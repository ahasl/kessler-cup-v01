extends StaticBody2D
## A glowing crystal/energy node: a rich, destructible material source.
## Modular — plasma_vent.tscn reuses this script with a different shape,
## item_type and flash_color.

const LOOT_SCENE := preload("res://scenes/run/collectibles/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@export var max_hp:      int = 12
@export var drop_amount: int = 4
@export var item_type:   Items.Type = Items.Type.CRYSTAL
@export var flash_color: Color = Color(0.30, 0.85, 1.0)

@onready var _body: Polygon2D = $Body
@onready var _particles: CPUParticles2D = $Particles
@onready var _name_tag: Label = $NameTag

var hp: int = 0
var _base_modulate := Color.WHITE
var _dead := false


func _ready() -> void:
	hp = max_hp
	add_to_group("asteroids")
	_base_modulate = modulate
	_name_tag.global_position = global_position


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	var dmg := 1.0 - float(hp) / float(max_hp)
	_body.color = flash_color.lerp(Color(0.9, 0.95, 1.0), dmg)
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
	loot.item_type = item_type
	loot.amount = drop_amount
	get_parent().add_child(loot)
	loot.global_position = global_position

	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()
