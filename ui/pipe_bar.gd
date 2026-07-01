extends Control
## Pressure-tank display for the pipe-balancing minigame (vertical for the 4
## peripheral tanks, horizontal for the shared central reservoir). Parent
## sets `pressure` (0-100), `solved`/`danger` each frame, then calls
## queue_redraw(). `kind` draws a small system icon above the fill gauge, so
## each tank reads as an actual ship system rather than a bare pipe — leave
## it empty for a plain tank (used by the central reservoir).

@export var horizontal: bool = false
@export var kind: String = ""  # "fuel" | "coolant" | "thruster" | "hull" | ""

const ICON_HEIGHT := 34.0

var pressure: float = 50.0
var selected: bool = false
var solved: bool = false
var danger: bool = false  # near 0 or 100 — about to blow


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var icon_h: float = 0.0 if (horizontal or kind == "") else ICON_HEIGHT
	var body_top: float = icon_h
	var body_h: float = h - body_top

	draw_rect(Rect2(0.0, body_top, w, body_h), Color(0.02, 0.04, 0.09, 1.0), true)

	for i in range(1, 4):
		if horizontal:
			var gx: float = w * float(i) / 4.0
			draw_line(Vector2(gx, 0.0), Vector2(gx, h), Color(0.08, 0.16, 0.3, 0.25), 1.0)
		else:
			var gy: float = body_top + body_h * float(i) / 4.0
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
		var fill_h: float = body_h * ratio
		draw_rect(Rect2(0.0, h - fill_h, w, fill_h), col, true)

	var border_col := Color(0.5, 0.88, 1.0, 0.9) if selected else Color(0.16, 0.28, 0.5, 0.55)
	var border_width := 2.5 if selected else 1.0
	draw_rect(Rect2(0.0, body_top, w, body_h), border_col, false, border_width)

	if icon_h > 0.0:
		_draw_icon(w, icon_h)


func _draw_icon(w: float, icon_h: float) -> void:
	draw_rect(Rect2(0.0, 0.0, w, icon_h), Color(0.06, 0.09, 0.15, 1.0), true)
	draw_rect(Rect2(0.0, 0.0, w, icon_h), Color(0.16, 0.28, 0.5, 0.55), false, 1.0)

	var c := Vector2(w * 0.5, icon_h * 0.5)
	var s: float = minf(w, icon_h) * 0.32
	var col := Color(0.55, 0.78, 0.98, 0.95)

	match kind:
		"fuel":
			draw_rect(Rect2(c.x - s * 0.55, c.y - s * 0.55, s * 1.1, s * 1.3), col, true)
			draw_rect(Rect2(c.x - s * 0.18, c.y - s * 1.0, s * 0.36, s * 0.45), col, true)
		"coolant":
			var pts := PackedVector2Array([
				c + Vector2(0.0, -s), c + Vector2(s * 0.75, s * 0.35),
				c + Vector2(0.0, s), c + Vector2(-s * 0.75, s * 0.35),
			])
			draw_colored_polygon(pts, col)
		"thruster":
			var pts := PackedVector2Array([
				c + Vector2(0.0, -s), c + Vector2(s * 0.55, s * 0.15),
				c + Vector2(s * 0.22, s), c + Vector2(-s * 0.22, s),
				c + Vector2(-s * 0.55, s * 0.15),
			])
			draw_colored_polygon(pts, col)
		"hull":
			var pts := PackedVector2Array([
				c + Vector2(0.0, -s), c + Vector2(s * 0.85, -s * 0.45),
				c + Vector2(s * 0.7, s * 0.5), c + Vector2(0.0, s),
				c + Vector2(-s * 0.7, s * 0.5), c + Vector2(-s * 0.85, -s * 0.45),
			])
			draw_colored_polygon(pts, col)
