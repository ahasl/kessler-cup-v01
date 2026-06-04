# Ideas — making biomes feel alive (and beyond)

Why Dave the Diver's world feels full: **depth (parallax layers) · constant small
motion · light & colour · density of small details** — not a few big objects.
Translate that to space. Keep everything **modular** (own scene, dropped into a
biome), so a biome is just a composition of these.

## Ambience — biome filler

### Done ✅
- **Nebula** (`scenes/run/nebula.tscn`) — soft colored cloud, slowly drifts/pulses,
  does nothing. Per-instance `tint` / `base_alpha`. Sits behind the action (z -10).
  (Tuned blue + subtle to match the planet.)
- **Dust field** (`scenes/run/dust_field.tscn`) — many tiny slow drifting motes over
  the biome. Clearly background (no collision), reads as "not collectible".
- **Comets** (`scenes/run/comet.tscn` + `comet_spawner.gd`) — occasional streak with
  a fading trail crosses the view. Spawner lives in space.tscn.
- ~~Space critter (jellyfish)~~ — removed: looked collectible/confusing; replaced by dust.
- **Parallax background** (`scenes/run/space_parallax.tscn`) — 3 tiled star layers at
  different scroll speeds (dense, white, crisp) → depth.
- **Distant gas giant** (`scenes/run/gas_giant.tscn`) — huge faint planet on a 0.05
  parallax layer (barely moves) = horizon landmark.
- **God rays** (`scenes/run/god_rays.tscn`) — faint shimmering diagonal light shafts
  over the nebula.
- **Drifting asteroids** — ~45% of asteroids now slowly drift (field isn't frozen).

### Next (high impact, cheap)
- **Drifting junk** — tumbling non-destructible debris bits (between dust and asteroids).
- **Background silhouettes** — far-off derelict station/ship outlines.
- **Light rays / god rays** — faint volumetric beams through the nebula.
- **Passing comets** — occasional streak with a tail crossing the view.
- **Derelict silhouettes** — far-off wreck/station outlines in the haze.

## New map objects (some gameplay)
- **Scan / points-of-interest** — small anomalies AnI comments on ("unknown
  signal"); gives her more lines and gives the map "targets".
- **Derelict wreck to loot** — bigger than the debris clusters, holds loot.
- **Gravity well / whirlpool** — rotating nebula that gently pulls the ship
  (optional risk near the edge).
- **Beacons / blinking buoys** — pulsing lights, navigation flavour.
- **Mineral-rich super-asteroid** — a rare large rock with extra loot.

## Recipe to remember
1. Depth via parallax (3+ layers)
2. Constant small motion (drift / particles / critters)
3. Light & colour (glow, nebula zones, rays)
4. Many small details > few big ones

## Other backlog (gameplay/systems)
- Quest/objective log UI (uses ProgressManager flags).
- AnI hint when an undiscovered probe/POI is nearby.
- More biomes (each its own scene), bosses, friendly NPCs (all save via flags).
- Station growth (Stardew-like), more buildables behind blueprints.
- Card/deck ship-module system (long-term).
