class_name Interactable
extends Area2D
## Station-domain interaction component. Reusable across props (bed / terminal /
## door). Emits `triggered` when activated; the station scene decides meaning.
## A child node named "Prompt" (Label) configures the action text; at runtime
## this is replaced by a styled InteractPrompt that reads the key from InputMap.

signal triggered

@export var kind: String = ""

@onready var _prompt: Node = get_node_or_null("Prompt")

var _styled: InteractPrompt = null


func _ready() -> void:
	add_to_group("interactable")
	if _prompt:
		_prompt.visible = false
		_styled = _build_prompt()


func _build_prompt() -> InteractPrompt:
	# Read label text from the existing Label, strip legacy "[E] " prefix.
	var text := ""
	if _prompt is Label:
		text = (_prompt as Label).text
		text = text.trim_prefix("[E] ").strip_edges()

	# Vertical position: re-use the old Label's offset_top if available.
	var y := -38.0
	if _prompt is Control:
		y = (_prompt as Control).offset_top

	var p := InteractPrompt.new()
	p.label         = text
	p.position      = Vector2(-10.0, y)
	p.visible       = false
	p.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	add_child(p)
	return p


func interact() -> void:
	triggered.emit()


func set_highlight(on: bool) -> void:
	if _styled:
		_styled.visible = on
	elif _prompt:
		_prompt.visible = on
