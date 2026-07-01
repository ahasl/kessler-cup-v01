extends Area2D
## Recall Beacon: a rare container drop. Press [E] in range to instantly warp
## the ship back to the home station's dock — no travel, no fuel spent. Skips
## a long trip home when stranded, at the cost of whatever loot is still out
## there uncollected. Self-contained / modular — drop instances (or spawn from
## a container) into any biome scene.

const LANDING_OFFSET := Vector2(0, 220)  # matches the ship's home spawn point

@onready var _prompt: Label   = $Prompt
@onready var _ring:   Line2D  = $Ring

var _pulse := 0.0


func _ready() -> void:
	add_to_group("recall_beacon")


func _process(delta: float) -> void:
	_pulse += delta * 3.0
	var s := 1.0 + 0.1 * sin(_pulse)
	scale = Vector2(s, s)
	# Only the ring spins — the prompt is a child too and must stay readable.
	_ring.rotation += delta * 0.8


func set_prompt(on: bool) -> void:
	_prompt.visible = on


func activate(player: Node2D) -> void:
	var dock := get_tree().get_first_node_in_group("docking")
	if dock != null:
		player.global_position = dock.global_position + LANDING_OFFSET
		player.velocity = Vector2.ZERO
	EventBus.say_id("recall_beacon")
	queue_free()
