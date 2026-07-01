extends StaticBody2D
## Run-domain asteroid. HP and metal drop amount are set per scene via exports,
## so small_asteroid.tscn can reuse this script with different values.

const LOOT_SCENE         := preload("res://scenes/run/collectibles/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@export var max_hp:      int = 10
@export var drop_amount: int = 2

@onready var _body:      Sprite2D       = $Body
@onready var _particles: CPUParticles2D = $Particles

var hp: int = 0
var _spin:          float   = 0.0
var _drift:         Vector2 = Vector2.ZERO
var _base_modulate: Color   = Color.WHITE
var _dead:          bool    = false


func _ready() -> void:
	hp = max_hp
	add_to_group("asteroids")
	rotation = randf() * TAU
	_spin = randf_range(-0.35, 0.35)
	if randf() < 0.45:
		_drift = Vector2.from_angle(randf() * TAU) * randf_range(6.0, 16.0)
	_base_modulate = modulate


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
	var dmg := 1.0 - float(hp) / float(max_hp)
	_body.modulate = Color.WHITE.lerp(Color(1.0, 0.35, 0.35), dmg)
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
	var loot := LOOT_SCENE.instantiate()
	loot.item_type  = Items.Type.METAL
	loot.amount     = drop_amount
	get_parent().add_child(loot)
	loot.global_position = global_position
	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()
