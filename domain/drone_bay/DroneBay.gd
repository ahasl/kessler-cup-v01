class_name DroneBay
extends RefCounted
## Drone-bay domain rules: the collector drone's daily haul table. Pure data +
## helpers, no autoload state. Unlocked at station level 1 (Station
## Expansion); further tiers come from the "drone_bay_upgrade" upgrade (see
## UpgradeManager.get_drone_level()). Each level has a fixed guaranteed Metal
## amount plus a number of weighted 1-unit bonus rolls, so the total materials
## per day is exact per level (3 / 4 / 6) while the mix stays a bit random.

const BONUS_POOL := [
	{"type": Items.Type.METAL, "weight": 5},
	{"type": Items.Type.CRYSTAL, "weight": 2},
	{"type": Items.Type.DATACHIP, "weight": 2},
]

const LEVELS := {
	1: {"guaranteed": {Items.Type.METAL: 2}, "bonus_rolls": 1},  # total 3
	2: {"guaranteed": {Items.Type.METAL: 3}, "bonus_rolls": 1},  # total 4
	3: {"guaranteed": {Items.Type.METAL: 4}, "bonus_rolls": 2},  # total 6
}


## Rolls one day's haul for the given drone level. Returns item_type -> amount.
## Empty if the level has no drone yet.
static func roll_haul(level: int) -> Dictionary:
	var data: Dictionary = LEVELS.get(level, {})
	if data.is_empty():
		return {}
	var haul: Dictionary = (data.get("guaranteed", {}) as Dictionary).duplicate()
	var rolls: int = int(data.get("bonus_rolls", 0))
	for i in rolls:
		var item_type := _roll_bonus_item()
		haul[item_type] = int(haul.get(item_type, 0)) + 1
	return haul


static func _roll_bonus_item() -> int:
	var total_weight := 0
	for entry in BONUS_POOL:
		total_weight += int(entry.weight)
	var roll := randi() % maxi(total_weight, 1)
	var acc := 0
	for entry in BONUS_POOL:
		acc += int(entry.weight)
		if roll < acc:
			return int(entry.type)
	return int(BONUS_POOL[0].type)


## Total materials per day at a given level (0 if no drone yet).
static func total_per_day(level: int) -> int:
	var data: Dictionary = LEVELS.get(level, {})
	if data.is_empty():
		return 0
	var total := 0
	for amount in (data.get("guaranteed", {}) as Dictionary).values():
		total += int(amount)
	total += int(data.get("bonus_rolls", 0))
	return total


## Human-readable list of materials this level's drone can bring back, most
## likely first (guaranteed materials, then the bonus pool).
static func describe(level: int) -> String:
	var data: Dictionary = LEVELS.get(level, {})
	if data.is_empty():
		return "—"
	var names: Array[String] = []
	for item_type in (data.get("guaranteed", {}) as Dictionary):
		names.append(Items.display_name(item_type))
	for entry in BONUS_POOL:
		var item_name := Items.display_name(int(entry.type))
		if not names.has(item_name):
			names.append(item_name)
	return ", ".join(names)
