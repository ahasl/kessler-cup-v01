extends Area2D
## A collectable blueprint. Flying over it sets a progression flag (e.g. unlocks
## a station buildable). The unlock is in-memory immediately and made permanent
## when the player next sleeps (saves). Self-contained / modular.

@export var unlock_flag: String = "research_station"
@export var unlock_title: String = "Research Station"

var _pulse := 0.0


func _ready() -> void:
	add_to_group("blueprint")


func collect() -> void:
	ProgressManager.collect_pending(unlock_flag, unlock_title)
	EventBus.say("Blueprint's in the hold. Get it home in one piece or it's just expensive litter. (Unlocks: %s)" % unlock_title)
	queue_free()


func _process(delta: float) -> void:
	_pulse += delta * 3.0
	rotation = _pulse * 0.4
	var s := 1.0 + 0.12 * sin(_pulse * 2.0)
	scale = Vector2(s, s)
