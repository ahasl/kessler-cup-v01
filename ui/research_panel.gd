extends CanvasLayer
## Research Lab (unlocked by salvaging Voyager 1). Placeholder for now — research
## projects will live here later.

@onready var _root: Control = $Root
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton


func _ready() -> void:
	_close_button.pressed.connect(close)
	close()


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and event.is_action_pressed("ui_cancel"):
		close()


func open() -> void:
	_root.visible = true
	EventBus.overlay_opened.emit()


func close() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()
