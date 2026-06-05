extends CanvasLayer
## Research Lab (unlocked by salvaging Voyager 1). Placeholder for now — research
## projects will live here later.

@onready var _root: Control = $Root
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton


func _ready() -> void:
	_close_button.pressed.connect(close)
	close()


func open() -> void:
	_root.visible = true


func close() -> void:
	_root.visible = false
