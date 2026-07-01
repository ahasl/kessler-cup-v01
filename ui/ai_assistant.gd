extends CanvasLayer
## AnI — the station AI assistant. A holographic portrait (top-right) plus a
## message banner (bottom centre, above the inventory). The whole assistant is
## hidden until she speaks, then fades out again. Shared HUD used in both the
## station and space scenes; driven entirely by EventBus.ai_message.
## `sticky` messages (e.g. quest updates) don't auto-hide — they show an
## "Understood" button and wait for the player to dismiss them.

const MIN_SHOW_TIME := 3.5
const MAX_SHOW_TIME := 10.0
const SECONDS_PER_CHAR := 0.05

@onready var _portrait: Node2D = $Portrait
@onready var _name_label: Label = $Name
@onready var _role_label: Label = $Role
@onready var _msg_box: Control = $Message
@onready var _msg_label: Label = $Message/Panel/Margin/VBox/Label
@onready var _understood_btn: Button = $Message/Panel/Margin/VBox/UnderstoodButton

var _timer := 0.0
var _sticky := false


func _ready() -> void:
	EventBus.ai_message.connect(_on_message)
	_understood_btn.pressed.connect(_dismiss)
	_set_visible(false)
	# Pick up a message emitted during the scene change that brought us here
	# (e.g. docking or being rescued), then consume it so it won't reappear.
	if not EventBus.pending_message.is_empty():
		var p := EventBus.pending_message
		_display(p.get("text", ""), p.get("level", "info"), p.get("sticky", false))
		EventBus.pending_message = {}


# Live signal handler. Must NOT clear pending_message — a message emitted right
# before a scene change has to survive for the next scene's AnI to display it.
func _on_message(text: String, level: String, sticky: bool) -> void:
	_display(text, level, sticky)


func _display(text: String, level: String, sticky: bool) -> void:
	_msg_label.text = "AnI  ▸  " + text
	var col := Color(0.55, 1.0, 0.9)
	if level == "warning":
		col = Color(1.0, 0.6, 0.3)
	_msg_label.add_theme_color_override("font_color", col)
	_set_visible(true)
	var was_sticky := _sticky
	_sticky = sticky
	_understood_btn.visible = sticky
	# Long lines stay up longer so they're actually readable. Sticky messages
	# don't time out at all — the player has to dismiss them, and can't move
	# in the meantime (same overlay-lock other panels use).
	_timer = 0.0 if sticky else clampf(MIN_SHOW_TIME + text.length() * SECONDS_PER_CHAR, MIN_SHOW_TIME, MAX_SHOW_TIME)
	if sticky and not was_sticky:
		EventBus.overlay_opened.emit()


func _dismiss() -> void:
	_sticky = false
	_timer = 0.0
	_set_visible(false)
	EventBus.overlay_closed.emit()


func _set_visible(on: bool) -> void:
	_portrait.visible = on
	_name_label.visible = on
	_role_label.visible = on
	_msg_box.visible = on


func _process(delta: float) -> void:
	# Holographic cyan tint with a gentle slow pulse + subtle fast flicker,
	# kept alive while a sticky message waits for dismissal.
	if _sticky:
		var t := Time.get_ticks_msec() / 1000.0
		var a := 0.62 + 0.12 * sin(t * 3.0) + 0.08 * sin(t * 17.0)
		_portrait.modulate = Color(0.65, 0.95, 1.0, clampf(a, 0.0, 1.0))
		return
	if _timer <= 0.0:
		return
	_timer -= delta
	if _timer <= 0.0:
		_set_visible(false)
		return
	var t := Time.get_ticks_msec() / 1000.0
	var a := 0.62 + 0.12 * sin(t * 3.0) + 0.08 * sin(t * 17.0)
	_portrait.modulate = Color(0.65, 0.95, 1.0, clampf(a, 0.0, 1.0))
