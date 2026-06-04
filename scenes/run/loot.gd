extends Area2D
## Run-domain loot pickup. Flying over it routes the item into the TEMPORARY run
## inventory. Visual/collision live in loot.tscn; colour is set per item type.

@onready var _body: Polygon2D = $Body

var item_type: int = Items.Type.METAL
var amount: int = 1

var _pulse := 0.0


func _ready() -> void:
	add_to_group("loot")
	_body.color = Items.color(item_type)


func collect() -> void:
	InventoryManager.add_run_loot(item_type, amount)
	queue_free()


func _process(delta: float) -> void:
	_pulse += delta * 4.0
	var s := 1.0 + 0.15 * sin(_pulse)
	scale = Vector2(s, s)
