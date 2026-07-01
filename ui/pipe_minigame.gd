extends CanvasLayer
## Pressure-equalizer minigame for ship upgrades. A central reservoir sits
## between 4 peripheral tanks; each connects to it through a valve the player
## drags open with the mouse (pressure_valve.gd). The moment a valve opens, it
## locks in a flow DIRECTION (whichever side is higher right then) and keeps
## pushing that way at a fixed rate for as long as it stays open — it does
## NOT auto-stop once the two sides match. So the player has to watch the
## numbers and close the valve right around the match point; leave it open
## and it sails past equalization and can shove a tank past its safe range —
## it explodes and the attempt fails. Win: get all four peripheral tanks to
## the same pressure, then confirm.

signal completed(success: bool)

const PIPE_COUNT := 4
const FLOW_RATE := 10.0       # pressure units/sec at full valve openness
const DEAD_ZONE := 0.5        # a valve opened while already this close does nothing
const SAFE_MIN := 0.0
const SAFE_MAX := 100.0
const DANGER_MARGIN := 12.0   # within this of a limit = danger coloring
const WIN_TOLERANCE := 2.0
const RESULT_HOLD_TIME := 1.4

@onready var _bg: ColorRect = $BG
@onready var _status: Label = $BG/Content/VBox/StatusLabel
@onready var _abandon: Button = $BG/Content/VBox/ActionRow/AbandonButton
@onready var _confirm: Button = $BG/Content/VBox/ActionRow/ConfirmButton
@onready var _center_bar: Control = $BG/Content/VBox/CenterRow/CenterTank/Bar
@onready var _center_value: Label = $BG/Content/VBox/CenterRow/CenterTank/Value

var _pipe_bars: Array = []
var _pipe_values: Array = []
var _valves: Array = []

var _pressures: Array = []
var _valve_directions: Array = []  # -1, 0 or 1 per pipe, locked in while open
var _center_pressure: float = 50.0
var _running := false
var _confirmed := false
var _pending_result := false
var _result_timer := 0.0


func _ready() -> void:
	for i in PIPE_COUNT:
		_pipe_bars.append(get_node("BG/Content/VBox/PipesRow/Pipe%d/Bar" % (i + 1)))
		_pipe_values.append(get_node("BG/Content/VBox/PipesRow/Pipe%d/Value" % (i + 1)))
		_valves.append(get_node("BG/Content/VBox/PipesRow/Pipe%d/Valve" % (i + 1)))
	_abandon.pressed.connect(_on_abandon)
	_confirm.pressed.connect(_on_confirm)
	_bg.visible = false


func start() -> void:
	_confirmed = false
	_running = true
	_result_timer = 0.0
	_pressures = _roll_pressures()
	_valve_directions = [0, 0, 0, 0]
	_center_pressure = 50.0
	for v in _valves:
		v.openness = 0.0
		v.locked = false
		v.queue_redraw()
	_confirm.disabled = true
	_refresh_visuals(false)
	_bg.visible = true


## Four values around a 50 average (so the shared centre starts neutral),
## deltas always summing to 0 — an exact equal split is always reachable.
func _roll_pressures() -> Array:
	var deltas: Array = [30, -35, 20, -15]
	deltas.shuffle()
	var out: Array = []
	for d in deltas:
		out.append(clampf(50.0 + float(d), 8.0, 92.0))
	return out


func _process(delta: float) -> void:
	if not _bg.visible:
		return
	if _running:
		_simulate(delta)
		_refresh_visuals(true)
		return
	_result_timer -= delta
	if _result_timer <= 0.0:
		_bg.visible = false
		completed.emit(_pending_result)


# Flow direction locks in the instant a valve opens and does NOT re-check the
# gap afterwards — so it's the player's job to close the valve once the two
# sides match. Leaving it open keeps pushing the same way and risks a rupture.
func _simulate(delta: float) -> void:
	for i in PIPE_COUNT:
		var openness: float = _valves[i].openness
		if openness <= 0.001:
			_valve_directions[i] = 0  # closed: forget direction, re-lock next time
			continue
		if _valve_directions[i] == 0:
			var diff: float = _pressures[i] - _center_pressure
			if absf(diff) < DEAD_ZONE:
				continue  # already balanced enough — opening it does nothing yet
			_valve_directions[i] = int(signf(diff))
		var flow: float = float(_valve_directions[i]) * FLOW_RATE * openness * delta
		_pressures[i] -= flow
		_center_pressure += flow
		if _pressures[i] <= SAFE_MIN or _pressures[i] >= SAFE_MAX:
			_explode()
			return
	if _center_pressure <= SAFE_MIN or _center_pressure >= SAFE_MAX:
		_explode()


func _explode() -> void:
	_running = false
	_pending_result = false
	_result_timer = RESULT_HOLD_TIME
	for v in _valves:
		v.locked = true
	_confirm.disabled = true
	_status.text = "▶  OVERPRESSURE — TANK RUPTURED"
	_status.add_theme_color_override("font_color", Color(1.0, 0.3, 0.25, 1.0))
	_refresh_visuals(false)


func _refresh_visuals(check_solved: bool) -> void:
	for i in PIPE_COUNT:
		var p: float = _pressures[i]
		_pipe_bars[i].pressure = p
		_pipe_bars[i].danger = p <= SAFE_MIN + DANGER_MARGIN or p >= SAFE_MAX - DANGER_MARGIN
		_pipe_values[i].text = str(int(round(p)))
	_center_bar.pressure = _center_pressure
	_center_bar.danger = (
		_center_pressure <= SAFE_MIN + DANGER_MARGIN or _center_pressure >= SAFE_MAX - DANGER_MARGIN
	)
	_center_value.text = str(int(round(_center_pressure)))

	if not check_solved:
		for bar in _pipe_bars:
			bar.solved = false
			bar.queue_redraw()
		_center_bar.queue_redraw()
		return

	var lo: float = _pressures.min()
	var hi: float = _pressures.max()
	var solved := (hi - lo) <= WIN_TOLERANCE
	for bar in _pipe_bars:
		bar.solved = solved
		bar.queue_redraw()
	_center_bar.solved = solved
	_center_bar.queue_redraw()
	_confirm.disabled = not solved
	if solved:
		_status.text = "PRESSURE BALANCED — ready to confirm"
		_status.add_theme_color_override("font_color", Color(0.28, 1.0, 0.52, 0.95))
	else:
		_status.text = "UNBALANCED  ·  spread %d" % int(hi - lo)
		_status.add_theme_color_override("font_color", Color(0.92, 0.62, 0.22, 0.9))


func _on_confirm() -> void:
	if _confirmed or _confirm.disabled or not _running:
		return
	_confirmed = true
	_running = false
	_pending_result = true
	_result_timer = RESULT_HOLD_TIME
	for v in _valves:
		v.locked = true
	_status.text = "▶  PRESSURE LOCKED"
	_status.add_theme_color_override("font_color", Color(0.28, 1.0, 0.52, 1.0))


func _on_abandon() -> void:
	_bg.visible = false
	completed.emit(false)


func _unhandled_input(event: InputEvent) -> void:
	if not _bg.visible or not _running:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_abandon()
