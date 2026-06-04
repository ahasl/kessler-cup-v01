extends Node2D
## Decorative colored nebula cloud. Does nothing gameplay-wise — just drifts and
## pulses softly to fill the void. Tint/size set per instance. Put behind the
## action (z_index < 0). Modular — drop several into any biome.

@export var tint: Color = Color(0.5, 0.35, 1.0)
@export var base_alpha: float = 0.5
@export var pulse_speed: float = 0.5

var _t := 0.0


func _ready() -> void:
	_t = randf() * TAU


func _process(delta: float) -> void:
	_t += delta
	var a := base_alpha * (0.8 + 0.2 * sin(_t * pulse_speed))
	modulate = Color(tint.r, tint.g, tint.b, a)
	rotation += delta * 0.015
