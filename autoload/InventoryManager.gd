extends Node
## Inventory-domain service (autoload). Owns two distinct aggregates that must
## never be conflated:
##   station -> PERSISTENT storage (saved)
##   run     -> TEMPORARY loot bag (wiped every run, never saved)

const RUN_CARRY_SLOTS := 6
const STATION_SLOTS := 999

var station: Inventory
var run: Inventory


func _ready() -> void:
	station = Inventory.new(STATION_SLOTS)
	run = Inventory.new(RUN_CARRY_SLOTS)
	SaveManager.register("inventory", self)


func add_run_loot(item_type: int, amount: int) -> void:
	run.add(item_type, amount)
	EventBus.loot_collected.emit(item_type, amount)


func reset_run() -> void:
	run.clear()


func discard_run() -> void:
	run.clear()


func transfer_run_to_station() -> void:
	run.transfer_into(station)
	EventBus.inventory_changed.emit()


# --- Save provider (only the persistent station storage is saved) -----------

func save_data() -> Dictionary:
	return {"station": station.to_dict()}


func load_data(data: Dictionary) -> void:
	station.from_dict(data.get("station", {}))


func reset_data() -> void:
	station.clear()
	run.clear()
