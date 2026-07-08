extends StaticBody2D
## A glowing crystal geode: a rich, destructible Crystal source. Modular.

const MAX_HP := 12
const CRYSTAL_DROP := 4

const LOOT_SCENE := preload("res://scenes/run/collectibles/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _body: Polygon2D = $Body
@onready var _particles: CPUParticles2D = $Particles
@onready var _name_tag: Label = $NameTag

var hp: int = MAX_HP
var _base_modulate := Color.WHITE
var _dead := false


func _ready() -> void:
	add_to_group("asteroids")
	_base_modulate = modulate
	_name_tag.global_position = global_position


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	var dmg := 1.0 - float(hp) / float(MAX_HP)
	_body.color = Color(0.30, 0.85, 1.0).lerp(Color(0.9, 0.95, 1.0), dmg)
	if hp <= 0:
		_destroy()


func set_targeted(on: bool) -> void:
	modulate = _base_modulate * 1.3 if on else _base_modulate
	_name_tag.visible = on


func _show_damage(amount: int) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(number)
	number.global_position = global_position + Vector2(-30, -34)
	number.setup(amount)


func _destroy() -> void:
	_dead = true
	var loot := LOOT_SCENE.instantiate()
	loot.item_type = Items.Type.CRYSTAL
	loot.amount = CRYSTAL_DROP
	get_parent().add_child(loot)
	loot.global_position = global_position

	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()
