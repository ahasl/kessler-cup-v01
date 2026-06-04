extends Area2D
## Run-domain projectile. Travels in a straight line and expires after a set
## DISTANCE (range), so range is a tunable upgrade rather than a fixed lifetime.
## Damage is passed in per shot so weapon upgrades drive it.

const SPEED := 600.0

var _direction := Vector2.RIGHT
var _max_distance := 420.0
var _damage := 2
var _travelled := 0.0


func _ready() -> void:
	add_to_group("laser")
	body_entered.connect(_on_body_entered)


## Configure the shot. Called by the ship right after spawning.
func setup(direction: Vector2, range_px: float, damage: int) -> void:
	_direction = direction.normalized()
	_max_distance = range_px
	_damage = damage


func _physics_process(delta: float) -> void:
	var step := SPEED * delta
	global_position += _direction * step
	_travelled += step
	if _travelled >= _max_distance:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Damages anything destructible; absorbed by any solid body (incl. obstacles).
	if body.has_method("take_damage"):
		body.take_damage(_damage)
	queue_free()
