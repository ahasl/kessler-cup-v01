extends CanvasLayer
## Research panel. Opens from the Research Station prop. Lists every
## not-yet-researched catalog entry (Research.CATALOG) as its own row — the
## player freely picks ship or weapon research, in any order. Each entry
## starts its own minigame — the Pressure Equalizer for ship-side items (e.g.
## hull plating), the Frequency Tuning wave for weapon items. Researching an
## item just reveals it at the terminal; buying it still costs its normal
## materials there.
## Cheat: press 6 three times quickly → fills inventory + reveals debug skip button.

const MINIGAME_SCENES := {
	"pipe": preload("res://ui/pipe_minigame.tscn"),
	"signal": preload("res://ui/signal_minigame.tscn"),
}
const ROW_SCENE := preload("res://ui/research_row.tscn")
const CHEAT_WINDOW := 1.2  # seconds allowed between presses

@onready var _root:         Control = $Root
@onready var _data_label:   Label   = $Root/Center/Panel/VBox/DataLabel
@onready var _list:         VBoxContainer = $Root/Center/Panel/VBox/List
@onready var _debug_btn:    Button        = $Root/Center/Panel/VBox/DebugButton
@onready var _status_label: Label         = $Root/Center/Panel/VBox/StatusLabel
@onready var _close_btn:    Button        = $Root/Center/Panel/VBox/CloseButton

var _minigame:        CanvasLayer = null
var _debug_mode:      bool        = false
var _cheat_count:     int         = 0
var _cheat_timer:     float       = 0.0
var _pending_id:      String      = ""


func _ready() -> void:
	_close_btn.pressed.connect(close)
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


## Every not-yet-researched catalog entry, in catalog order.
func _pending_items() -> Array:
	var out: Array = []
	for item: Dictionary in Research.CATALOG:
		if not ResearchManager.has(item["id"]):
			out.append(item)
	return out


func _refresh() -> void:
	var count: int = InventoryManager.station.count(Items.Type.DATACHIP)
	_data_label.text = "Data Fragments: %d" % count

	for child in _list.get_children():
		child.queue_free()

	var pending := _pending_items()
	if pending.is_empty():
		_list.visible = false
		_debug_btn.visible = false
		_status_label.text = "All research completed."
		_status_label.visible = true
		return

	_status_label.visible = false
	_list.visible = true
	_debug_btn.visible = _debug_mode
	var affordable := ResearchManager.can_afford()
	for item: Dictionary in pending:
		var row := ROW_SCENE.instantiate()
		_list.add_child(row)
		row.setup(item)
		row.set_affordable(affordable)
		row.start_requested.connect(_on_start)


func _activate_debug() -> void:
	_debug_mode = true
	for item_type: int in Items.ALL:
		InventoryManager.station.add(item_type, 99)
	EventBus.inventory_changed.emit()
	EventBus.say("[DEBUG] Cheats on — materials filled.")
	if _root.visible:
		_debug_btn.visible = true


func _on_start(id: String) -> void:
	if _minigame != null:
		return
	var item := _find_item(id)
	if item.is_empty() or ResearchManager.has(id):
		return
	_pending_id = id
	var minigame_key: String = item.get("minigame", "signal")
	ResearchManager.consume_cost()
	_minigame = MINIGAME_SCENES[minigame_key].instantiate()
	_minigame.layer = 10
	get_tree().root.add_child(_minigame)
	_minigame.completed.connect(_on_minigame_done)
	_minigame.start()


func _on_minigame_done(success: bool) -> void:
	_minigame.queue_free()
	_minigame = null
	if success:
		var item: Dictionary = _find_item(_pending_id)
		ResearchManager.unlock(_pending_id)
		EventBus.say("New upgrade unlocked: %s — %s" % [item["name"], item.get("desc", "")])
	else:
		EventBus.say("Research failed. Data Fragments consumed.", "warning")
	_pending_id = ""
	_refresh()


func _find_item(id: String) -> Dictionary:
	for item: Dictionary in Research.CATALOG:
		if item["id"] == id:
			return item
	return {}


func _on_debug_skip() -> void:
	var pending := _pending_items()
	if not pending.is_empty():
		var item: Dictionary = pending[0]
		ResearchManager.unlock(item["id"])
		EventBus.say("[DEBUG] %s unlocked." % item["name"])
	_refresh()
