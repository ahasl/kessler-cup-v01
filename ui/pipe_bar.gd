extends Control
## Pressure-tank display for the pipe-balancing minigame (vertical for the 4
## peripheral tanks, horizontal for the shared central reservoir). Parent
## sets `pressure` (0-100), `solved`/`danger` each frame, then calls
## queue_redraw().

@export var horizontal: bool = false

var pressure: float = 50.0
var selected: bool = false
var solved: bool = false
var danger: bool = false  # near 0 or 100 — about to blow


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y

	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.02, 0.04, 0.09, 1.0), true)

	for i in range(1, 4):
		if horizontal:
			var gx: float = w * float(i) / 4.0
			draw_line(Vector2(gx, 0.0), Vector2(gx, h), Color(0.08, 0.16, 0.3, 0.25), 1.0)
		else:
			var gy: float = h * float(i) / 4.0
			draw_line(Vector2(0.0, gy), Vector2(w, gy), Color(0.08, 0.16, 0.3, 0.25), 1.0)

	var ratio: float = clampf(pressure / 100.0, 0.0, 1.0)
	var col := Color(0.95, 0.52, 0.2, 0.9)
	if solved:
		col = Color(0.28, 1.0, 0.52, 1.0)
	elif danger:
		col = Color(1.0, 0.22, 0.2, 0.95)

	if horizontal:
		draw_rect(Rect2(0.0, 0.0, w * ratio, h), col, true)
	else:
		var fill_h: float = h * ratio
		draw_rect(Rect2(0.0, h - fill_h, w, fill_h), col, true)

	var border_col := Color(0.5, 0.88, 1.0, 0.9) if selected else Color(0.16, 0.28, 0.5, 0.55)
	var border_width := 2.5 if selected else 1.0
	draw_rect(Rect2(0.0, 0.0, w, h), border_col, false, border_width)
