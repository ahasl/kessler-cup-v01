extends Node
## Save-domain service (autoload). Persists ONLY meta progress as JSON.
##
## It knows nothing about WHAT is saved: any system registers itself as a
## "save provider" and the manager aggregates them. To make a new system (bosses,
## NPCs, research, ...) persistent, just implement the three methods below and
## call SaveManager.register("your_key", self) in _ready — no edits here needed.
##
## A save provider must implement:
##   save_data() -> Dictionary      # current progress for this system
##   load_data(data: Dictionary)    # apply loaded progress
##   reset_data()                   # back to a fresh-game default
##
## Single save slot at user://savegame.dat (a new game overwrites it on save).

const SAVE_PATH := "user://savegame.dat"
const SAVE_VERSION := 2

var _providers: Dictionary = {}  # key (String) -> provider (Node)


func register(key: String, provider: Node) -> void:
	_providers[key] = provider


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> void:
	var data := {"version": SAVE_VERSION}
	for key in _providers:
		data[key] = _providers[key].save_data()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot write %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	EventBus.game_saved.emit()


## Loads the save into every registered provider. Returns false if nothing loaded.
func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("SaveManager: corrupt save, ignoring")
		return false

	for key in _providers:
		if data.has(key):
			_providers[key].load_data(data[key])
	EventBus.inventory_changed.emit()
	return true


## Resets every provider to fresh-game defaults (does not touch the file until
## the next save_game()).
func new_game() -> void:
	for key in _providers:
		_providers[key].reset_data()
	EventBus.inventory_changed.emit()
