class_name Research
extends RefCounted
## Research catalogue. Pure data — no nodes, no autoloads. Unlocked in order
## (first non-researched entry is next). Each entry's `id` must match an
## Upgrades.CATALOG id — researching it just reveals that upgrade at the
## terminal; buying it (cost, level) still happens there, same as any other
## upgrade. Adding a new research item = add an entry to CATALOG. Nothing
## else changes.
##
## `minigame` picks which puzzle unlocks it: "pipe" (Pressure Equalizer —
## ship-side upgrades) or "signal" (Frequency Tuning — weapon upgrades).

const COST_DATA := 1  # Data Fragments per attempt

## Each entry: id, name, desc, minigame.
const CATALOG: Array = [
	{
		"id":       "metal_alloy",
		"name":     "Reinforced Plating",
		"desc":     "Unlocks the hull upgrade needed to survive Biome 2.",
		"minigame": "pipe",
	},
	{
		"id":       "laser_dmg_1",
		"name":     "Laser Damage I",
		"desc":     "Increases laser damage from 2 to 3.",
		"minigame": "signal",
	},
]
