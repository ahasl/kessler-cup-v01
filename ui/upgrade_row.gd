extends PanelContainer
## One upgrade row in the terminal. Bound to an upgrade id; reads everything
## from the Upgrades catalogue and UpgradeManager so it works for any upgrade.
## Always shows the current level and the level buying grants next (no plain
## "BUY" — the number IS the point). Buying is instant (cost -> level up) —
## the puzzle/reflex minigames happen earlier, at the Research Station, to
## even reveal an upgrade here (see research_panel.gd + Research.gd).
## fuel_tank has no research gate, so it's always available.

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
	var display_lvl := lvl + int(def.get("level_offset", 0))
	var info: String = "%s  ·  LEVEL %d" % [def["name"], display_lvl]

	if UpgradeManager.is_maxed(_id):
		if def.has("value_label"):
			info += "  (%d %s)" % [int(Upgrades.value_at(_id, lvl)), def["value_label"]]
		elif def.has("desc"):
			info += "  ·  " + str(def["desc"])
		_name_label.text = info
		_cost_label.text = "MAXED"
		_buy_button.disabled = true
		_buy_button.text = "✓"
		return

	if def.has("value_label"):
		info += "  →  %d  (+%d %s)" % [
			display_lvl + 1,
			int(Upgrades.value_at(_id, lvl + 1)) - int(Upgrades.value_at(_id, lvl)),
			def["value_label"],
		]
	elif def.has("desc"):
		info += "  →  %d  ·  %s" % [display_lvl + 1, str(def["desc"])]
	else:
		info += "  →  %d" % (display_lvl + 1)
	_name_label.text = info
	_cost_label.text = _format_cost(Upgrades.cost_for(_id, lvl))
	_buy_button.disabled = not UpgradeManager.can_afford(_id)
	_buy_button.text = "→  LV %d" % (display_lvl + 1)


func _format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for item_type in cost:
		parts.append("%d %s" % [int(cost[item_type]), Items.display_name(item_type)])
	return "  ·  ".join(parts)
