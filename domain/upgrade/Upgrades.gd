class_name Upgrades
extends RefCounted
## Upgrade-domain rules/data. A pure catalogue. Each upgrade lists its levels
## explicitly: every level entry has its own `cost` AND (where it changes a
## numeric stat) its resulting `value`. So progression is freely tunable and
## NON-linear — edit the numbers below, add/remove level entries at will.
##   level 0      = base_value
##   level N      = levels[N-1].value, bought for levels[N-1].cost
##   max_level    = number of level entries

# Fixed base ship stats (not levelled yet).
const BASE_SHIP_SPEED := 250.0
const BASE_LASER_DAMAGE := 2
const BASE_LASER_RANGE := 420.0

# `category` decides WHERE an upgrade is bought:
#   "ship"   -> the station PC terminal
#   "weapon" -> the Weapon Workbench (must be unlocked via a blueprint first)
const CATALOG := {
	"fuel_tank": {
		"name": "Fuel Tank",
		"category": "ship",
		"value_label": "max fuel",
		"base_value": 100.0,                # level 0
		"levels": [
			{"value": 150.0, "cost": {Items.Type.METAL: 6}},
			{"value": 200.0, "cost": {Items.Type.METAL: 20, Items.Type.CRYSTAL: 3}},
			{"value": 250.0, "cost": {Items.Type.METAL: 40, Items.Type.CRYSTAL: 6, Items.Type.DATACHIP: 1}},
			{"value": 300.0, "cost": {Items.Type.METAL: 70, Items.Type.CRYSTAL: 10, Items.Type.DATACHIP: 2}},
			{"value": 360.0, "cost": {Items.Type.METAL: 110, Items.Type.CRYSTAL: 16, Items.Type.DATACHIP: 3}},
			{"value": 420.0, "cost": {Items.Type.METAL: 160, Items.Type.CRYSTAL: 24, Items.Type.DATACHIP: 5}},
		],
	},
	"metal_alloy": {
		"name": "Double Metal Alloy",
		"category": "ship",
		"desc": "Reinforced hull — survive new biomes",
		"levels": [
			{"cost": {Items.Type.METAL: 15}},  # single unlock level (no numeric value)
		],
	},
	"laser_damage": {
		"name": "Laser Power",
		"category": "weapon",
		"value_label": "laser damage",
		"base_value": 2.0,
		"levels": [
			{"value": 3.0, "cost": {Items.Type.CRYSTAL: 8}},
			{"value": 4.0, "cost": {Items.Type.CRYSTAL: 14, Items.Type.METAL: 30}},
			{"value": 6.0, "cost": {Items.Type.CRYSTAL: 22, Items.Type.DATACHIP: 2}},
		],
	},
	"laser_range": {
		"name": "Laser Range",
		"category": "weapon",
		"value_label": "laser range",
		"base_value": 420.0,
		"levels": [
			{"value": 520.0, "cost": {Items.Type.CRYSTAL: 6}},
			{"value": 640.0, "cost": {Items.Type.CRYSTAL: 12, Items.Type.METAL: 20}},
			{"value": 780.0, "cost": {Items.Type.CRYSTAL: 20, Items.Type.DATACHIP: 1}},
		],
	},
}


## Upgrade ids belonging to a station category, in catalogue order.
static func ids_in_category(category: String) -> Array:
	var out: Array = []
	for id in CATALOG:
		if String(CATALOG[id].get("category", "ship")) == category:
			out.append(id)
	return out


static func max_level(id: String) -> int:
	return (CATALOG[id]["levels"] as Array).size()


## Cost to buy the NEXT level, given the current level (0-based).
static func cost_for(id: String, current_level: int) -> Dictionary:
	var levels: Array = CATALOG[id]["levels"]
	if current_level < 0 or current_level >= levels.size():
		return {}
	return levels[current_level]["cost"]


## The numeric stat value at a given level (level 0 = base_value).
static func value_at(id: String, level: int) -> float:
	if level <= 0:
		return float(CATALOG[id].get("base_value", 0.0))
	var levels: Array = CATALOG[id]["levels"]
	var i := clampi(level - 1, 0, levels.size() - 1)
	return float(levels[i].get("value", 0.0))
