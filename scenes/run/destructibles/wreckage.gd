extends StaticBody2D
## Destructible wreckage debris. Tougher than an asteroid (16 HP) and always
## drops Metal. Solid (the ship collides, lasers are absorbed). Modular — drop
## clusters of these into any biome scene. HP and metal drop amount are set
## per scene via exports, so wreckage_small.tscn can reuse this script with
## smaller values.

const LOOT_SCENE := preload("res://scenes/run/collectibles/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@export var max_hp:      int = 16
@export var drop_amount: int = 2

@onready var _body: Sprite2D = $Body
@onready var _particles: CPUParticles2D = $Particles

var hp: int = 0
var _base_modulate := Color.WHITE
var _dead := false


func _ready() -> void:
	hp = max_hp
	add_to_group("wreckage")
	rotation = randf() * TAU
	_base_modulate = modulate


## Brighten while the ship is aiming at it (highlight = shootable).
func set_targeted(on: bool) -> void:
	modulate = _base_modulate * 1.6 if on else _base_modulate


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	var dmg := 1.0 - float(hp) / float(max_hp)
	_body.modulate = Color(0.38, 0.4, 0.46).lerp(Color(0.6, 0.3, 0.2), dmg)
	if hp <= 0:
		_destroy()


func _show_damage(amount: int) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(number)
	number.global_position = global_position + Vector2(-30, -28)
	number.setup(amount)


func _destroy() -> void:
	_dead = true
	var loot := LOOT_SCENE.instantiate()
	loot.item_type = Items.Type.METAL
	loot.amount = drop_amount
	get_parent().add_child(loot)
	loot.global_position = global_position

	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()
