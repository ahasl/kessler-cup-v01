extends Node2D
## Run-domain root scene (SPACE). The map is composed of Biome scenes placed
## side by side (see scenes/run/biomes/). This script discovers them via the
## "biome" group and applies their rules generically — entering messages, the
## alloy fuel penalty, and the lethal edge of charted space. Adding a biome is
## pure content: build a Biome scene and drop it into space.tscn.

const DEATH_MARGIN := 280.0  # how far past the (hidden) charted edge you may stray

@onready var _player: CharacterBody2D = $PlayerShip

var _biomes: Array = []
var _current: Biome = null
var _edge_warned := false
var _ended := false


func _ready() -> void:
	_biomes = get_tree().get_nodes_in_group("biome")


func _physics_process(delta: float) -> void:
	if _ended or _player == null:
		return
	var pos := _player.global_position
	_update_biome(pos, delta)
	_update_edge(pos)


func _update_biome(pos: Vector2, delta: float) -> void:
	var biome := _biome_at(pos)
	if biome != _current:
		_current = biome
		if biome != null:
			var unshielded := biome.requires_alloy and not UpgradeManager.has_metal_alloy()
			var line := biome.blocked_message if unshielded else biome.enter_message
			if line != "":
				EventBus.say(line, "warning" if unshielded else "info")

	if _current != null and _current.requires_alloy and not UpgradeManager.has_metal_alloy():
		_player.environment_drain(_current.penalty_drain * delta)


func _biome_at(pos: Vector2) -> Biome:
	for b in _biomes:
		if b.contains(pos):
			return b
	return null


func _update_edge(pos: Vector2) -> void:
	var d_out := _distance_outside(pos)
	var level := 0.0
	if d_out > 0.0:
		# Strong red immediately on leaving, ramping to full at the death line.
		level = maxf(0.5, clampf(d_out / DEATH_MARGIN, 0.0, 1.0))
		if not _edge_warned:
			_edge_warned = true
			EventBus.say_id("edge", "warning")
		if d_out > DEATH_MARGIN:
			_ended = true
			EventBus.player_died.emit(_player.run_time, _player.max_distance)
	else:
		_edge_warned = false
	EventBus.edge_danger.emit(level)


## 0.0 while inside any biome; otherwise the distance to the nearest biome edge.
func _distance_outside(pos: Vector2) -> float:
	var best := INF
	for b in _biomes:
		var r: Rect2 = b.world_rect()
		if r.has_point(pos):
			return 0.0
		var cx := clampf(pos.x, r.position.x, r.end.x)
		var cy := clampf(pos.y, r.position.y, r.end.y)
		best = minf(best, pos.distance_to(Vector2(cx, cy)))
	return best
