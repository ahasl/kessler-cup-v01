extends StaticBody2D
## A large asteroid that shatters into several normal (smaller) asteroids when
## destroyed — which can then be shot too. Modular; drop into any biome.

const MAX_HP := 30
const FRAGMENTS := 3
const FRAGMENT_DIST := 58.0

const ASTEROID_SCENE := preload("res://scenes/run/asteroid.tscn")
const LOOT_SCENE := preload("res://scenes/run/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _body: Polygon2D = $Body
@onready var _particles: CPUParticles2D = $Particles

var hp: int = MAX_HP
var _base_modulate := Color.WHITE
var _dead := false


func _ready() -> void:
	add_to_group("asteroids")
	rotation = randf() * TAU
	_base_modulate = modulate


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	var dmg := 1.0 - float(hp) / float(MAX_HP)
	_body.color = Color(0.24, 0.26, 0.32).lerp(Color(0.55, 0.25, 0.25), dmg)
	if hp <= 0:
		_destroy()


func set_targeted(on: bool) -> void:
	modulate = _base_modulate * 1.6 if on else _base_modulate


func _show_damage(amount: int) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(number)
	number.global_position = global_position + Vector2(-30, -40)
	number.setup(amount)


func _destroy() -> void:
	_dead = true
	var loot := LOOT_SCENE.instantiate()
	loot.item_type = Items.roll_drop()
	get_parent().add_child(loot)
	loot.global_position = global_position

	for i in FRAGMENTS:
		var frag := ASTEROID_SCENE.instantiate()
		get_parent().add_child(frag)
		var ang := TAU * float(i) / float(FRAGMENTS) + randf() * 0.6
		frag.global_position = global_position + Vector2(cos(ang), sin(ang)) * FRAGMENT_DIST

	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()
