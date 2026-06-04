extends Node
## Occasionally sends a decorative comet streaking across the player's view.
## Drop one into the space scene; it works for any biome.

const MIN_INTERVAL := 6.0
const MAX_INTERVAL := 14.0
const SPAWN_DISTANCE := 1000.0

const COMET_SCENE := preload("res://scenes/run/comet.tscn")

var _timer := 0.0


func _ready() -> void:
	_timer = randf_range(MIN_INTERVAL, MAX_INTERVAL)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = randf_range(MIN_INTERVAL, MAX_INTERVAL)
		_spawn()


func _spawn() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	# Start off-screen around the player, head roughly across the view.
	var angle := randf() * TAU
	var origin: Vector2 = player.global_position + Vector2.from_angle(angle) * SPAWN_DISTANCE
	var dir := (player.global_position - origin).normalized().rotated(randf_range(-0.5, 0.5))
	var comet := COMET_SCENE.instantiate()
	get_parent().add_child(comet)
	comet.global_position = origin
	comet.setup(dir)
