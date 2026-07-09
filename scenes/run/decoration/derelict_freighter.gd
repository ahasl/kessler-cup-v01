extends Area2D
## Pure-flavor discovery landmark: a huge, ancient wreck with no gameplay
## effect. Fires one AnI line the first time the player gets close, then goes
## quiet — a reward for flying out to the map's edges instead of a mechanic.
## Modular — drop into any biome, far from the busy centre.

@export_multiline var flavor_line: String = "Whatever this was, it's been out here a long time. Bigger than anything we fly now."

var _triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if body.is_in_group("player"):
		_triggered = true
		EventBus.say(flavor_line, "info")
