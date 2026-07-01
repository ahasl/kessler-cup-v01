extends Area2D
## Fuel Cell — a floating pickup that instantly refills the whole fuel tank
## (like Dave the Diver's oxygen tanks). Flying over it triggers the refill in
## the player ship. Self-contained / modular — drop instances into any biome.

var _pulse := 0.0


func _ready() -> void:
	add_to_group("fuel_cell")


func collect() -> void:
	queue_free()


func _process(delta: float) -> void:
	_pulse += delta * 4.0
	var s := 1.0 + 0.12 * sin(_pulse)
	scale = Vector2(s, s)
