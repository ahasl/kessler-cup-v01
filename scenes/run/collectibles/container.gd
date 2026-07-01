extends Area2D
## Space container: floats until the ship is nearby, then opens with [E].
## Opening spawns one of DROP_SCENES and removes the container. Currently only
## drops a Fuel Cell — add more scenes to DROP_SCENES for variety later, no
## other code needs to change. Self-contained / modular — drop instances into
## any biome scene like any other pickup.

const DROP_SCENES: Array[PackedScene] = [
	preload("res://scenes/run/collectibles/fuel_cell.tscn"),
]

@onready var _prompt: Label = $Prompt


func _ready() -> void:
	add_to_group("container")


func set_prompt(on: bool) -> void:
	_prompt.visible = on


func open() -> void:
	var drop := DROP_SCENES[randi() % DROP_SCENES.size()].instantiate()
	get_parent().add_child(drop)
	drop.global_position = global_position
	queue_free()
