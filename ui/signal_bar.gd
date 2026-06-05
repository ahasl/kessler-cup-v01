extends Control
## Live waveform display for the frequency-tuning minigame.
## Parent sets freq_distance (0 = perfect) and time_offset each frame, then calls queue_redraw().

var freq_distance: float = 50.0
var time_offset:   float = 0.0
var locked:        bool  = false


func _draw() -> void:
	var w:  float = size.x
	var h:  float = size.y
	var cx: float = h * 0.5

	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.02, 0.04, 0.09, 1.0), true)

	# Grid
	for i in range(1, 10):
		var gx: float = w * float(i) / 10.0
		draw_line(Vector2(gx, 0.0), Vector2(gx, h), Color(0.08, 0.16, 0.3, 0.22), 1.0)
	draw_line(Vector2(0.0, h * 0.25), Vector2(w, h * 0.25), Color(0.08, 0.16, 0.3, 0.28), 1.0)
	draw_line(Vector2(0.0, h * 0.50), Vector2(w, h * 0.50), Color(0.08, 0.16, 0.3, 0.28), 1.0)
	draw_line(Vector2(0.0, h * 0.75), Vector2(w, h * 0.75), Color(0.08, 0.16, 0.3, 0.28), 1.0)
	draw_line(Vector2(0.0, cx), Vector2(w, cx), Color(0.14, 0.28, 0.48, 0.4), 1.0)

	var noise: float = clamp(freq_distance / 50.0, 0.0, 1.0) if not locked else 0.0
	var col: Color
	if locked:
		col = Color(0.28, 1.0, 0.52, 1.0)
	elif noise < 0.08:
		col = Color(0.28, 0.95, 0.52, 0.95)
	elif noise < 0.25:
		col = Color(0.38, 0.88, 0.62, 0.9)
	elif noise < 0.5:
		col = Color(0.92, 0.8, 0.22, 0.88)
	elif noise < 0.75:
		col = Color(0.95, 0.52, 0.2, 0.88)
	else:
		col = Color(0.95, 0.28, 0.28, 0.88)

	var amp:   float = h * 0.36
	var steps: int   = int(w)
	var pts := PackedVector2Array()
	pts.resize(steps)

	for i in steps:
		var t:     float = float(i) / float(steps - 1)
		var base:  float = sin(t * TAU * 3.0 + time_offset * 2.0) * amp * (1.0 - noise * 0.38)
		var chaos: float = 0.0
		if noise > 0.005:
			chaos = (
				sin(t * TAU * 11.3 + time_offset * 6.7) * 0.45
				+ sin(t * TAU * 19.7 - time_offset * 9.4) * 0.3
				+ sin(t * TAU * 6.1 * (1.0 + noise) + time_offset * 14.3) * 0.25
			) * amp * noise
		pts[i] = Vector2(float(i), cx - (base + chaos))

	if pts.size() > 1:
		draw_polyline(pts, col, 2.4, true)

	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.16, 0.28, 0.5, 0.55), false, 1.0)
