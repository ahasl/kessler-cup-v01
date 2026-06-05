# Kessler Cup — Project Guide (for Claude)

2D top-down space **extraction roguelite** in **Godot 4.6** (run → return → upgrade).
Inspiration: Dave the Diver (loop), Slay the Spire (progression), Nova Drift (neon feel).
This is a clean, modular **DDD foundation** — prioritise **extensibility**, never hard-code
what should be data, never mix the two worlds (see below).

## Golden rules
- **Two worlds, never mixed:** RUN domain (space, temporary, never saved) vs META domain
  (station, persistent, saved). They communicate ONLY through `EventBus` signals — no
  direct cross-scene node references.
- **Definitions live in code, progress lives in the save.** Catalogs (`Upgrades.CATALOG`,
  `Items`, later bosses/NPCs) define what *can* exist. The JSON save stores only what the
  player *has/achieved*, referencing catalog ids. Base stats are central in `Upgrades.gd`;
  runtime value = base + saved level.
- **Extensibility is everything.** Prefer adding a catalog entry / a save provider over
  editing call sites.
- **Use real scenes**, not procedural node-building, for props/UI/entities/maps.

## Testing (IMPORTANT — always verify)
A Godot 4.6.2 binary is installed locally:
`/Users/alexander.hasl/Downloads/Godot 2.app/Contents/MacOS/Godot`
(`Godot.app` is 4.3 — do NOT use it.)
- Import + parse check: `"$GODOT" --headless --editor --quit --path .`
- Load a scene headless: `"$GODOT" --headless --path . res://<scene>.tscn --quit-after 20`
- A stale editor-cache warning about a deleted file is harmless; ignore it.
- After big changes the user may need to **restart the Godot editor** (cache).

## Layout
```
autoload/   EventBus, SaveManager, InventoryManager, UpgradeManager, ProgressManager, GameManager  (load order matters)
domain/     Items.gd, Inventory.gd (inventory) · Upgrades.gd (upgrade catalog)  — pure, no nodes
scenes/run/      space, player_ship, asteroid, loot, laser, docking_pad, biome.gd
scenes/run/biomes/  biome_home, biome_belt  (one scene PER biome; map elements placed inside)
scenes/station/  station, station_player, interactable.gd, props/{bed,terminal,door,storage}
ui/         main_menu, loading, run_hud, station_hud, inventory_view, inventory_slot,
            upgrade_panel, upgrade_row, storage_panel, ai_assistant
shaders/    starfield.gdshader, danger_vignette.gdshader
environment/ glow.tres (WorldEnvironment glow, used by space & station)
```
Autoload order: `EventBus, SaveManager, InventoryManager, UpgradeManager, GameManager`
(SaveManager must exist before providers register with it).

## Save system (extensible)
`SaveManager` is generic: systems call `SaveManager.register("key", self)` in `_ready` and
implement `save_data() -> Dictionary`, `load_data(d)`, `reset_data()`. To persist a NEW
system (bosses, NPCs, research): implement those three + register — no SaveManager edits.
Single slot at `user://savegame.dat` (pretty JSON). New Game overwrites on next save.
Saving happens when sleeping in the bed (`GameManager.sleep_and_save`).

## EventBus signals
`asteroid_destroyed, loot_collected, run_started, run_ended, player_docked, player_died,
fuel_changed, edge_danger, upgrade_purchased, game_saved, inventory_changed, ai_message`.
`EventBus.say(text, level)` shows an AnI message (survives scene change via `pending_message`).

## Game loop
MainMenu (New Game / Continue) → loading → Station. Station props (E to interact):
Bed = sleep+save, Storage (Lager) = view all stored materials, Terminal = upgrades,
Door = start run. Run: WASD thrust, mouse aim, LMB fire (held = auto-fire), fly into the
home-station dock + E to extract. Out of fuel or straying past a biome edge = run lost
(rescue drone, cargo gone). Loading screen on every station↔space switch.

## Content / tuning quick-reference
- Materials (`Items.gd`): Metal, Crystal, Data Fragment (weighted drops). Add = enum + 3 cases.
- Upgrades (`Upgrades.gd` CATALOG): `fuel_tank` (+20 fuel, ×10; 20 Metal/3 Crystal/1 Data),
  `metal_alloy` (unlock biomes; 15 Metal). Costs scale with level via `cost_for`.
- Ship base stats in `Upgrades.gd`: speed 250, max fuel 100, laser dmg 2, range 420.
- Map: composed of Biome scenes (`scenes/run/biomes/`) placed side by side in space.tscn.
  Each `Biome` (biome.gd) declares size/requires_alloy/penalty/messages and holds its own
  asteroids (fixed layout). `space.gd` discovers biomes via the "biome" group and applies
  rules generically. New biome = new scene + drop into space.tscn (no code changes).
- Inventory: run carry = 5 slots (limit); station storage = effectively unlimited.

## Progression / unlocks (quests, blueprints)
`ProgressManager` holds named unlock flags (save provider). `has("flag")` /
`unlock("flag")`. Pattern in play: a `probe` (quest object) spawns only while its
flag is NOT set; shoot it -> drops a `blueprint` pickup -> collecting it calls
`ProgressManager.unlock(flag)` -> the flag persists on next sleep and the probe
never respawns. The station shows the matching buildable when the flag is set
(e.g. the **Research Station** prop appears once `research_station` is unlocked —
salvaged from the Voyager 1 probe).
New quest/unlock = new flag id + a probe/blueprint + something gated on `has()`.

Quests: `QuestManager` (autoload, save provider) tracks active/done quests from
`Quests.LIST` (domain/quests.gd), fired off EventBus signals, announced via AnI,
shown in the station Quest Log (Log console -> quest_log_panel). Current quests:
`find_voyager` (side, day 1, completes when the Voyager probe blueprint is salvaged)
and `reinforced_alloy` (main, day 5, completes when Reinforced Alloy reaches storage).
Reinforced Alloy is a material dropped only by metal-rich asteroids that appear from
day 5; it's the cost of the `metal_alloy` hull upgrade -> gates the next biome.

The station **PC terminal** (`upgrade_panel.tscn`) has two tabs built from upgrade
`category`: **Ship** (fuel_tank, metal_alloy) and **Weapon** (intentionally empty
for now — weapon upgrades come later via research).

## Collision layers (run domain)
1 = player ship · 2 = asteroids (solid) · 4 = pickups (loot/docking/fuel_cell, Area2D) ·
8 = enemies (drone body). Ship body mask=2; ship pickup-sensor mask=4; laser mask=10 (2+8,
hits anything with `take_damage`); drone hitbox mask=1. Enemies are NOT layer 2, so the ship
passes through them (contact handled by the drone's own hitbox, no physical bounce).

## Enemies & pickups (modular content)
- `drone.tscn` (enemy): chases the player, drains `CONTACT_FUEL` on touch (no weapons), 5 HP,
  smokes below half, drops a Data Fragment. Hit via laser `take_damage`. Drop instances into a biome.
- `fuel_cell.tscn` (pickup): flying over it fully refills fuel (handled in player_ship `_on_sensor_area_entered`).
- Both are placed inside biome scenes (e.g. 5 drones + 3 fuel cells in `biome_home.tscn`).

## Conventions
- snake_case files; `class_name` PascalCase (Items, Inventory, Upgrades, Interactable).
- Match surrounding comment density / idiom. Keep behaviour in scripts, visuals/collision in scenes.
