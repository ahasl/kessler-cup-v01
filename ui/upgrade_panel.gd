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
	_build("weapon", _weapon_tab)
	close()


func _build(category: String, container: VBoxContainer) -> void:
	var ids := Upgrades.ids_in_category(category)
	if ids.is_empty():
		var placeholder := Label.new()
		placeholder.text = "No upgrades available yet."
		placeholder.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
		container.add_child(placeholder)
		return
	for id in ids:
		var row := ROW_SCENE.instantiate()
		container.add_child(row)
		row.setup(id)


func open() -> void:
	_root.visible = true


func close() -> void:
	_root.visible = false
