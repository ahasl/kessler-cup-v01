extends CanvasLayer
## Lager (storage) view. Opened from the station's storage prop. Lists the full
## contents of persistent station storage; refreshes live.

@onready var _root: Control = $Root
@onready var _list: RichTextLabel = $Root/Center/Panel/VBox/List
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton


func _ready() -> void:
	_close_button.pressed.connect(close)
	EventBus.inventory_changed.connect(_refresh)
	close()


func open() -> void:
	_root.visible = true
	_refresh()


func close() -> void:
	_root.visible = false


func _refresh() -> void:
	var text := ""
	for item_type in Items.ALL:
		var c := InventoryManager.station.count(item_type)
		if c <= 0:
			continue  # only list materials actually in storage
		var col := Items.color(item_type)
		text += "[color=#%s]%s[/color]   ×%d\n" % [col.to_html(false), Items.display_name(item_type), c]
	if text == "":
		text = "[color=#808890]Storage is empty.[/color]"
	_list.text = text
