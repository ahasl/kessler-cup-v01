extends Area2D
## Run-domain loot pickup. Flying over it routes the item into the TEMPORARY run
## inventory. Visual/collision live in loot.tscn; colour is set per item type.

@onready var _body: Polygon2D = $Body
@onready var _icon: Sprite2D = $Icon

var item_type: int = Items.Type.METAL
var amount: int = 1

var _pulse := 0.0


func _ready() -> void:
	add_to_group("loot")
	var tex_path := Items.texture_path(item_type)
	if tex_path != "":
		var tex: Texture2D = load(tex_path)
		_icon.texture = tex
		_icon.modulate = Items.color(item_type)
		var max_dim: float = max(tex.get_size().x, tex.get_size().y)
		if max_dim > 0:
			_icon.scale = Vector2(20.0 / max_dim, 20.0 / max_dim)
		_icon.visible = true
		_body.visible = false
	else:
		_body.color = Items.color(item_type)


func collect() -> void:
	InventoryManager.add_run_loot(item_type, amount)
	queue_free()


func _process(delta: float) -> void:
	_pulse += delta * 4.0
	var s := 1.0 + 0.15 * sin(_pulse)
	scale = Vector2(s, s)
