extends Control
## Press-and-hold valve wheel. Hold the mouse button down on it to open it
## (ramps up while held); release to close it again (ramps back down). Tap
## briefly for a small nudge, hold longer for more flow — much easier to
## control precisely with a mouse than dragging to an exact position.
## `openness` (0 = shut, 1 = fully open) is read every frame by the minigame
## to compute flow.

signal changed(value: float)

const RAMP_TIME := 0.4  # seconds to go fully closed <-> fully open

var openness: float = 0.0
var locked: bool = false

var _held := false


func _gui_input(event: InputEvent) -> void:
	if locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_held = event.pressed
		accept_event()


func _process(delta: float) -> void:
	if locked:
		if openness == 0.0:
			return
	var target := 1.0 if (_held and not locked) else 0.0
	if is_equal_approx(openness, target):
		return
	openness = move_toward(openness, target, delta / RAMP_TIME)
	changed.emit(openness)
	queue_redraw()


func _draw() -> void:
	var r: float = minf(size.x, size.y) * 0.5
	var center := size * 0.5

	draw_circle(center, r, Color(0.06, 0.08, 0.13, 1.0))
	draw_arc(center, r - 1.5, 0.0, TAU, 32, Color(0.3, 0.4, 0.55, 0.6), 2.0)

	# Needle sweeps from lower-left (closed) through the top (fully open).
	var angle: float = lerpf(PI * 0.75, -PI * 0.75, openness)
	var needle_col := Color(0.4, 0.45, 0.55, 1.0)
	if openness > 0.66:
		needle_col = Color(1.0, 0.4, 0.25, 1.0)
	elif openness > 0.02:
		needle_col = Color(0.95, 0.75, 0.25, 1.0)
	draw_line(center, center + Vector2(cos(angle), sin(angle)) * (r * 0.78), needle_col, 3.0)
	draw_circle(center, r * 0.16, needle_col)

	var border_col := Color(0.5, 0.88, 1.0, 0.85) if _held else Color(0.2, 0.3, 0.45, 0.6)
	var border_width := 2.5 if _held else 1.2
	draw_arc(center, r, 0.0, TAU, 32, border_col, border_width)
