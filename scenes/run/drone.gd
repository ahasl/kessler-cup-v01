extends CharacterBody2D
## First enemy: a small drone. Slowly chases the player and drains fuel on
## contact (no weapons). 5 HP; smokes below half. Always drops a Data Fragment.
## Self-contained / modular — drop instances into any biome scene.

const MAX_HP       := 3
const SPEED        := 110.0
const CONTACT_FUEL := 10.0    # fuel drained when it rams the ship
const DETECT_RADIUS := 420.0  # stays dormant until the ship comes this close

const LOOT_SCENE          := preload("res://scenes/run/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _smoke:  CPUParticles2D = $Smoke
@onready var _hitbox: Area2D         = $Hitbox

var hp:             int    = MAX_HP
var _player:        Node2D = null
var _activated:     bool   = false
var _base_modulate: Color  = Color.WHITE
var _dead:          bool   = false
var _alert:         Label  = null


func _ready() -> void:
	add_to_group("enemy")
	_hitbox.body_entered.connect(_on_body_entered)
	_base_modulate = modulate
	_alert = Label.new()
	_alert.text = "!"
	_alert.add_theme_color_override("font_color", Color(1.0, 0.28, 0.18, 1.0))
	_alert.add_theme_font_size_override("font_size", 18)
	_alert.position = Vector2(-6, -52)
	_alert.visible = false
	add_child(_alert)


func set_targeted(on: bool) -> void:
	modulate = _base_modulate * 1.6 if on else _base_modulate


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		if _player == null:
			return

	var to := _player.global_position - global_position
	if not _activated:
		if to.length() <= DETECT_RADIUS:
			_activated = true
			_alert.visible = true
		else:
			return

	# Pulse the alert while active.
	_alert.modulate.a = 0.65 + 0.35 * sin(Time.get_ticks_msec() * 0.008)

	if to.length() > 1.0:
		look_at(_player.global_position)
		velocity = to.normalized() * SPEED
	move_and_slide()


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	if hp <= MAX_HP / 2.0:
		_smoke.emitting = true
	if hp <= 0:
		_die()


func _show_damage(amount: int) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(number)
	number.global_position = global_position + Vector2(-30, -26)
	number.setup(amount)


func _die() -> void:
	_dead = true
	var loot := LOOT_SCENE.instantiate()
	loot.item_type = Items.Type.DATACHIP
	get_parent().add_child(loot)
	loot.global_position = global_position
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _dead:
		return
	if body.is_in_group("player"):
		_dead = true
		if body.has_method("environment_drain"):
			body.environment_drain(CONTACT_FUEL)
		queue_free()
