extends Node
## Debug helpers. Set ENABLED = false before shipping.

const ENABLED := true


func _ready() -> void:
	if not ENABLED:
		set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match (event as InputEventKey).keycode:
		KEY_F8:
			_fill_station()
		KEY_F9:
			SaveManager.new_game()
			EventBus.say("[DEBUG] Save reset", "warning")


func _fill_station() -> void:
	for item_type in Items.ALL:
		InventoryManager.station.add(item_type, 99)
	EventBus.inventory_changed.emit()
	EventBus.say("[DEBUG] Inventory filled")
