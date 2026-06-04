extends Node
## Application orchestrator (autoload). Owns the high-level loop and scene
## transitions. No gameplay logic — it only wires domains together via EventBus.

const MAIN_MENU_SCENE := "res://ui/main_menu.tscn"
const STATION_SCENE := "res://scenes/station/station.tscn"
const SPACE_SCENE := "res://scenes/run/space.tscn"
const LOADING_SCENE := "res://ui/loading.tscn"

const MAX_RUNS_PER_DAY := 2

var day: int = 1
var run_active: bool = false
var runs_today: int = 0

## Target scene the loading screen should switch to once it's done.
var _next_scene: String = ""


func _ready() -> void:
	EventBus.player_docked.connect(_on_player_docked)
	EventBus.player_died.connect(_on_player_died)
	SaveManager.register("meta", self)


# --- Save provider (run-independent meta state) -----------------------------

func save_data() -> Dictionary:
	return {"day": day, "runs_today": runs_today}


func load_data(data: Dictionary) -> void:
	day = int(data.get("day", 1))
	runs_today = int(data.get("runs_today", 0))


func reset_data() -> void:
	day = 1
	runs_today = 0
	run_active = false


# App-level input (window concerns, not gameplay). F11 toggles fullscreen.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# --- Scene navigation -------------------------------------------------------

func goto_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func goto_station() -> void:
	_load_scene(STATION_SCENE)


## Switch scenes via the loading screen (used for the station<->space transitions).
func _load_scene(target: String) -> void:
	_next_scene = target
	get_tree().change_scene_to_file(LOADING_SCENE)


func consume_next_scene() -> String:
	var target := _next_scene
	_next_scene = ""
	return target


# --- Run lifecycle ----------------------------------------------------------

func start_run() -> void:
	if runs_today >= MAX_RUNS_PER_DAY:
		EventBus.say_id("run_limit", "warning")
		return
	runs_today += 1
	InventoryManager.reset_run()
	ProgressManager.discard_pending()
	run_active = true
	EventBus.run_started.emit()
	EventBus.say_id("launch")
	_load_scene(SPACE_SCENE)


func _on_player_docked() -> void:
	if not run_active:
		return
	# SUCCESS: run loot is extracted into persistent station storage, and any
	# carried blueprints are committed (permanently unlocked).
	InventoryManager.transfer_run_to_station()
	run_active = false
	EventBus.run_ended.emit(true)
	EventBus.say_id("docked")
	ProgressManager.commit_pending()
	goto_station()


func _on_player_died() -> void:
	if not run_active:
		return
	# FAILURE: run loot AND any carried blueprints are lost.
	InventoryManager.discard_run()
	ProgressManager.discard_pending()
	run_active = false
	EventBus.run_ended.emit(false)
	EventBus.say_id("died", "warning")
	goto_station()


# --- Meta: sleeping ends the day and persists progression -------------------

func sleep_and_save() -> void:
	InventoryManager.reset_run()
	day += 1
	runs_today = 0
	SaveManager.save_game()
	EventBus.say_id("sleep")
