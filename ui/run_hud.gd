extends CanvasLayer
## Run HUD: prominent fuel gauge (top centre) with a red danger vignette that
## intensifies as fuel runs low, plus the run-loot bar (bottom centre).

const FUEL_WIDTH := 360.0
const LOW_FUEL_RATIO := 0.30

@onready var _fuel_fill: ColorRect = $HUD/FuelPanel/VBox/FuelFrame/FuelFill
@onready var _fuel_text: Label = $HUD/FuelPanel/VBox/FuelFrame/FuelText
@onready var _overlay: ColorRect = $HUD/LowFuelOverlay
@onready var _loot_view: PanelContainer = $HUD/BottomBar/InventoryView
@onready var _station_arrow: Polygon2D = $StationArrow
@onready var _station_dist: Label = $StationDist

var _fuel_danger := 0.0
var _edge_danger := 0.0


func _ready() -> void:
	_loot_view.bind(InventoryManager.run)
	EventBus.fuel_changed.connect(_on_fuel_changed)
	EventBus.edge_danger.connect(_on_edge_danger)
	var max_fuel := UpgradeManager.get_max_fuel()
	_on_fuel_changed(max_fuel, max_fuel)


func _on_fuel_changed(current: float, maximum: float) -> void:
	var ratio := current / maximum if maximum > 0.0 else 0.0
	_fuel_fill.offset_right = FUEL_WIDTH * ratio
	_fuel_fill.color = Color(1.0, 0.3, 0.2).lerp(Color(0.3, 1.0, 0.5), ratio)
	_fuel_text.text = "%d / %d" % [roundi(current), roundi(maximum)]
	_fuel_danger = clampf((LOW_FUEL_RATIO - ratio) / LOW_FUEL_RATIO, 0.0, 1.0)


func _on_edge_danger(level: float) -> void:
	_edge_danger = level


func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var pulse := 0.6 + 0.4 * sin(t * 6.0)
	var danger := maxf(_fuel_danger, _edge_danger)
	_overlay.material.set_shader_parameter("intensity", danger * pulse)
	_update_home_indicator()


# Off-screen arrow pointing back to the home station, with distance.
func _update_home_indicator() -> void:
	var station := get_tree().get_first_node_in_group("docking") as Node2D
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if station == null or player == null:
		_station_arrow.visible = false
		_station_dist.visible = false
		return

	var viewport := get_viewport()
	var size := viewport.get_visible_rect().size
	var screen_pos := viewport.get_canvas_transform() * station.global_position

	if screen_pos.x >= 0.0 and screen_pos.x <= size.x and screen_pos.y >= 0.0 and screen_pos.y <= size.y:
		# Station is on screen — no arrow needed.
		_station_arrow.visible = false
		_station_dist.visible = false
		return

	var margin := 64.0
	var edge := Vector2(
		clampf(screen_pos.x, margin, size.x - margin),
		clampf(screen_pos.y, margin, size.y - margin)
	)
	var dir := screen_pos - size * 0.5

	_station_arrow.visible = true
	_station_arrow.position = edge
	_station_arrow.rotation = dir.angle()

	_station_dist.visible = true
	_station_dist.position = edge + Vector2(-20, 18)
	var meters := int(player.global_position.distance_to(station.global_position) * 0.1)
	_station_dist.text = "%d m" % meters
