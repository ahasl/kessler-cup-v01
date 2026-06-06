class_name InteractPrompt
extends PanelContainer
## Modern in-world interaction prompt built from real Label nodes.
## Dark pill background, teal key badge, white action text.
## Key is resolved live from InputMap — works with keyboard and controller.

@export var label: String = "Interact"


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE

	# Dark rounded background
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.07, 0.1, 0.92)
	style.set_corner_radius_all(3)
	style.content_margin_left   = 6.0
	style.content_margin_right  = 6.0
	style.content_margin_top    = 3.0
	style.content_margin_bottom = 3.0
	add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.mouse_filter = MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", 5)
	add_child(hbox)

	# Key badge  "[ E ]"
	var key_lbl := Label.new()
	key_lbl.text = "[ %s ]" % _resolve_key()
	key_lbl.add_theme_font_size_override("font_size", 7)
	key_lbl.add_theme_color_override("font_color", Color(0.40, 0.86, 0.80, 1.0))
	key_lbl.mouse_filter = MOUSE_FILTER_IGNORE
	hbox.add_child(key_lbl)

	# Action name
	var action_lbl := Label.new()
	action_lbl.text = label
	action_lbl.add_theme_font_size_override("font_size", 7)
	action_lbl.add_theme_color_override("font_color", Color(0.96, 0.96, 0.96, 1.0))
	action_lbl.mouse_filter = MOUSE_FILTER_IGNORE
	hbox.add_child(action_lbl)

	# Force size from content after layout runs.
	call_deferred(&"_fit_size")


func _fit_size() -> void:
	set_size(get_minimum_size())


func _resolve_key() -> String:
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey:
			var ev := event as InputEventKey
			var kc := ev.keycode if ev.keycode != KEY_NONE else ev.physical_keycode
			if kc != KEY_NONE:
				return OS.get_keycode_string(kc)
		elif event is InputEventJoypadButton:
			return _joy_label((event as InputEventJoypadButton).button_index)
	return "E"


func _joy_label(btn: int) -> String:
	match btn:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
	return "●"
