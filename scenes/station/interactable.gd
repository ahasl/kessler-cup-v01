class_name Interactable
extends Area2D
## Station-domain interaction component. Reusable across props (bed / terminal /
## door). Emits `triggered` when activated; the station scene decides meaning.
## A child node named "Prompt" (if present) is shown while the player is in range.

signal triggered

@export var kind: String = ""

@onready var _prompt: Node = get_node_or_null("Prompt")


func _ready() -> void:
	add_to_group("interactable")
	if _prompt:
		_prompt.visible = false


func interact() -> void:
	triggered.emit()


func set_highlight(on: bool) -> void:
	if _prompt:
		_prompt.visible = on
