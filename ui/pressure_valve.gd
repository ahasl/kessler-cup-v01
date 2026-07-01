extends Control
## Draggable valve wheel. Drag up to open it, drag down to close it —
## `openness` (0 = shut, 1 = fully open) is read every frame by the minigame
## to compute flow. No clicking a "transfer" button: the valve itself is the
## control, the way a real one would be.

signal changed(value: float)

const DRAG_RANGE := 90.0  # px of vertical drag from fully closed to fully open

var openness: float = 0.0
var locked: bool = false

var _dragging := false
var _drag_start_y := 0.0
var _drag_start_value := 0.0


func _gui_input(event: InputEvent) -> void:
	if locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_start_y = event.position.y
			_drag_start_value = openness
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		var delta_y: float = _drag_start_y - event.position.y  # drag UP = open more
		openness = clampf(_drag_start_value + delta_y / DRAG_RANGE, 0.0, 1.0)
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

	var border_col := Color(0.5, 0.88, 1.0, 0.85) if _dragging else Color(0.2, 0.3, 0.45, 0.6)
	var border_width := 2.5 if _dragging else 1.2
	draw_arc(center, r, 0.0, TAU, 32, border_col, border_width)
