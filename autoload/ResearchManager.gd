extends Node
## Research-domain service (autoload). Tracks which weapon research has been
## unlocked. A save provider — state persists on sleep.
##
## Adding a new research item: add it to Research.CATALOG + implement its effect
## wherever it applies. No changes here.

var _unlocked: Dictionary = {}  # research_id -> true


func _ready() -> void:
	SaveManager.register("research", self)


func has(id: String) -> bool:
	return _unlocked.get(id, false)


func unlock(id: String) -> void:
	_unlocked[id] = true
	EventBus.research_completed.emit(id)
	EventBus.inventory_changed.emit()


## True if every item in the catalog has been researched.
func all_done() -> bool:
	for item in Research.CATALOG:
		if not has(item["id"]):
			return false
	return true


func can_afford() -> bool:
	return InventoryManager.station.count(Items.Type.DATACHIP) >= Research.COST_DATA


func consume_cost() -> void:
	InventoryManager.station.remove(Items.Type.DATACHIP, Research.COST_DATA)


# --- save provider ----------------------------------------------------------

func save_data() -> Dictionary:
	return {"unlocked": _unlocked.keys()}


func load_data(data: Dictionary) -> void:
	_unlocked = {}
	for id in data.get("unlocked", []):
		_unlocked[id] = true


func reset_data() -> void:
	_unlocked = {}
