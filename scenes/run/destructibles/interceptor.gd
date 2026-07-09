extends CharacterBody2D
## Third enemy: a fast, fragile dasher. Sits still until the player gets close,
## then charges in short, fast bursts instead of a steady chase — hits harder
## per touch than a drone but dies in one or two shots. Always drops a Data
## Fragment. Self-contained / modular — drop instances into any biome scene.

const MAX_HP        := 2
const DASH_SPEED    := 260.0
const DASH_TIME     := 0.35
const RECOVER_TIME  := 0.55
const CONTACT_FUEL  := 16.0
const DETECT_RADIUS := 380.0
const ALERT_OFFSET  := Vector2(-6, -40)

const LOOT_SCENE          := preload("res://scenes/run/collectibles/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _hitbox:   Area2D = $Hitbox
@onready var _name_tag: Label  = $NameTag

var hp:             int    = MAX_HP
var _player:        Node2D = null
var _activated:     bool   = false
var _base_modulate: Color  = Color.WHITE
var _dead:          bool   = false
var _alert:         Label  = null
var _dash_dir:      Vector2 = Vector2.ZERO
var _state_timer:   float  = 0.0
var _dashing:       bool   = false


func _ready() -> void:
	add_to_group("enemy")
	_hitbox.body_entered.connect(_on_body_entered)
	_base_modulate = modulate
	_alert = Label.new()
	_alert.text = "!"
	_alert.add_theme_color_override("font_color", Color(1.0, 0.35, 0.3, 1.0))
	_alert.add_theme_font_size_override("font_size", 18)
	_alert.visible = false
	# Sibling, not child — see drone.gd for why (rotation/orbiting).
	get_parent().add_child.call_deferred(_alert)


func set_targeted(on: bool) -> void:
	modulate = _base_modulate * 1.3 if on else _base_modulate
	_name_tag.visible = on


func _physics_process(delta: float) -> void:
	_name_tag.global_position = global_position
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

	_alert.global_position = global_position + ALERT_OFFSET
	_alert.modulate.a = 0.65 + 0.35 * sin(Time.get_ticks_msec() * 0.012)

	_state_timer -= delta
	if _dashing:
		velocity = _dash_dir * DASH_SPEED
		if _state_timer <= 0.0:
			_dashing = false
			_state_timer = RECOVER_TIME
			velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DASH_SPEED * 2.0 * delta)
		if to.length() > 1.0:
			look_at(_player.global_position)
		if _state_timer <= 0.0:
			_dashing = true
			_dash_dir = to.normalized()
			_state_timer = DASH_TIME
	move_and_slide()


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_show_damage(amount)
	if hp <= 0:
		_die()


func _show_damage(amount: int) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(number)
	number.global_position = global_position + Vector2(-30, -24)
	number.setup(amount)


func _die() -> void:
	_dead = true
	_alert.queue_free()
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
		_alert.queue_free()
		if body.has_method("environment_drain"):
			body.environment_drain(CONTACT_FUEL)
		queue_free()
