extends CanvasLayer
## Lager (storage) view. Opened from the station's storage prop. Shows
## persistent station storage as a fixed GRID_SIZE x GRID_SIZE icon grid (like
## a stash), one slot per catalog material filled in, the rest left empty for
## future materials. A new material in Items.gd just fills the next empty
## slot — no scene edits needed. Refreshes live.

const SLOT_SCENE := preload("res://ui/inventory_slot.tscn")
const GRID_SIZE := 7

@onready var _root: Control = $Root
@onready var _grid: GridContainer = $Root/Center/Panel/VBox/Grid
@onready var _empty_label: Label = $Root/Center/Panel/VBox/EmptyLabel
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton

var _slots: Array = []


func _ready() -> void:
	for i in GRID_SIZE * GRID_SIZE:
		var slot := SLOT_SCENE.instantiate()
		_grid.add_child(slot)
		_slots.append(slot)
	_close_button.pressed.connect(close)
	EventBus.inventory_changed.connect(_refresh)
	close()


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and event.is_action_pressed("ui_cancel"):
		close()


func open() -> void:
	_root.visible = true
	EventBus.overlay_opened.emit()
	_refresh()


func close() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()


func _refresh() -> void:
	if not is_node_ready():
		return
	var any := false
	for i in _slots.size():
		if i >= Items.ALL.size():
			_slots[i].set_slot(null)
			continue
		var item_type: int = Items.ALL[i]
		var c := InventoryManager.station.count(item_type)
		if c > 0:
			any = true
			_slots[i].set_slot({"type": item_type, "count": c})
		else:
			_slots[i].set_slot(null)
	_empty_label.visible = not any
