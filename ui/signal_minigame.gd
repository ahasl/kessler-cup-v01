extends CanvasLayer
## Frequency-tuning minigame for weapon research.
## Player adjusts the slider until the waveform looks perfectly smooth, then
## presses CONFIRM. No text reveals the exact match — the wave is the only feedback.
## Correct frequency (100% match) → success. Wrong → fail, chips consumed.

signal completed(success: bool)

const RESULT_HOLD_TIME := 1.6

var _target:        int   = 50
var _current:       int   = 50
var _time:          float = 0.0
var _confirmed:     bool  = false
var _result_timer:  float = 0.0
var _result_ok:     bool  = false

@onready var _bg:      ColorRect = $BG
@onready var _wave:    Control   = $BG/Content/VBox/WaveDisplay
@onready var _freq:    Label     = $BG/Content/VBox/FreqLabel
@onready var _status:  Label     = $BG/Content/VBox/StatusLabel
@onready var _slider:  HSlider   = $BG/Content/VBox/SliderMargin/Slider
@onready var _abandon: Button    = $BG/Content/VBox/ActionRow/AbandonButton
@onready var _confirm: Button    = $BG/Content/VBox/ActionRow/ConfirmButton


func _ready() -> void:
	_slider.value_changed.connect(_on_slider_changed)
	_abandon.pressed.connect(_on_abandon)
	_confirm.pressed.connect(_on_confirm)
	_bg.visible = false


func start() -> void:
	_target    = randi_range(15, 85)
	_current   = randi_range(0, 100)
	_confirmed = false
	_time      = 0.0
	_wave.locked        = false
	_wave.freq_distance = float(absi(_current - _target))
	_wave.time_offset   = 0.0
	_slider.set_value_no_signal(float(_current))
	_slider.editable = true
	_update_status()
	_bg.visible = true


func _process(delta: float) -> void:
	if not _bg.visible:
		return
	_time += delta
	_wave.time_offset = _time
	_wave.queue_redraw()

	if _confirmed:
		_result_timer -= delta
		if _result_timer <= 0.0:
			_bg.visible = false
			completed.emit(_result_ok)


func _on_slider_changed(value: float) -> void:
	if _confirmed:
		return
	_current = int(value)
	_wave.freq_distance = float(absi(_current - _target))
	_update_status()


func _update_status() -> void:
	var dist: int = absi(_current - _target)
	# No text feedback for exact match — player must judge by the wave alone.
	if dist <= 3:
		_status.text = "SIGNAL STABILIZING . . ."
		_status.add_theme_color_override("font_color", Color(0.45, 0.9, 0.62, 0.9))
	elif dist <= 10:
		_status.text = "WEAK SIGNAL DETECTED"
		_status.add_theme_color_override("font_color", Color(0.92, 0.8, 0.22, 0.9))
	elif dist <= 25:
		_status.text = "SCANNING . . ."
		_status.add_theme_color_override("font_color", Color(0.92, 0.52, 0.2, 0.85))
	else:
		_status.text = "NO SIGNAL"
		_status.add_theme_color_override("font_color", Color(0.88, 0.28, 0.28, 0.85))


func _on_confirm() -> void:
	if _confirmed:
		return
	_confirmed    = true
	_result_ok    = absi(_current - _target) == 0
	_result_timer = RESULT_HOLD_TIME

	_slider.editable = false
	_wave.locked     = _result_ok
	_wave.freq_distance = float(absi(_current - _target))

	if _result_ok:
		_status.text = "▶  SIGNAL LOCKED"
		_status.add_theme_color_override("font_color", Color(0.28, 1.0, 0.52, 1.0))
	else:
		_status.text = "WRONG FREQUENCY — signal lost"
		_status.add_theme_color_override("font_color", Color(0.9, 0.28, 0.28, 1.0))


func _on_abandon() -> void:
	_bg.visible = false
	completed.emit(false)


func _unhandled_input(event: InputEvent) -> void:
	if not _bg.visible or _confirmed:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_abandon()
