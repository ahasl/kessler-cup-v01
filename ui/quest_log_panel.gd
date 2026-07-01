extends CanvasLayer
## Quest log. Opened from the station's log console. Two columns — active
## ("IN PROGRESS") and completed — each a scrollable stack of quest_row
## cards; refreshes live.

const ROW_SCENE := preload("res://ui/quest_row.tscn")

@onready var _root: Control = $Root
@onready var _active_list: VBoxContainer = $Root/Center/Panel/VBox/Columns/Active/VBox/Scroll/List
@onready var _done_list: VBoxContainer = $Root/Center/Panel/VBox/Columns/Done/VBox/Scroll/List
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton


func _ready() -> void:
	_close_button.pressed.connect(close)
	EventBus.quest_updated.connect(_on_updated)
	close()


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	_root.visible = true
	EventBus.overlay_opened.emit()
	_refresh()


func close() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()


func _on_updated() -> void:
	if _root.visible:
		_refresh()


func _refresh() -> void:
	_fill(_active_list, QuestManager.active_ids(), false, "No active objectives.\nLaunch a run.")
	_fill(_done_list, QuestManager.done_ids(), true, "Nothing completed yet.")


func _fill(list: VBoxContainer, ids: Array, completed: bool, empty_msg: String) -> void:
	for child in list.get_children():
		child.queue_free()
	if ids.is_empty():
		var lbl := Label.new()
		lbl.text = empty_msg
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		lbl.add_theme_color_override("font_color", Color(0.4, 0.45, 0.55))
		lbl.add_theme_font_size_override("font_size", 12)
		list.add_child(lbl)
		return
	for id in ids:
		var row := ROW_SCENE.instantiate()
		list.add_child(row)
		row.setup(Quests.LIST[id], completed)
