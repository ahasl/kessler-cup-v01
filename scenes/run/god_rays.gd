extends Node2D
## Decorative light shafts ("god rays"). A few faint diagonal beams that slowly
## shimmer and drift. Purely visual, sits behind the action. Per-instance tint.

@export var tint: Color = Color(0.6, 0.8, 1.0)
@export var base_alpha: float = 0.07

var _t := 0.0


func _ready() -> void:
	_t = randf() * TAU


func _process(delta: float) -> void:
	_t += delta
	var a := base_alpha * (0.55 + 0.45 * sin(_t * 0.4))
	modulate = Color(tint.r, tint.g, tint.b, a)
	rotation += delta * 0.008
