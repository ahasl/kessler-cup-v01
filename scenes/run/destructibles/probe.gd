extends Area2D
## A quest probe (Voyager 1). Floats in space until interacted with — press
## [E] in range (same pickup-sensor pattern as a container) to salvage it.
## Drops a blueprint that has to be flown back to the station to actually
## commit the unlock. Only exists while its `unlock_flag` is NOT yet
## unlocked; once collected & saved it never reappears. Modular: set the
## flag/title and drop one into a biome.

@export var unlock_flag: String = "research_station"
@export var unlock_title: String = "Research Station"
@export var probe_name: String = "Voyager 1"  # a real probe, for flavour

const BLUEPRINT_SCENE := preload("res://scenes/run/collectibles/blueprint.tscn")

@onready var _prompt: Label = $Prompt

var _collected := false


func _ready() -> void:
	# Already unlocked? Then this probe is done — don't appear at all.
	if ProgressManager.has(unlock_flag):
		queue_free()
		return
	add_to_group("probe")


func set_prompt(on: bool) -> void:
	_prompt.visible = on


func open() -> void:
	if _collected:
		return
	_collected = true
	EventBus.say("Hold on... that's %s. The real one — NASA, 1977, not the TV starship. Still bleeping out here after all these centuries. Touching. Now strip it for parts." % probe_name)
	var blueprint := BLUEPRINT_SCENE.instantiate()
	blueprint.unlock_flag = unlock_flag
	blueprint.unlock_title = unlock_title
	get_parent().add_child(blueprint)
	blueprint.global_position = global_position
	queue_free()
