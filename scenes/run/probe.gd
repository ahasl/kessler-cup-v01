extends StaticBody2D
## A quest probe: a tougher destructible that drops a blueprint on death,
## unlocking a station buildable. It only exists while its `unlock_flag` is NOT
## yet unlocked — once collected & saved it never reappears. Modular: set the
## flag/title and drop one into a biome.

const MAX_HP := 24

@export var unlock_flag: String = "weapon_workbench"
@export var unlock_title: String = "Weapon Workbench"
@export var probe_name: String = "Voyager 1"  # a real probe, for flavour

const BLUEPRINT_SCENE := preload("res://scenes/run/blueprint.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _body: Polygon2D = $Body
@onready var _particles: CPUParticles2D = $Particles

var hp: int = MAX_HP
var _base_modulate := Color.WHITE
var _dead := false


func _ready() -> void:
	# Already unlocked? Then this probe is done — don't appear at all.
	if ProgressManager.has(unlock_flag):
		queue_free()
		return
	add_to_group("probe")
	_base_modulate = modulate


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	var dmg := 1.0 - float(hp) / float(MAX_HP)
	_body.color = Color(0.5, 0.42, 0.2).lerp(Color(0.7, 0.3, 0.2), dmg)
	if hp <= 0:
		_destroy()


func set_targeted(on: bool) -> void:
	modulate = _base_modulate * 1.6 if on else _base_modulate


func _show_damage(amount: int) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(number)
	number.global_position = global_position + Vector2(-30, -34)
	number.setup(amount)


func _destroy() -> void:
	_dead = true
	EventBus.say("Hold on... that's %s. The real one — NASA, 1977, not the TV starship. Still bleeping out here after all these centuries. Touching. Now strip it for parts." % probe_name)
	var blueprint := BLUEPRINT_SCENE.instantiate()
	blueprint.unlock_flag = unlock_flag
	blueprint.unlock_title = unlock_title
	get_parent().add_child(blueprint)
	blueprint.global_position = global_position

	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()
