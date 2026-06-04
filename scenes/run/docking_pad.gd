extends Area2D
## Run-domain home-station entrance. The PlayerShip's sensor detects this
## (group "docking"); the player presses E inside it to extract. Pulses gently
## and shows an "[E] dock" prompt while the ship is in range.

@onready var _ring: Line2D = $Ring
@onready var _prompt: Label = $Prompt

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	var pulse := 0.4 + 0.4 * sin(_t * 2.0)
	_ring.modulate = Color(1, 1, 1, pulse)


func set_prompt(on: bool) -> void:
	_prompt.visible = on
