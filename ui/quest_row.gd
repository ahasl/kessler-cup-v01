extends PanelContainer
## One quest card in the Quest Log. Read-only — just displays a quest's tag
## (MAIN/SIDE, colored), title and description, dimmed + checked when done.

@onready var _tag_label: Label = $Margin/VBox/Header/Tag
@onready var _title_label: Label = $Margin/VBox/Header/Title
@onready var _check_label: Label = $Margin/VBox/Header/Check
@onready var _desc_label: Label = $Margin/VBox/Desc


func setup(quest: Dictionary, completed: bool) -> void:
	var is_main: bool = quest["type"] == "main"
	var accent := Color(1.0, 0.54, 0.29) if is_main else Color(0.35, 0.82, 1.0)

	_tag_label.text = "MAIN" if is_main else "SIDE"
	_tag_label.add_theme_color_override("font_color", accent)

	var style: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	style.border_color = accent
	add_theme_stylebox_override("panel", style)

	_title_label.text = quest["title"]
	_desc_label.text = quest["desc"]
	_check_label.visible = completed
	modulate = Color(1, 1, 1, 0.55) if completed else Color(1, 1, 1, 1)
