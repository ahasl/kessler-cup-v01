extends Node2D
## Slow idle spin for background parallax silhouettes (planets/satellites/
## asteroids) — purely cosmetic, keeps the distant layers from looking frozen.

@export var spin_speed: float = 0.05  # radians/sec, sign sets direction


func _process(delta: float) -> void:
	rotation += spin_speed * delta
