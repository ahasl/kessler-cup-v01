extends Control
## Transition screen shown between the station and space. Reads the target scene
## from GameManager, holds briefly, then switches. Keeps the loop from feeling
## like an instant teleport.

const HOLD_TIME := 0.8

@onready var _title: Label = $Center/VBox/Title
@onready var _dots: Label = $Center/VBox/Dots

var _t := 0.0


func _ready() -> void:
	var target := GameManager.consume_next_scene()
	if "space" in target:
		_title.text = "LAUNCHING EXPEDITION"
	elif "station" in target:
		_title.text = "RETURNING TO STATION"
	else:
		_title.text = "LOADING"

	await get_tree().create_timer(HOLD_TIME).timeout
	if target == "":
		target = GameManager.MAIN_MENU_SCENE
	get_tree().change_scene_to_file(target)


func _process(delta: float) -> void:
	_t += delta
	_dots.text = ".".repeat(1 + (int(_t * 3.0) % 3))
