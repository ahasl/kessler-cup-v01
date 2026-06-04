extends PanelContainer
## One upgrade row in the terminal. Bound to an upgrade id; reads everything
## from the Upgrades catalogue and UpgradeManager so it works for any upgrade.

@onready var _name_label: Label = $Margin/HBox/Info/Name
@onready var _cost_label: Label = $Margin/HBox/Info/Cost
@onready var _buy_button: Button = $Margin/HBox/BuyButton

var _id: String = ""


func setup(id: String) -> void:
	_id = id
	_buy_button.pressed.connect(_on_buy)
	EventBus.inventory_changed.connect(_refresh)
	EventBus.upgrade_purchased.connect(_on_upgrade)
	_refresh()


func _on_buy() -> void:
	UpgradeManager.purchase(_id)  # signals trigger _refresh on every row


func _on_upgrade(_id_changed: String, _level: int) -> void:
	_refresh()


func _refresh() -> void:
	var def: Dictionary = Upgrades.CATALOG[_id]
	var lvl := UpgradeManager.level_of(_id)
	var info := "%s   Lv %d/%d" % [def["name"], lvl, Upgrades.max_level(_id)]

	if UpgradeManager.is_maxed(_id):
		if def.has("desc"):
			info += "  ·  " + str(def["desc"])
		_name_label.text = info
		_cost_label.text = "MAXED OUT"
		_buy_button.disabled = true
		_buy_button.text = "—"
		return

	# Show what the next level gives (numeric upgrades), else the description.
	if def.has("value_label"):
		info += "  →  %d %s" % [int(Upgrades.value_at(_id, lvl + 1)), def["value_label"]]
	elif def.has("desc"):
		info += "  ·  " + str(def["desc"])
	_name_label.text = info
	_cost_label.text = _format_cost(Upgrades.cost_for(_id, lvl))
	_buy_button.disabled = not UpgradeManager.can_afford(_id)
	_buy_button.text = "Buy"


func _format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for item_type in cost:
		parts.append("%d %s" % [int(cost[item_type]), Items.display_name(item_type)])
	return "  ·  ".join(parts)
