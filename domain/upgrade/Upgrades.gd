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
#   "ship"    -> the station PC terminal, Ship tab
#   "weapon"  -> the station PC terminal, Ship Weapon tab
#   "station" -> the station PC terminal, Station tab
# An id also listed in Research.CATALOG only shows up in its tab once
# ResearchManager.has(id) — i.e. its minigame at the Research Station has been
# won at least once (see research_panel.gd). Ids NOT in Research.CATALOG
# (e.g. fuel_tank) are always buyable, no minigame required.
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
		"desc": "Reinforced hull — survive new biomes (needs Reinforced Alloy)",
		"levels": [
			{"cost": {Items.Type.REINFORCED_ALLOY: 2}},  # material from the day-5 quest
		],
		# Also listed in Research.CATALOG: must win the Pressure Equalizer at
		# the Research Station before it appears in the Ship tab at all.
	},
	# Weapon upgrades — unlocked via Research Lab, then built here.
	"laser_dmg_1": {
		"name": "Laser Damage I",
		"category": "weapon",
		"desc": "Increases laser damage from 2 to 3.",
		"base_value": 2.0,
		"value_label": "damage",
		"levels": [
			{"value": 3.0, "cost": {Items.Type.METAL: 8, Items.Type.CRYSTAL: 3, Items.Type.DATACHIP: 1}},
		],
	},
	# Station upgrades — expand the station itself. Level 1 -> 2 swaps in the
	# larger station layout (station.gd) and unlocks the Drone Bay.
	"station_level": {
		"name": "Station Expansion",
		"category": "station",
		"desc": "Expands the station and adds a Drone Bay — a collector drone that salvages materials once a day.",
		"levels": [
			{"cost": {Items.Type.METAL: 100, Items.Type.CRYSTAL: 20, Items.Type.DATACHIP: 5}},
		],
	},
	# Drone Bay tiers. Only shown once the Drone Bay exists (`requires`:
	# station_level >= 1). Drone level = 1 + this upgrade's level — see
	# UpgradeManager.get_drone_level(). Each tier brings home a bit more per
	# day (see DroneBay.gd's LEVELS table).
	"drone_bay_upgrade": {
		"name": "Drone Bay Upgrade",
		"category": "station",
		"desc": "A better-equipped collector drone brings home more materials per trip.",
		"requires": "station_level",
		"level_offset": 1,  # raw level 0 = drone level 1, see UpgradeManager.get_drone_level()
		"levels": [
			{"cost": {Items.Type.METAL: 40, Items.Type.CRYSTAL: 8, Items.Type.DATACHIP: 2}},   # drone level 1 -> 2
			{"cost": {Items.Type.METAL: 80, Items.Type.CRYSTAL: 16, Items.Type.DATACHIP: 4}},  # drone level 2 -> 3
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
