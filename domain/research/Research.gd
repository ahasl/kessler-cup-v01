class_name Research
extends RefCounted
## Research catalogue. Pure data — no nodes, no autoloads.
## Adding a new research item = add an entry to CATALOG. Nothing else changes.

const COST_DATA := 1  # Data Fragments per attempt

## Each entry: id, name, desc.
const CATALOG: Array = [
	{
		"id":   "laser_dmg_1",
		"name": "Laser Damage I",
		"desc": "Increases laser damage from 2 to 3.",
	},
]
