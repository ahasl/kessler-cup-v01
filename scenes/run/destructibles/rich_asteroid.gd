extends StaticBody2D
## Metal-rich asteroid: tougher (25 HP), darker, drops Reinforced Alloy (the
## day-5 quest material) plus some Metal. Only appears from APPEAR_DAY onward.

const MAX_HP := 25
const APPEAR_DAY := 5
const METAL_BONUS := 3

const LOOT_SCENE := preload("res://scenes/run/collectibles/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _body: Sprite2D = $Body
@onready var _particles: CPUParticles2D = $Particles

var hp: int = MAX_HP
var _base_modulate := Color.WHITE
var _dead := false


func _ready() -> void:
	# Only present once the day-5 quest is in play.
	if GameManager.day < APPEAR_DAY:
		queue_free()
		return
	add_to_group("asteroids")
	rotation = randf() * TAU
	_base_modulate = modulate


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	var dmg := 1.0 - float(hp) / float(MAX_HP)
	_body.modulate = Color(1.0, 0.75, 0.45).lerp(Color(1.0, 0.3, 0.3), dmg)
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
	_spawn_loot(Items.Type.REINFORCED_ALLOY, 1, Vector2(0, -8))
	_spawn_loot(Items.Type.METAL, METAL_BONUS, Vector2(18, 14))

	_particles.reparent(get_parent())
	_particles.emitting = true
	_particles.finished.connect(_particles.queue_free)
	queue_free()


func _spawn_loot(item_type: int, amount: int, offset: Vector2) -> void:
	var loot := LOOT_SCENE.instantiate()
	loot.item_type = item_type
	loot.amount = amount
	get_parent().add_child(loot)
	loot.global_position = global_position + offset
