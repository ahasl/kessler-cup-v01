extends CanvasLayer
## Generic upgrade terminal. Builds one row per catalogue entry in its
## `category`, so the same scene serves the PC ("ship") and the Weapon Workbench
## ("weapon"). New upgrades in that category appear automatically.

const ROW_SCENE := preload("res://ui/upgrade_row.tscn")

@export var category: String = "ship"
@export var title_text: String = "SHIP UPGRADES"

@onready var _root: Control = $Root
@onready var _title: Label = $Root/Center/Panel/VBox/Title
@onready var _rows: VBoxContainer = $Root/Center/Panel/VBox/Rows
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton


func _ready() -> void:
	_title.text = title_text
	_close_button.pressed.connect(close)
	for id in Upgrades.ids_in_category(category):
		var row := ROW_SCENE.instantiate()
		_rows.add_child(row)
		row.setup(id)
	close()


func open() -> void:
	_root.visible = true


func close() -> void:
	_root.visible = false
