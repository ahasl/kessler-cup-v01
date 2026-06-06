extends Node2D
## Station-domain root scene (BASE). Wires the props to meta-domain actions.
## Holds NO run logic. Props, player, camera, HUD and panels are composed in
## station.tscn.

const RESEARCH_FLAG := "research_station"
const INTRO_FLAG    := "intro_shown"

@onready var _bed: Interactable = %Bed
@onready var _terminal: Interactable = %Terminal
@onready var _door: Interactable = %Door
@onready var _storage: Interactable = %Storage
@onready var _research: Interactable = %Research
@onready var _log: Interactable = %Log
@onready var _upgrade_panel: CanvasLayer = $UpgradePanel
@onready var _storage_panel: CanvasLayer = $StoragePanel
@onready var _research_panel: CanvasLayer = $ResearchPanel
@onready var _quest_panel: CanvasLayer = $QuestLogPanel
@onready var _fade: CanvasLayer = $ScreenFade


func _ready() -> void:
	_bed.triggered.connect(_on_bed)
	_terminal.triggered.connect(_on_terminal)
	_door.triggered.connect(_on_door)
	_storage.triggered.connect(_on_storage)
	_research.triggered.connect(_on_research)
	_log.triggered.connect(_on_log)
	EventBus.progress_unlocked.connect(func(_flag): _update_research())
	_update_research()
	if not ProgressManager.has(INTRO_FLAG):
		ProgressManager.unlock(INTRO_FLAG)
		get_tree().create_timer(1.2).timeout.connect(_say_intro)


func _say_intro() -> void:
	EventBus.say_id("intro")


# The research lab only exists once Voyager 1 has been salvaged.
func _update_research() -> void:
	var unlocked := ProgressManager.has(RESEARCH_FLAG)
	_research.visible = unlocked
	_research.monitorable = unlocked
	_research.set_deferred("monitoring", unlocked)
	var body := _research.get_node_or_null("Blocker")
	if body:
		body.process_mode = Node.PROCESS_MODE_INHERIT if unlocked else Node.PROCESS_MODE_DISABLED


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
