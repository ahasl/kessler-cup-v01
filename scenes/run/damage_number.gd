extends Label
## Floating combat-damage number. Rises and fades, then frees itself.

const DURATION := 0.7
const RISE := 46.0

var _life := 0.0


func setup(amount: int) -> void:
	text = str(amount)


func _process(delta: float) -> void:
	_life += delta
	position.y -= RISE * delta
	modulate.a = clampf(1.0 - _life / DURATION, 0.0, 1.0)
	if _life >= DURATION:
		queue_free()
