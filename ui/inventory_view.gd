extends PanelContainer
## Reusable inventory display. Bound to any Inventory (station or run) via
## `bind`. Refreshes on the relevant EventBus signals. The 5 slot views are
## inventory_slot instances placed in inventory_view.tscn.

@export var title: String = "INVENTORY"

@onready var _title_label: Label = $VBox/Title
@onready var _slots: HBoxContainer = $VBox/Slots

var _inventory: Inventory = null


func _ready() -> void:
	EventBus.inventory_changed.connect(_refresh)
	EventBus.loot_collected.connect(_on_loot)
	_refresh()


func bind(inventory: Inventory, p_title := "") -> void:
	_inventory = inventory
	if p_title != "":
		title = p_title
	_refresh()


func _on_loot(_item_type: int, _amount: int) -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	_title_label.text = title
	var slot_nodes := _slots.get_children()
	for i in slot_nodes.size():
		var data = null
		if _inventory != null and i < _inventory.slots.size():
			data = _inventory.slots[i]
		slot_nodes[i].set_slot(data)
