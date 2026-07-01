extends Control
## Vertical pressure-tank display for the pipe-balancing minigame. Parent sets
## `pressure` (0-100) and `solved` each frame/update, then calls queue_redraw().

var pressure: float = 50.0
var selected: bool = false
var solved: bool = false


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y

	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.02, 0.04, 0.09, 1.0), true)

	for i in range(1, 4):
		var gy: float = h * float(i) / 4.0
		draw_line(Vector2(0.0, gy), Vector2(w, gy), Color(0.08, 0.16, 0.3, 0.25), 1.0)

	var fill_h: float = h * clampf(pressure / 100.0, 0.0, 1.0)
	var col := Color(0.95, 0.52, 0.2, 0.9)
	if solved:
		col = Color(0.28, 1.0, 0.52, 1.0)
	draw_rect(Rect2(0.0, h - fill_h, w, fill_h), col, true)

	var border_col := Color(0.5, 0.88, 1.0, 0.9) if selected else Color(0.16, 0.28, 0.5, 0.55)
	var border_width := 2.5 if selected else 1.0
	draw_rect(Rect2(0.0, 0.0, w, h), border_col, false, border_width)
