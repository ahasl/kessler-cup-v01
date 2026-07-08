extends Control
## A single square inventory slot: icon centred in a rounded frame, count
## shown as a small badge in the corner (no name label — the item name is a
## tooltip instead). `set_slot` accepts either null (empty) or a
## { "type": int, "count": int } stack dictionary. Reused by both the run HUD
## cargo bar and the station storage grid.

@onready var _frame:        Panel     = $Frame
@onready var _icon:         TextureRect = $Icon
@onready var _color_swatch: ColorRect = $ColorSwatch
@onready var _badge:        Control   = $Badge
@onready var _count_label:  Label     = $Badge/CountLabel


func set_slot(data) -> void:
	if data == null:
		_icon.visible = false
		_color_swatch.visible = false
		_frame.self_modulate = Color(1, 1, 1, 0.45)
		_badge.visible = false
		tooltip_text = ""
		return

	_frame.self_modulate = Color.WHITE
	var item_type := int(data.type)
	var tex_path := Items.texture_path(item_type)
	if tex_path != "":
		_icon.texture = load(tex_path) as Texture2D
		_icon.modulate = Items.color(item_type)
		_icon.visible = true
		_color_swatch.visible = false
	else:
		# No dedicated art yet: fall back to a coloured swatch.
		_color_swatch.color = Items.color(item_type)
		_color_swatch.visible = true
		_icon.visible = false

	_badge.visible = true
	_count_label.text = str(int(data.count))
	tooltip_text = Items.display_name(item_type)
