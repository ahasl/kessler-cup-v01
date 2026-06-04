extends CharacterBody2D
## Station-domain avatar. A top-down walker that roams the hub and activates
## the nearest Interactable with the interact action. No fuel, no combat —
## deliberately separate from the run-domain player ship.

const SPEED := 240.0

@onready var _reach: Area2D = $Reach

var _nearby: Array[Interactable] = []
var _current: Interactable = null


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


func _update_current() -> void:
	if _current != null:
		_current.set_highlight(false)
	_current = _nearby.back() if not _nearby.is_empty() else null
	if _current != null:
		_current.set_highlight(true)
