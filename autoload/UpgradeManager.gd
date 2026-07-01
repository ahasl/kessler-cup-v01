extends Node
## Upgrade-domain service (autoload). Holds a level per upgrade id and exposes
## the derived ship stats the run domain reads. Generic over the Upgrades
## catalogue: purchasing/affording works for any id without special-casing.

var levels: Dictionary = {}  # id (String) -> level (int)


func _ready() -> void:
	SaveManager.register("upgrades", self)


# --- level access -----------------------------------------------------------

func level_of(id: String) -> int:
	return int(levels.get(id, 0))


func is_maxed(id: String) -> bool:
	return level_of(id) >= Upgrades.max_level(id)


# --- derived ship stats (read by the run domain) ----------------------------

func get_max_fuel() -> float:
	return Upgrades.value_at("fuel_tank", level_of("fuel_tank"))


func get_ship_speed() -> float:
	return Upgrades.BASE_SHIP_SPEED


func get_laser_damage() -> int:
	var lvl := level_of("laser_dmg_1")
	if lvl > 0:
		return int(Upgrades.value_at("laser_dmg_1", lvl))
	return Upgrades.BASE_LASER_DAMAGE


func get_laser_range() -> float:
	return Upgrades.BASE_LASER_RANGE


## Reinforced hull required to survive new biomes (e.g. the Crimson Belt).
func has_metal_alloy() -> bool:
	return level_of("metal_alloy") >= 1


## Station expansion level: 0 = starting station, 1 = expanded station + Drone Bay.
func get_station_level() -> int:
	return level_of("station_level")


## Drone Bay tier: 0 = no Drone Bay yet, 1-3 = its own upgrade track
## (drone_bay_upgrade), only meaningful once the station is expanded.
func get_drone_level() -> int:
	if get_station_level() < 1:
		return 0
	return 1 + level_of("drone_bay_upgrade")


# --- purchasing -------------------------------------------------------------

func can_afford(id: String) -> bool:
	if is_maxed(id):
		return false
	var cost := Upgrades.cost_for(id, level_of(id))
	for item_type in cost:
		if InventoryManager.station.count(item_type) < cost[item_type]:
			return false
	return true


func purchase(id: String) -> bool:
	if not can_afford(id):
		return false
	var cost := Upgrades.cost_for(id, level_of(id))
	for item_type in cost:
		InventoryManager.station.remove(item_type, cost[item_type])
	levels[id] = level_of(id) + 1
	EventBus.inventory_changed.emit()
	EventBus.upgrade_purchased.emit(id, levels[id])
	return true


# --- save provider ----------------------------------------------------------

func save_data() -> Dictionary:
	return {"levels": levels.duplicate()}


func load_data(data: Dictionary) -> void:
	levels = {}
	var saved: Dictionary = data.get("levels", {})
	for id in saved:
		levels[id] = int(saved[id])


func reset_data() -> void:
	levels = {}
