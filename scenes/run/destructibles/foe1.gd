extends CharacterBody2D
## Second enemy: a gunner. Drifts/patrols the map on its own, and once it
## spots the player it doesn't rush in — it orbits at range, strafing while
## it shoots. Hits hard (20 dmg/shot) and has more HP than a drone (25). Always
## drops Data Fragments. Self-contained / modular — drop instances into any
## biome scene.

const MAX_HP        := 25
const PATROL_SPEED  := 55.0
const ORBIT_SPEED   := 70.0
const DETECT_RADIUS := 480.0
const FIRE_RANGE    := 480.0
const PREFERRED_DIST := 330.0   # orbits at roughly this distance while fighting
const FIRE_COOLDOWN := 1.6
const FIRE_DAMAGE   := 20
const ALERT_OFFSET  := Vector2(-6, -54)

const LASER_SCENE         := preload("res://scenes/run/laser_enemy.tscn")
const LOOT_SCENE          := preload("res://scenes/run/collectibles/loot.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/run/damage_number.tscn")

@onready var _hitbox:   Area2D         = $Hitbox
@onready var _smoke:    CPUParticles2D = $Smoke
@onready var _name_tag: Label          = $NameTag

var hp:             int    = MAX_HP
var _player:        Node2D = null
var _activated:     bool   = false
var _base_modulate: Color  = Color.WHITE
var _dead:          bool   = false
var _alert:         Label  = null
var _fire_timer:    float  = 0.0
var _orbit_dir:     float  = 1.0
var _patrol_dir:    Vector2 = Vector2.RIGHT
var _patrol_timer:  float  = 0.0


func _ready() -> void:
	add_to_group("enemy")
	_hitbox.body_entered.connect(_on_body_entered)
	_base_modulate = modulate
	_orbit_dir = 1.0 if randf() < 0.5 else -1.0
	_pick_new_patrol_dir()
	_alert = Label.new()
	_alert.text = "!"
	_alert.add_theme_color_override("font_color", Color(1.0, 0.6, 0.15, 1.0))
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
			_patrol(delta)
			return

	_alert.global_position = global_position + ALERT_OFFSET
	_alert.modulate.a = 0.65 + 0.35 * sin(Time.get_ticks_msec() * 0.008)

	var dist := to.length()
	if dist > 1.0:
		look_at(_player.global_position)

	# Strafes around the player at roughly PREFERRED_DIST instead of parking —
	# a radial component to hold distance, a tangential one to keep circling.
	var radial: Vector2 = to.normalized()
	var tangent := Vector2(-radial.y, radial.x) * _orbit_dir
	var dist_error := clampf((dist - PREFERRED_DIST) / PREFERRED_DIST, -1.0, 1.0)
	var desired := radial * dist_error * ORBIT_SPEED + tangent * ORBIT_SPEED
	velocity = velocity.move_toward(desired, ORBIT_SPEED * 3.0 * delta)
	move_and_slide()

	_fire_timer -= delta
	if dist <= FIRE_RANGE and _fire_timer <= 0.0:
		_fire()
		_fire_timer = FIRE_COOLDOWN


# Dormant wandering — picks a new drift direction every couple of seconds so
# it's actually flying around the map, not parked waiting for the player.
func _patrol(delta: float) -> void:
	_patrol_timer -= delta
	if _patrol_timer <= 0.0:
		_pick_new_patrol_dir()
	velocity = velocity.move_toward(_patrol_dir * PATROL_SPEED, PATROL_SPEED * delta)
	move_and_slide()
	rotation = lerp_angle(rotation, _patrol_dir.angle(), delta * 2.0)


func _pick_new_patrol_dir() -> void:
	_patrol_dir = Vector2.from_angle(randf() * TAU)
	_patrol_timer = randf_range(2.5, 5.0)


func _fire() -> void:
	var dir := Vector2.RIGHT.rotated(rotation)
	var laser := LASER_SCENE.instantiate()
	get_parent().add_child(laser)
	laser.global_position = global_position + dir * 18.0
	laser.rotation = rotation
	laser.setup(dir, FIRE_RANGE, FIRE_DAMAGE)


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
	number.global_position = global_position + Vector2(-30, -28)
	number.setup(amount)


func _die() -> void:
	_dead = true
	_alert.queue_free()
	var loot := LOOT_SCENE.instantiate()
	loot.item_type = Items.Type.DATACHIP
	loot.amount = 2
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
			body.environment_drain(FIRE_DAMAGE * 0.5)  # a lighter ram penalty — its real threat is the gun
		queue_free()
