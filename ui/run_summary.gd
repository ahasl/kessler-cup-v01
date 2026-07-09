extends CanvasLayer
## Post-run recap (Dave the Diver style): time survived and distance reached
## this run, plus the all-time records, shown right after docking/dying and
## before the loading screen to the station. GameManager computes the stats
## and fires `run_summary_ready`; this panel just displays them and, once the
## player dismisses it, hands control back to GameManager for the actual
## scene transition.

@onready var _root: Control = $Root
@onready var _time_label: Label = $Root/Center/Panel/VBox/TimeRow/Value
@onready var _time_record_label: Label = $Root/Center/Panel/VBox/TimeRow/Record
@onready var _best_time_label: Label = $Root/Center/Panel/VBox/BestTime
@onready var _distance_label: Label = $Root/Center/Panel/VBox/DistanceRow/Value
@onready var _distance_record_label: Label = $Root/Center/Panel/VBox/DistanceRow/Record
@onready var _best_distance_label: Label = $Root/Center/Panel/VBox/BestDistance
@onready var _continue_button: Button = $Root/Center/Panel/VBox/ContinueButton


func _ready() -> void:
	_root.visible = false
	EventBus.run_summary_ready.connect(_on_summary_ready)
	_continue_button.pressed.connect(_continue)


func _on_summary_ready(stats: Dictionary) -> void:
	_time_label.text = _format_time(stats.get("run_time", 0.0))
	_best_time_label.text = "Best: %s" % _format_time(stats.get("best_run_time", 0.0))
	_time_record_label.visible = stats.get("time_record", false)

	_distance_label.text = "%dm" % roundi(stats.get("max_distance", 0.0))
	_best_distance_label.text = "Best: %dm" % roundi(stats.get("best_distance", 0.0))
	_distance_record_label.visible = stats.get("distance_record", false)

	_root.visible = true
	EventBus.overlay_opened.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _root.visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_continue()


func _continue() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()
	GameManager.goto_station()


func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%d:%02d" % [total / 60, total % 60]
