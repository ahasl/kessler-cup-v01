extends CharacterBody2D
## Drift mine: slowly drifts (doesn't chase), drains fuel and explodes on contact
## with the ship, and can be shot to destroy it safely. A blinking light pulses.

const MAX_HP := 4
const DRIFT_SPEED := 24.0
const CONTACT_FUEL := 30.0

const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _hitbox: Area2D = $Hitbox
@onready var _light: Polygon2D = $Light
@onready var _particles: CPUParticles2D = $Particles

var hp: int = MAX_HP
var _base_modulate := Color.WHITE
var _dir := Vector2.RIGHT
var _dead := false


func _ready() -> void:
	add_to_group("hazard")
	_base_modulate = modulate
	_dir = Vector2.from_angle(randf() * TAU)
	_hitbox.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	velocity = _dir * DRIFT_SPEED
	move_and_slide()
	rotation += delta * 0.6
	# Warning light blink.
	var t := Time.get_ticks_msec() / 1000.0
	_light.modulate.a = 0.35 + 0.65 * (0.5 + 0.5 * sin(t * 6.0))


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	if hp <= 0:
		_explode()


func set_targeted(on: bool) -> void:
	modulate = _base_modulate * 1.6 if on else _base_modulate


func _show_damage(amount: int) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(number)
	number.global_position = global_position + Vector2(-30, -28)
	number.setup(amount)


func _on_body_entered(body: Node2D) -> void:
	if _dead:
		return
	if body.is_in_group("player"):
		_dead = true
		if body.has_method("environment_drain"):
			body.environment_drain(CONTACT_FUEL)
		_explode()


func _explode() -> void:
	_dead = true
	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()
