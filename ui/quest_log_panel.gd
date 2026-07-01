extends CanvasLayer
## Quest log. Opened from the station's log console. Lists active and completed
## objectives (main/side) with descriptions; refreshes live.

@onready var _root: Control = $Root
@onready var _list: RichTextLabel = $Root/Center/Panel/VBox/List
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
	var text := ""
	var active := QuestManager.active_ids()
	var done := QuestManager.done_ids()
	if active.is_empty() and done.is_empty():
		text = "[color=#808890]No objectives yet. Launch a run.[/color]"
	for id in active:
		text += _format(id, false)
	for id in done:
		text += _format(id, true)
	_list.text = text


func _format(id: String, completed: bool) -> String:
	var q: Dictionary = Quests.LIST[id]
	var is_main: bool = q["type"] == "main"
	var col := "#ff8a4a" if is_main else "#5ad0ff"
	var tag := "MAIN" if is_main else "SIDE"
	var status := "   ✓ COMPLETE" if completed else ""
	return "[color=%s][b][%s]  %s[/b]%s[/color]\n%s\n\n" % [col, tag, q["title"], status, q["desc"]]
