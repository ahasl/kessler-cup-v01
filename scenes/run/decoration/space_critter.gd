extends Node2D
## Harmless ambient space critter (think Dave the Diver's drifting jellyfish).
## Slowly wanders and pulses, does nothing else — just makes the void feel alive.
## Tint set per instance. Modular — scatter several into any biome.

const SPEED := 16.0

@export var tint: Color = Color(0.4, 0.95, 1.0)

var _dir := Vector2.RIGHT
var _t := 0.0


func _ready() -> void:
	_t = randf() * TAU
	_dir = Vector2.from_angle(randf() * TAU)
	modulate = tint


func _process(delta: float) -> void:
	_t += delta
	# Lazy wandering: gently curve the heading over time.
	_dir = _dir.rotated(sin(_t * 0.7) * delta * 1.2)
	position += _dir * SPEED * delta
	var s := 1.0 + 0.12 * sin(_t * 2.0)
	scale = Vector2(s, s)
