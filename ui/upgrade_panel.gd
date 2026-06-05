extends CanvasLayer
## The station PC terminal. Two tabs — Ship and Weapon — each built from the
## Upgrades catalogue by category. Empty categories show a placeholder.

const ROW_SCENE := preload("res://ui/upgrade_row.tscn")

@onready var _root: Control = $Root
@onready var _ship_tab: VBoxContainer = $Root/Center/Panel/VBox/Tabs/Ship
@onready var _weapon_tab: VBoxContainer = $Root/Center/Panel/VBox/Tabs/Weapon
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton


func _ready() -> void:
	_close_button.pressed.connect(close)
	_build("ship", _ship_tab)
	_rebuild_weapon_tab()
	close()


func _build(category: String, container: VBoxContainer) -> void:
	var ids := Upgrades.ids_in_category(category)
	if ids.is_empty():
		_add_placeholder(container, "No upgrades available yet.")
		return
	for id in ids:
		var row := ROW_SCENE.instantiate()
		container.add_child(row)
		row.setup(id)


func _rebuild_weapon_tab() -> void:
	for child in _weapon_tab.get_children():
		child.queue_free()
	var ids := Upgrades.ids_in_category("weapon")
	var available := ids.filter(func(id: String) -> bool: return ResearchManager.has(id))
	if available.is_empty():
		_add_placeholder(_weapon_tab, "No weapon upgrades researched yet.\nVisit the Research Lab.")
		return
	for id in available:
		var row := ROW_SCENE.instantiate()
		_weapon_tab.add_child(row)
		row.setup(id)


func _add_placeholder(container: VBoxContainer, msg: String) -> void:
	var lbl := Label.new()
	lbl.text = msg
	lbl.add_theme_color_override("font_color", Color(0.45, 0.52, 0.65))
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	container.add_child(lbl)


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and event.is_action_pressed("ui_cancel"):
		close()


func open() -> void:
	_rebuild_weapon_tab()
	_root.visible = true
	EventBus.overlay_opened.emit()


func close() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()
