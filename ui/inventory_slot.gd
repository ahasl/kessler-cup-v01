extends PanelContainer
## A single inventory slot view. `set_slot` accepts either null (empty) or a
## { "type": int, "count": int } stack dictionary.

@onready var _swatch: ColorRect = $VBox/Swatch
@onready var _name_label: Label = $VBox/Name
@onready var _count_label: Label = $VBox/Count


func set_slot(data) -> void:
	if data == null:
		_swatch.color = Color(0.15, 0.16, 0.20)
		_name_label.text = "—"
		_count_label.text = ""
	else:
		_swatch.color = Items.color(int(data.type))
		_name_label.text = Items.display_name(int(data.type))
		_count_label.text = "x%d" % int(data.count)
