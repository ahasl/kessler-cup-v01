extends Node2D
## Decorative comet: streaks across the view in a straight line, then frees
## itself. Purely visual, no collision — clearly background, not collectible.

const SPEED := 380.0
const LIFETIME := 7.0

var _dir := Vector2.RIGHT
var _age := 0.0


func setup(dir: Vector2) -> void:
	_dir = dir.normalized()
	rotation = _dir.angle()  # trail points behind the movement


func _process(delta: float) -> void:
	position += _dir * SPEED * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()
