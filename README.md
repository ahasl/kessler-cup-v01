# Kessler Cup

A 2D top-down space **extraction roguelite** foundation built in **Godot 4.6**.

Loop inspiration: *Dave the Diver* (run → return → upgrade), *Slay the Spire*
(progression), *Nova Drift* (minimal neon combat feel).

> This is a clean, modular **Domain-Driven Design** foundation — a playable
> prototype of the core loop, intentionally **not** a finished game.

---

## The two worlds

The codebase keeps two worlds strictly separate. They never share state and
never reference each other's nodes directly.

| Domain | World | Lifetime | Persistence |
|--------|-------|----------|-------------|
| **Run** | Space expedition | Resets every run | Never saved |
| **Meta / Station** | The hub | Persistent | Saved |

All cross-domain communication goes through the **`EventBus`** signal hub.

---

## Architecture

```
core/
  EventBus.gd          # autoload — global signal hub (the only cross-domain channel)
  GameManager.gd       # autoload — game loop orchestration + scene transitions

domains/
  run/                 # RUN DOMAIN (temporary, never persisted)
    SpaceScene.gd/.tscn
    PlayerShip.gd/.tscn   thrust, mouse-aim, laser, fuel
    Asteroid.gd/.tscn     10 HP, drops loot
    Loot.gd/.tscn         Metal / Crystal / DataChip
    Laser.gd/.tscn        2 damage projectile

  station/             # META DOMAIN (persistent hub)
    StationScene.gd/.tscn
    StationPlayer.gd/.tscn
    InteractZone.gd       bed / terminal / door triggers

  inventory/           # INVENTORY DOMAIN
    Items.gd              item catalogue (value object)
    Inventory.gd          5-slot stackable aggregate
    InventoryManager.gd   autoload — owns station (persistent) + run (temporary)

  upgrade/
    UpgradeManager.gd     autoload — Fuel Tank upgrade (only one for now)

  save/
    SaveManager.gd        autoload — persists ONLY station inventory + upgrades

ui/
  MainMenu.gd/.tscn
```

### Autoload order
`EventBus → InventoryManager → UpgradeManager → SaveManager → GameManager`

### EventBus signals
`asteroid_destroyed`, `loot_collected`, `run_started`, `run_ended`,
`player_docked`, `player_died`, `fuel_changed`, `upgrade_purchased`,
`game_saved`, `inventory_changed`.

---

## Game loop

```
MainMenu ──Play──▶ Station ──Door──▶ Space (run)
                     ▲                  │
                     │   dock (success) │  loot → station storage
                     └──────────────────┤
                         die / no fuel   │  loot lost
                                         ▼
                              back to Station
```

- **Bed** → ends the day, **saves the game**, resets run state.
- **PC Terminal** → buy the **Fuel Tank** upgrade
  (cost: 50 Metal · 7 Crystal · 1 DataChip → **+10 max fuel**).
- **Door** → start a space run.

### Space rules
- Fuel starts at max (100 + 10/level) and drains while thrusting.
- Fuel reaching **0 → run fails**, all run loot lost.
- Asteroids: **10 HP**, laser deals **2**; on death drop loot
  (Metal common · Crystal rare · DataChip very rare).
- Fly over loot to collect (into the **temporary** run inventory).
- Fly into the **DOCK** ring to extract → loot moves to persistent storage.

---

## Controls

| Input | Action |
|-------|--------|
| `WASD` | Thrust (space) / walk (station) |
| Mouse | Aim ship |
| Left Mouse | Fire laser |
| `E` | Interact (bed / PC / door) |

---

## Save

`user://savegame.dat` (JSON). Written **only** when sleeping in the bed.
Persists station inventory + ship upgrades. Run/world state is never saved.

---

## Designed to extend

Built to grow without breaking the domain split: card/deck ship modules,
more biomes & sectors, enemy factions, bosses, and Stardew-like station growth.
New features should keep talking through the `EventBus` rather than wiring
scenes together directly.

## Running

Open the project in **Godot 4.6** and press Play (main scene is
`res://ui/MainMenu.tscn`). On first open Godot will import assets and register
the `class_name` scripts.
