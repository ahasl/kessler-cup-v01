extends Node2D
## Station-domain root scene (BASE). Wires the props to meta-domain actions.
## Holds NO run logic. Props, player, camera, HUD and panels are composed in
## station.tscn.
##
## The station has two physical layouts, `level1` and `level2` (siblings of
## this node), each with its own full set of props. Only one is visible/active
## at a time — `_apply_station_level()` toggles them based on the
## "station_level" upgrade (UpgradeManager.get_station_level()). `level2` adds
## a Drone Bay prop that level1 doesn't have.

const RESEARCH_FLAG := "research_station"
const INTRO_FLAG    := "intro_shown"
const STATION_LEVEL_UPGRADE := "station_level"

@onready var _level1: Node2D = $level1
@onready var _level2: Node2D = $level2
@onready var _upgrade_panel: CanvasLayer = $UpgradePanel
@onready var _storage_panel: CanvasLayer = $StoragePanel
@onready var _research_panel: CanvasLayer = $ResearchPanel
@onready var _quest_panel: CanvasLayer = $QuestLogPanel
@onready var _drone_bay_panel: CanvasLayer = $DroneBayPanel
@onready var _fade: CanvasLayer = $ScreenFade

var _research_props: Array = []


func _ready() -> void:
	_wire_level(_level1)
	_wire_level(_level2)
	EventBus.progress_unlocked.connect(func(_flag): _update_research())
	EventBus.upgrade_purchased.connect(_on_upgrade_purchased)
	_apply_station_level()
	_update_research()
	if not ProgressManager.has(INTRO_FLAG):
		ProgressManager.unlock(INTRO_FLAG)
		get_tree().create_timer(1.2).timeout.connect(_say_intro)


# Connects every prop present in a level's Props node to its shared handler.
# Both levels carry the same prop set (Bed/Terminal/Door/Storage/Research/Log);
# level2 additionally has a DroneBay. Missing nodes are skipped, so a level
# doesn't need every prop.
func _wire_level(level: Node2D) -> void:
	var props := level.get_node("Props")
	_connect_prop(props, "Bed", _on_bed)
	_connect_prop(props, "Terminal", _on_terminal)
	_connect_prop(props, "Door", _on_door)
	_connect_prop(props, "Storage", _on_storage)
	_connect_prop(props, "Log", _on_log)
	_connect_prop(props, "DroneBay", _on_drone_bay)
	var research: Interactable = props.get_node_or_null("Research")
	if research:
		research.triggered.connect(_on_research)
		_research_props.append(research)


func _connect_prop(props: Node2D, name: String, handler: Callable) -> void:
	var prop: Interactable = props.get_node_or_null(name)
	if prop:
		prop.triggered.connect(handler)


func _say_intro() -> void:
	EventBus.say_id("intro")


# The research lab only exists once Voyager 1 has been salvaged.
func _update_research() -> void:
	var unlocked := ProgressManager.has(RESEARCH_FLAG)
	for research in _research_props:
		research.visible = unlocked
		research.monitorable = unlocked
		research.set_deferred("monitoring", unlocked)
		var body: Node = research.get_node_or_null("Blocker")
		if body:
			body.process_mode = Node.PROCESS_MODE_INHERIT if unlocked else Node.PROCESS_MODE_DISABLED


func _on_upgrade_purchased(id: String, _new_level: int) -> void:
	if id == STATION_LEVEL_UPGRADE:
		_apply_station_level()


# Only the active level is visible AND processing — the inactive one is fully
# disabled so its Interactables can't be triggered while off-screen.
func _apply_station_level() -> void:
	var expanded := UpgradeManager.get_station_level() >= 1
	_set_level_active(_level1, not expanded)
	_set_level_active(_level2, expanded)


func _set_level_active(level: Node2D, active: bool) -> void:
	level.visible = active
	level.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED


func _on_bed() -> void:
	_fade.flash()
	GameManager.sleep_and_save()


func _on_log() -> void:
	_quest_panel.open()


func _on_terminal() -> void:
	_upgrade_panel.open()


func _on_door() -> void:
	GameManager.start_run()


func _on_storage() -> void:
	_storage_panel.open()


func _on_research() -> void:
	_research_panel.open()


func _on_drone_bay() -> void:
	_drone_bay_panel.open()
