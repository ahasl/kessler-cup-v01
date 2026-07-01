extends CharacterBody2D
## Run-domain player ship. All stats (speed, fuel, weapon, dodge) come from the
## Upgrade domain, so upgrades drive behaviour without hard-coded values here.

const ACCELERATION := 1600.0   # snappy response
const BRAKE := 1400.0          # quick stop when you let go
const FUEL_DRAIN_PER_SEC := 7.0
const SHIP_NOSE := 20.0
const FIRE_COOLDOWN := 0.5
const LOW_FUEL_RATIO := 0.30

const LASER_SCENE := preload("res://scenes/run/laser.tscn")

@onready var _pickup_sensor: Area2D = $PickupSensor
@onready var _aim_ray: RayCast2D = $AimRay

var max_fuel: float = 100.0
var fuel: float = 100.0
var max_speed: float = 360.0
var can_control: bool = true

var _dock_zone: Area2D = null
var _container_zone: Area2D = null
var _recall_zone: Area2D = null
var _fire_timer: float = 0.0
var _low_fuel_warned: bool = false
var _target: Node = null


func _ready() -> void:
	add_to_group("player")
	max_fuel = UpgradeManager.get_max_fuel()
	fuel = max_fuel
	max_speed = UpgradeManager.get_ship_speed()
	_aim_ray.target_position = Vector2(UpgradeManager.get_laser_range(), 0)
	_pickup_sensor.area_entered.connect(_on_sensor_area_entered)
	_pickup_sensor.area_exited.connect(_on_sensor_area_exited)
	EventBus.overlay_opened.connect(func(): can_control = false)
	EventBus.overlay_closed.connect(func(): can_control = fuel > 0.0)
	EventBus.fuel_changed.emit(fuel, max_fuel)


func _physics_process(delta: float) -> void:
	if can_control:
		var aim := get_global_mouse_position()
		if not global_position.is_equal_approx(aim):
			look_at(aim)

	var input := Vector2.ZERO
	if can_control:
		input = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		)

	var target := Vector2.ZERO
	var rate := BRAKE
	if input != Vector2.ZERO and fuel > 0.0:
		target = input.normalized() * max_speed
		rate = ACCELERATION
		_consume_fuel(FUEL_DRAIN_PER_SEC * delta)

	velocity = velocity.move_toward(target, rate * delta)
	move_and_slide()

	_handle_actions(delta)
	_update_target()


# Highlights the destructible the ship is aiming at (not the planet).
func _update_target() -> void:
	var hit: Object = null
	if can_control:
		_aim_ray.force_raycast_update()
		hit = _aim_ray.get_collider()
	var new_target: Node = hit if (hit != null and hit.has_method("set_targeted")) else null
	if new_target == _target:
		return
	if _target != null and is_instance_valid(_target):
		_target.set_targeted(false)
	_target = new_target
	if _target != null:
		_target.set_targeted(true)


# Polled from the input state so the HUD can never swallow these.
func _handle_actions(delta: float) -> void:
	_fire_timer -= delta
	if not can_control:
		return
	if Input.is_action_pressed("shoot") and _fire_timer <= 0.0:
		_fire_weapon()
		_fire_timer = FIRE_COOLDOWN
	if Input.is_action_just_pressed("interact"):
		if _dock_zone != null:
			EventBus.player_docked.emit()
		elif _container_zone != null:
			_container_zone.open()
			_container_zone = null
		elif _recall_zone != null:
			_recall_zone.activate(self)
			_recall_zone = null


## Passive fuel loss from a hostile environment (e.g. an un-shielded biome) or
## an enemy touching the ship.
func environment_drain(amount: float) -> void:
	if can_control:
		_consume_fuel(amount)


## Instantly tops the tank back up (fuel cell pickup).
func refill_fuel() -> void:
	fuel = max_fuel
	_low_fuel_warned = false
	EventBus.fuel_changed.emit(fuel, max_fuel)


func _consume_fuel(amount: float) -> void:
	fuel = max(fuel - amount, 0.0)
	EventBus.fuel_changed.emit(fuel, max_fuel)
	if not _low_fuel_warned and fuel <= max_fuel * LOW_FUEL_RATIO and fuel > 0.0:
		_low_fuel_warned = true
		EventBus.say_id("low_fuel", "warning")
	if fuel <= 0.0:
		can_control = false
		EventBus.player_died.emit()


func _fire_weapon() -> void:
	var dir := Vector2.RIGHT.rotated(rotation)
	var laser := LASER_SCENE.instantiate()
	get_parent().add_child(laser)
	laser.global_position = global_position + dir * SHIP_NOSE
	laser.rotation = rotation
	laser.setup(dir, UpgradeManager.get_laser_range(), UpgradeManager.get_laser_damage())


func _on_sensor_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.collect()
	elif area.is_in_group("blueprint"):
		area.collect()
	elif area.is_in_group("fuel_cell"):
		refill_fuel()
		area.collect()
		if randf() < 0.34:  # don't comment on every single pickup
			EventBus.say_id("fuel_cell")
	elif area.is_in_group("docking"):
		_dock_zone = area
		if area.has_method("set_prompt"):
			area.set_prompt(true)
	elif area.is_in_group("container"):
		_container_zone = area
		area.set_prompt(true)
	elif area.is_in_group("recall_beacon"):
		_recall_zone = area
		area.set_prompt(true)


func _on_sensor_area_exited(area: Area2D) -> void:
	if area == _dock_zone:
		if area.has_method("set_prompt"):
			area.set_prompt(false)
		_dock_zone = null
	elif area == _container_zone:
		area.set_prompt(false)
		_container_zone = null
	elif area == _recall_zone:
		area.set_prompt(false)
		_recall_zone = null
