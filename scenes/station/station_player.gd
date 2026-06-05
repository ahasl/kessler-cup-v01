extends CharacterBody2D

const SPEED := 100

@onready var _reach: Area2D = $Reach
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _nearby: Array[Interactable] = []
var _current: Interactable = null

var _last_direction := "down"


func _ready() -> void:
	add_to_group("station_player")
	_reach.area_entered.connect(_on_reach_entered)
	_reach.area_exited.connect(_on_reach_exited)


func _physics_process(_delta: float) -> void:
	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	velocity = input.normalized() * SPEED
	move_and_slide()

	var prev_dir := _last_direction
	_update_animation(input)
	if _last_direction != prev_dir:
		_update_current()


func _update_animation(input: Vector2) -> void:
	if input.length() > 0:
		# Bewegungsrichtung bestimmen
		if abs(input.x) > abs(input.y):
			if input.x > 0:
				_last_direction = "right"
			else:
				_last_direction = "left"
		else:
			if input.y > 0:
				_last_direction = "down"
			else:
				_last_direction = "top"

		_sprite.play("walk_" + _last_direction)
	else:
		_sprite.play("idle_" + _last_direction)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _current != null:
		_current.interact()


func _on_reach_entered(area: Area2D) -> void:
	if area is Interactable:
		_nearby.append(area as Interactable)
		_update_current()


func _on_reach_exited(area: Area2D) -> void:
	if area is Interactable:
		_nearby.erase(area as Interactable)
		_update_current()


func _facing_vector() -> Vector2:
	match _last_direction:
		"right": return Vector2.RIGHT
		"left":  return Vector2.LEFT
		"top":   return Vector2.UP
		_:       return Vector2.DOWN


func _update_current() -> void:
	if _current != null:
		_current.set_highlight(false)

	var facing := _facing_vector()
	var best: Interactable = null
	var best_dot := 0.0  # must be in front (dot > 0)

	for item in _nearby:
		var dot := (item.global_position - global_position).normalized().dot(facing)
		if dot > best_dot:
			best_dot = dot
			best = item

	_current = best
	if _current != null:
		_current.set_highlight(true)
