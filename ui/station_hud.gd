extends CanvasLayer
## Station HUD: day counter + status (top-left). No carry bar here — the carried
## inventory only matters during a run; in the hub use the Lager (storage).

@onready var _day_label: Label = $HUD/TopLeft/Day
@onready var _status_label: Label = $HUD/TopLeft/Status


func _ready() -> void:
	EventBus.game_saved.connect(_on_game_saved)
	EventBus.upgrade_purchased.connect(_on_upgrade)
	_refresh()


func _refresh() -> void:
	_day_label.text = "DAY %d" % GameManager.day


func _on_game_saved() -> void:
	_refresh()
	_status_label.text = "Slept. Game saved."


func _on_upgrade(_id: String, _level: int) -> void:
	_refresh()
