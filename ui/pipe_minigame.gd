extends CanvasLayer
## Pressure-equalizer minigame for ship upgrades (fuel tank, hull, etc — any
## upgrade in the "ship" category). Four pipes share a fixed total pressure;
## the player relays pressure between NEIGHBORING pipes via valve buttons
## until all four read the same value, then confirms. Always solvable — the
## total never changes, only how it's distributed.

signal completed(success: bool)

const PIPE_COUNT := 4
const STEP := 5
const RESULT_HOLD_TIME := 1.2

@onready var _bg: ColorRect = $BG
@onready var _status: Label = $BG/Content/VBox/StatusLabel
@onready var _abandon: Button = $BG/Content/VBox/ActionRow/AbandonButton
@onready var _confirm: Button = $BG/Content/VBox/ActionRow/ConfirmButton

var _bars: Array = []
var _value_labels: Array = []
var _forward_buttons: Array = []
var _backward_buttons: Array = []

var _pressures: Array = []
var _confirmed := false
var _result_timer := 0.0


func _ready() -> void:
	for i in PIPE_COUNT:
		_bars.append(get_node("BG/Content/VBox/PipesRow/Pipe%d/Bar" % (i + 1)))
		_value_labels.append(get_node("BG/Content/VBox/PipesRow/Pipe%d/Value" % (i + 1)))
	for i in PIPE_COUNT - 1:
		var fwd: Button = get_node("BG/Content/VBox/PipesRow/Junction%d/ForwardButton" % (i + 1))
		var back: Button = get_node("BG/Content/VBox/PipesRow/Junction%d/BackButton" % (i + 1))
		fwd.pressed.connect(_on_transfer.bind(i, 1))
		back.pressed.connect(_on_transfer.bind(i, -1))
		_forward_buttons.append(fwd)
		_backward_buttons.append(back)
	_abandon.pressed.connect(_on_abandon)
	_confirm.pressed.connect(_on_confirm)
	_bg.visible = false


func start() -> void:
	_confirmed = false
	_result_timer = 0.0
	_pressures = _roll_pressures()
	_refresh()
	_bg.visible = true


## Four values with a fixed, evenly-divisible total, uneven at the start —
## deltas always sum to 0, so an exact equal split is always reachable.
func _roll_pressures() -> Array:
	var target := randi_range(30, 70)
	var deltas: Array = [15, -20, 10, -5]
	deltas.shuffle()
	var out: Array = []
	for d in deltas:
		out.append(clampi(target + int(d), 5, 95))
	return out


func _refresh() -> void:
	var lo: int = _pressures.min()
	var hi: int = _pressures.max()
	var solved := lo == hi
	for i in PIPE_COUNT:
		_bars[i].pressure = _pressures[i]
		_bars[i].solved = solved
		_bars[i].queue_redraw()
		_value_labels[i].text = str(_pressures[i])
	for i in PIPE_COUNT - 1:
		_forward_buttons[i].disabled = _confirmed or _pressures[i] < STEP or _pressures[i + 1] > 100 - STEP
		_backward_buttons[i].disabled = _confirmed or _pressures[i] > 100 - STEP or _pressures[i + 1] < STEP
	_confirm.disabled = _confirmed or not solved
	if _confirmed:
		return
	if solved:
		_status.text = "PRESSURE BALANCED — ready to confirm"
		_status.add_theme_color_override("font_color", Color(0.28, 1.0, 0.52, 0.95))
	else:
		_status.text = "UNBALANCED  ·  spread %d" % (hi - lo)
		_status.add_theme_color_override("font_color", Color(0.92, 0.62, 0.22, 0.9))


# direction=1 (forward "→"): pipe[i] gives STEP to pipe[i+1].
# direction=-1 (back "←"): pipe[i+1] gives STEP to pipe[i].
func _on_transfer(junction: int, direction: int) -> void:
	if _confirmed:
		return
	var amount: int = STEP * direction
	var a: int = _pressures[junction] - amount
	var b: int = _pressures[junction + 1] + amount
	if a < 0 or a > 100 or b < 0 or b > 100:
		return
	_pressures[junction] = a
	_pressures[junction + 1] = b
	_refresh()


func _on_confirm() -> void:
	if _confirmed or _confirm.disabled:
		return
	_confirmed = true
	_result_timer = RESULT_HOLD_TIME
	_status.text = "▶  PRESSURE LOCKED"
	_status.add_theme_color_override("font_color", Color(0.28, 1.0, 0.52, 1.0))
	_refresh()


func _process(delta: float) -> void:
	if not _bg.visible or not _confirmed:
		return
	_result_timer -= delta
	if _result_timer <= 0.0:
		_bg.visible = false
		completed.emit(true)


func _on_abandon() -> void:
	_bg.visible = false
	completed.emit(false)


func _unhandled_input(event: InputEvent) -> void:
	if not _bg.visible or _confirmed:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_abandon()
