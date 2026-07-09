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

## Records across all runs ever (Dave the Diver style post-run recap).
var best_run_time: float = 0.0
var best_distance: float = 0.0

## Target scene the loading screen should switch to once it's done.
var _next_scene: String = ""


func _ready() -> void:
	EventBus.player_docked.connect(_on_player_docked)
	EventBus.player_died.connect(_on_player_died)
	SaveManager.register("meta", self)


# --- Save provider (run-independent meta state) -----------------------------

func save_data() -> Dictionary:
	return {
		"day": day, "runs_today": runs_today,
		"best_run_time": best_run_time, "best_distance": best_distance,
	}


func load_data(data: Dictionary) -> void:
	day = int(data.get("day", 1))
	runs_today = int(data.get("runs_today", 0))
	best_run_time = float(data.get("best_run_time", 0.0))
	best_distance = float(data.get("best_distance", 0.0))


func reset_data() -> void:
	day = 1
	runs_today = 0
	run_active = false
	best_run_time = 0.0
	best_distance = 0.0


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
	EventBus.say_id("launch")
	# Emitted last so any quest line it triggers is the message that shows on arrival.
	EventBus.run_started.emit()
	_load_scene(SPACE_SCENE)


func _on_player_docked(run_time: float, max_distance: float) -> void:
	if not run_active:
		return
	# SUCCESS: run loot is extracted into persistent station storage, and any
	# carried blueprints are committed (permanently unlocked).
	InventoryManager.transfer_run_to_station()
	run_active = false
	EventBus.run_ended.emit(true)
	EventBus.say_id("docked")
	ProgressManager.commit_pending()
	_report_run_stats(run_time, max_distance)


func _on_player_died(_run_time: float, _max_distance: float) -> void:
	if not run_active:
		return
	# FAILURE: run loot AND any carried blueprints are lost. No run-summary
	# recap here on purpose — that celebration is for a successful extraction,
	# not for dying.
	InventoryManager.discard_run()
	ProgressManager.discard_pending()
	run_active = false
	EventBus.run_ended.emit(false)
	EventBus.say_id("died", "warning")
	goto_station()


## Compares this run against the all-time records, updates them, and hands the
## recap to the run-summary UI (still in the space scene). The station
## transition itself waits for the UI to call `goto_station()` once dismissed.
func _report_run_stats(run_time: float, max_distance: float) -> void:
	var time_record := run_time > best_run_time
	var distance_record := max_distance > best_distance
	var stats := {
		"run_time": run_time,
		"best_run_time": max(run_time, best_run_time),
		"time_record": time_record,
		"max_distance": max_distance,
		"best_distance": max(max_distance, best_distance),
		"distance_record": distance_record,
	}
	if time_record:
		best_run_time = run_time
	if distance_record:
		best_distance = max_distance
	EventBus.run_summary_ready.emit(stats)


## Leaving a run early via the pause menu's "Main Menu" option — same cleanup
## as dying, minus the flavor text (the player chose to quit, not lose).
func abandon_run() -> void:
	if not run_active:
		return
	InventoryManager.discard_run()
	ProgressManager.discard_pending()
	run_active = false
	EventBus.run_ended.emit(false)


# --- Meta: sleeping ends the day and persists progression -------------------

func sleep_and_save() -> void:
	InventoryManager.reset_run()
	day += 1
	runs_today = 0
	var drone_haul := _run_drone_bay()
	SaveManager.save_game()
	EventBus.say_id("sleep")
	if not drone_haul.is_empty():
		_announce_drone_haul(drone_haul)


## The Drone Bay (Station Expansion, level 1+) sends its collector drone out
## once per day, right after sleeping, and it comes back with materials.
## Returns the haul (empty if there's no drone yet) so it can be announced.
func _run_drone_bay() -> Dictionary:
	var level := UpgradeManager.get_drone_level()
	var haul := DroneBay.roll_haul(level)
	for item_type in haul:
		InventoryManager.add_station_loot(item_type, haul[item_type])
	return haul


func _announce_drone_haul(haul: Dictionary) -> void:
	var parts: Array[String] = []
	for item_type in haul:
		parts.append("%d %s" % [int(haul[item_type]), Items.display_name(item_type)])
	EventBus.say("%s %s" % [AiLines.pick("drone_bay_return"), ", ".join(parts)])
