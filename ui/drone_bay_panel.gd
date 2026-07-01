extends CanvasLayer
## Drone Bay info panel. Opened from the Drone Bay prop. Purely informational
## — the actual daily haul happens in GameManager on sleep; this just explains
## what the drone does at its current level.

@onready var _root:        Control = $Root
@onready var _level_label: Label   = $Root/Center/Panel/VBox/LevelLabel
@onready var _desc_label:  Label   = $Root/Center/Panel/VBox/DescLabel
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton


func _ready() -> void:
	_close_button.pressed.connect(close)
	close()


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	_refresh()
	_root.visible = true
	EventBus.overlay_opened.emit()


func close() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()


func _refresh() -> void:
	var level := maxi(UpgradeManager.get_drone_level(), 1)
	_level_label.text = "Level %d" % level
	_desc_label.text = (
		"Launches automatically once a day, right after you sleep, and comes "
		+ "back with salvaged materials.\n\n%d materials per trip. Possible: %s."
	) % [DroneBay.total_per_day(level), DroneBay.describe(level)]
