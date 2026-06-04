extends StaticBody2D
## Run-domain asteroid. A solid body (the ship collides with it). Takes laser
## damage; on destruction announces itself, drops loot and a particle burst.
## Visual/collision live in asteroid.tscn.

const MAX_HP := 10

const LOOT_SCENE := preload("res://scenes/run/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _body: Polygon2D = $Body
@onready var _particles: CPUParticles2D = $Particles

var hp: int = MAX_HP
var _spin: float = 0.0
var _drift: Vector2 = Vector2.ZERO
var _base_modulate := Color.WHITE
var _dead := false


func _ready() -> void:
	add_to_group("asteroids")
	rotation = randf() * TAU          # cheap variety from one shared shape
	_spin = randf_range(-0.35, 0.35)  # slow rotation (rad/s)
	# About half of them slowly drift, so the field isn't frozen.
	if randf() < 0.45:
		_drift = Vector2.from_angle(randf() * TAU) * randf_range(6.0, 16.0)
	_base_modulate = modulate


## Brighten while the ship is aiming at it (highlight = shootable).
func set_targeted(on: bool) -> void:
	modulate = _base_modulate * 1.6 if on else _base_modulate


func _physics_process(delta: float) -> void:
	rotation += _spin * delta
	if _drift != Vector2.ZERO:
		position += _drift * delta


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	# Tint toward red as it gets damaged.
	var dmg := 1.0 - float(hp) / float(MAX_HP)
	_body.color = Color(0.22, 0.24, 0.30).lerp(Color(0.55, 0.25, 0.25), dmg)
	if hp <= 0:
		_destroy()


func _show_damage(amount: int) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(number)
	number.global_position = global_position + Vector2(-30, -28)
	number.setup(amount)


func _destroy() -> void:
	_dead = true
	EventBus.asteroid_destroyed.emit(global_position)
	_spawn_loot()
	# Detach the particle emitter so the burst outlives this node.
	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()


func _spawn_loot() -> void:
	var loot := LOOT_SCENE.instantiate()
	loot.item_type = Items.roll_drop()
	get_parent().add_child(loot)
	loot.global_position = global_position
