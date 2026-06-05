extends Node
## Quest service (autoload). Tracks active/completed quests, fires their triggers
## off EventBus signals, and announces them through AnI. Save provider, so quest
## progress persists on sleep. New quest = add to Quests.LIST + a trigger here.

const VOYAGER_DAY := 1
const ALLOY_DAY := 5

var _active: Dictionary = {}  # id -> true
var _done: Dictionary = {}    # id -> true


func _ready() -> void:
	SaveManager.register("quests", self)
	EventBus.run_started.connect(_on_run_started)
	EventBus.progress_unlocked.connect(_on_progress_unlocked)
	EventBus.inventory_changed.connect(_on_inventory_changed)


# --- queries (for the quest log) --------------------------------------------

func active_ids() -> Array:
	return _active.keys()


func done_ids() -> Array:
	return _done.keys()


func is_active(id: String) -> bool:
	return _active.has(id)


func is_done(id: String) -> bool:
	return _done.has(id)


# --- state changes ----------------------------------------------------------

func activate(id: String) -> void:
	if _active.has(id) or _done.has(id):
		return
	_active[id] = true
	EventBus.quest_updated.emit()
	var line: String = Quests.LIST[id].get("activate_line", "New objective: %s." % Quests.LIST[id]["title"])
	EventBus.say(line)


func complete(id: String) -> void:
	if not _active.has(id):
		return
	_active.erase(id)
	_done[id] = true
	EventBus.quest_updated.emit()
	EventBus.say("Objective complete: %s." % Quests.LIST[id]["title"])


# --- triggers ---------------------------------------------------------------

func _on_run_started() -> void:
	if GameManager.day >= VOYAGER_DAY:
		activate("find_voyager")
	if GameManager.day >= ALLOY_DAY:
		activate("reinforced_alloy")


func _on_progress_unlocked(flag: String) -> void:
	# Salvaging the Voyager probe (its blueprint) completes the side quest.
	if flag == "research_station":
		complete("find_voyager")


func _on_inventory_changed() -> void:
	if InventoryManager.station.count(Items.Type.REINFORCED_ALLOY) > 0:
		complete("reinforced_alloy")


# --- save provider ----------------------------------------------------------

func save_data() -> Dictionary:
	return {"active": _active.keys(), "done": _done.keys()}


func load_data(data: Dictionary) -> void:
	_active = {}
	_done = {}
	for id in data.get("active", []):
		_active[id] = true
	for id in data.get("done", []):
		_done[id] = true


func reset_data() -> void:
	_active = {}
	_done = {}
