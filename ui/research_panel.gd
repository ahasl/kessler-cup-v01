extends CanvasLayer
## Weapon Research panel. Opens from the Research Station prop.
## Cheat: press 6 three times quickly → fills inventory + reveals debug skip button.

const MINIGAME_SCENE := preload("res://ui/signal_minigame.tscn")
const CHEAT_WINDOW   := 1.2  # seconds allowed between presses

@onready var _root:         Control = $Root
@onready var _data_label:   Label   = $Root/Center/Panel/VBox/DataLabel
@onready var _start_btn:    Button  = $Root/Center/Panel/VBox/BtnRow/StartButton
@onready var _debug_btn:    Button        = $Root/Center/Panel/VBox/BtnRow/DebugButton
@onready var _status_label: Label         = $Root/Center/Panel/VBox/StatusLabel
@onready var _close_btn:    Button        = $Root/Center/Panel/VBox/CloseButton

var _minigame:        CanvasLayer = null
var _debug_mode:      bool        = false
var _cheat_count:     int         = 0
var _cheat_timer:     float       = 0.0


func _ready() -> void:
	_close_btn.pressed.connect(close)
	_start_btn.pressed.connect(_on_start)
	_debug_btn.pressed.connect(_on_debug_skip)
	EventBus.inventory_changed.connect(_refresh)
	EventBus.research_completed.connect(func(_id: String) -> void: _refresh())
	close()


func _process(delta: float) -> void:
	if _cheat_timer > 0.0:
		_cheat_timer -= delta
		if _cheat_timer <= 0.0:
			_cheat_count = 0


func _unhandled_input(event: InputEvent) -> void:
	# Cheat code: 6-6-6 — works whether panel is open or not
	if event is InputEventKey and (event as InputEventKey).pressed \
			and not (event as InputEventKey).echo:
		if (event as InputEventKey).keycode == KEY_6:
			_cheat_count += 1
			_cheat_timer  = CHEAT_WINDOW
			if _cheat_count >= 3:
				_cheat_count = 0
				_cheat_timer = 0.0
				_activate_debug()

	if not _root.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	_root.visible = true
	EventBus.overlay_opened.emit()
	_refresh()


func close() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()


func _refresh() -> void:
	var count: int = InventoryManager.station.count(Items.Type.DATACHIP)
	_data_label.text = "Data Fragments: %d" % count

	if ResearchManager.all_done():
		_start_btn.visible = false
		_debug_btn.visible = false
		_status_label.text = "All weapon research completed."
		_status_label.visible = true
		return

	_status_label.visible = false
	_start_btn.visible = true
	_start_btn.disabled = not ResearchManager.can_afford()
	_debug_btn.visible = _debug_mode


func _activate_debug() -> void:
	_debug_mode = true
	for item_type: int in Items.ALL:
		InventoryManager.station.add(item_type, 99)
	EventBus.inventory_changed.emit()
	EventBus.say("[DEBUG] Cheats on — materials filled.")
	if _root.visible:
		_debug_btn.visible = true


func _on_start() -> void:
	ResearchManager.consume_cost()
	_minigame = MINIGAME_SCENE.instantiate()
	_minigame.layer = 10
	get_tree().root.add_child(_minigame)
	_minigame.completed.connect(_on_minigame_done)
	_minigame.start()


func _on_minigame_done(success: bool) -> void:
	_minigame.queue_free()
	_minigame = null
	if success:
		for item: Dictionary in Research.CATALOG:
			if not ResearchManager.has(item["id"]):
				ResearchManager.unlock(item["id"])
				EventBus.say("New weapon upgrade unlocked: %s — %s" % [item["name"], item.get("desc", "")])
				break
	else:
		EventBus.say("Signal lost. Data Fragments consumed.", "warning")
	_refresh()


func _on_debug_skip() -> void:
	for item: Dictionary in Research.CATALOG:
		if not ResearchManager.has(item["id"]):
			ResearchManager.unlock(item["id"])
			EventBus.say("[DEBUG] %s unlocked." % item["name"])
			break
	_refresh()
