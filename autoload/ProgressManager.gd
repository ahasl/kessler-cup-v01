extends Node
## Progression service (autoload). A general set of named unlock flags for
## quests / blueprints / discoveries (e.g. "weapon_workbench"). Anything that
## needs to be "unlocked once and stay unlocked" is a flag here.
##
## Check with has("flag"); set with unlock("flag"). It's a save provider, so
## flags persist when the player sleeps. New progression content = new flag id,
## no changes here.

var _unlocked: Dictionary = {}  # flag -> true (committed, saved)
var _pending: Dictionary = {}   # flag -> title (collected this run, not yet extracted)


func _ready() -> void:
	SaveManager.register("progress", self)


func has(flag: String) -> bool:
	return _unlocked.get(flag, false)


func unlock(flag: String) -> void:
	if _unlocked.get(flag, false):
		return
	_unlocked[flag] = true
	EventBus.progress_unlocked.emit(flag)


# --- run-carried unlocks (committed on extraction, lost on death) -----------

## A blueprint was picked up this run. It only counts once safely extracted.
func collect_pending(flag: String, _title: String = "") -> void:
	_pending[flag] = true


## Successful dock: turn carried blueprints into permanent unlocks.
func commit_pending() -> void:
	if _pending.is_empty():
		return
	for flag in _pending:
		unlock(flag)
	_pending.clear()
	EventBus.say("Blueprint secured. Fine. I'll build the thing.")


## Run failed: carried blueprints are lost.
func discard_pending() -> void:
	_pending.clear()


# --- save provider ----------------------------------------------------------

func save_data() -> Dictionary:
	return {"unlocked": _unlocked.keys()}


func load_data(data: Dictionary) -> void:
	_unlocked = {}
	for flag in data.get("unlocked", []):
		_unlocked[flag] = true


func reset_data() -> void:
	_unlocked = {}
	_pending = {}
