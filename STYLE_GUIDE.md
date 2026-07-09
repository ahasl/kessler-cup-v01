# Space Visual Style Guide (run domain)

Single source of truth for how anything in `scenes/run/` looks. If a change
doesn't fit a rule here, fix the rule first — don't pick a one-off exception.
Scope: **space only.** The station interior (`scenes/station/`) is a separate,
unconverted pixel-art style and not covered by this document.

## Shape

- `Polygon2D` fill + `Line2D` outline. No raster art, no gradients on solid
  objects (gradients are reserved for soft decoration, see below).
- 3–8 vertices per solid shape. Line2D "soft" elements (rings, halos, glows)
  are exempt — they're meant to look smooth, not faceted.
- Fill is always near-black (`~0.04–0.09` per channel) — barely visible
  against the starfield. Fill **never** carries identity color. All color
  lives in the outline. Exception: `crystal_geode.gd`/`plasma_vent.tscn`
  flash the fill toward white under damage — a deliberate "cracking energy
  core" cue, not a resting-state color.
- No standalone glow-halo aura (soft translucent polygon behind the shape) on
  destructibles/hazards — that's reserved for actual pickups (see below).

## Color — the ONLY four outline colors that exist

| Color | RGB | Means |
|---|---|---|
| White-grey | `(0.75, 0.8, 0.85)` | Neutral environment (asteroids, wreckage) |
| Cyan | `(0.4, 0.9, 1)` | Player / friendly / valuable (ship, docking pad, crystal geode, container) |
| Red | `(1, 0.35, 0.3)` | Any threat (drone, foe1, interceptor, drift mine — tell them apart by shape, not hue) |
| Gold | `(1, 0.9, 0.5)` | Quest-relevant (probe, blueprint) |

No fifth color. A new object that doesn't fit one of these four semantically
needs a category discussion, not an ad-hoc hue.

This rule governs **outlines specifically**. Two adjacent systems are allowed
their own palettes because they serve a different purpose — but they must
stay internally consistent, not grow new one-off colors either:

- **Material identity** (`Items.gd color()`): Metal/Crystal/Data
  Fragment/Ice/Plasma/Reinforced Alloy each get one fixed color, used
  everywhere that material appears — the game-icons.net icon tint, the loot
  pickup glow+ring, the inventory slot. A material's color is not the same
  axis as the outline-semantics table above (a Crystal pickup is cyan-ish
  because that's Crystal's color, not because "cyan = friendly").
- **Decoration** (`scenes/run/decoration/`): planets/nebulae/gas giants use
  soft gradient textures, not flat fill+outline — they're background, not
  objects the player interacts with, so the shape rules above don't apply.
  Keep decoration colors desaturated/dim relative to gameplay objects so
  they never compete with something the player needs to read at a glance.
- **Particle bursts** (destruction/impact VFX): warm tones (orange/white) are
  fine regardless of the object's resting color — an explosion doesn't need
  to match its source's identity color, impacts read as "impact" universally.

## Labeling

Anything targetable (`set_targeted(bool)`) gets a `NameTag` Label child:
`top_level = true`, hidden by default, shown on targeted, font_color matches
the object's outline color, black `font_outline_color` (`outline_size = 5`)
so it stays legible over any background brightness. Sync its
`global_position` every frame the object can move; static objects can sync
once in `_ready`.

## Motion & effects ("juice")

- **Hit feedback:** `modulate = _base_modulate * 1.3 if on else _base_modulate`
  on target — never higher, it overwhelms damage numbers. Damage numbers
  (`damage_number.tscn`) always carry a black outline (`outline_size = 6`)
  so they read regardless of what's flashing behind them.
- **Player ship:** thrust/strafe should be visible, not just implied by
  position change — engine trail while moving, side-flare intensity tied to
  the lateral velocity component (see `player_ship.gd`).
- Moving hazards/enemies must physically collide with solid terrain and each
  other — `collision_mask` has to include layer 2 (asteroids/wreckage) and
  layer 8 (other enemies), or they clip through everything. Static
  destructibles (`StaticBody2D`) never separate from each other regardless of
  mask — Godot doesn't resolve static-vs-static overlap — so avoid placing
  them within roughly 90px of each other by hand when building a biome.

## Collision layers

See `CLAUDE.md` "Collision layers (run domain)" — kept there since it's
gameplay-logic reference, not visual style, but the two documents describe
the same objects and must stay in sync.

## Extending this guide

Adding a new destructible/pickup/hazard:
1. Pick which of the 4 outline colors it semantically belongs to (or, if it's
   a material source, use that material's `Items.color()`).
2. Build its shape at 3–8 vertices, near-black fill.
3. Add a `NameTag` if it's targetable.
4. If it moves, set `collision_mask` to include layer 2 + 8.
5. If none of this fits, that's a sign this guide needs a new rule — edit
   this file in the same change, don't special-case it in the scene alone.
