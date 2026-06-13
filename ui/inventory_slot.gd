extends PanelContainer
## A single inventory slot view. `set_slot` accepts either null (empty) or a
## { "type": int, "count": int } stack dictionary.

@onready var _bg: ColorRect = $VBox/Swatch/BG
@onready var _icon: TextureRect = $VBox/Swatch/Icon
@onready var _name_label: Label = $VBox/Name
@onready var _count_label: Label = $VBox/Count


func set_slot(data) -> void:
	if data == null:
		_bg.color = Color(0.15, 0.16, 0.20)
		_bg.visible = true
		_icon.visible = false
		_name_label.text = "—"
		_count_label.text = ""
	else:
		var tex_path := Items.texture_path(int(data.type))
		if tex_path != "":
			_icon.texture = load(tex_path) as Texture2D
			_icon.visible = true
			_bg.visible = false
		else:
			_bg.color = Items.color(int(data.type))
			_bg.visible = true
			_icon.visible = false
		_name_label.text = Items.display_name(int(data.type))
		_count_label.text = "x%d" % int(data.count)
