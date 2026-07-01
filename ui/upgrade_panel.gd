extends CanvasLayer
## The station PC terminal. Three tabs — Ship, Ship Weapon and Station — each
## built from the Upgrades catalogue by category. An id also listed in
## Research.CATALOG only appears once it's been researched (see
## research_panel.gd); an id with a `requires` field only appears once that
## other upgrade is bought. Empty/fully-locked tabs show a placeholder.

const ROW_SCENE := preload("res://ui/upgrade_row.tscn")

@onready var _root: Control = $Root
@onready var _tabs: TabContainer = $Root/Center/Panel/VBox/Tabs
@onready var _ship_tab: VBoxContainer = $Root/Center/Panel/VBox/Tabs/Ship
@onready var _weapon_tab: VBoxContainer = $Root/Center/Panel/VBox/Tabs/Weapon
@onready var _station_tab: VBoxContainer = $Root/Center/Panel/VBox/Tabs/Station
@onready var _close_button: Button = $Root/Center/Panel/VBox/CloseButton


func _ready() -> void:
	_tabs.set_tab_title(_tabs.get_tab_idx_from_control(_ship_tab), "SHIP")
	_tabs.set_tab_title(_tabs.get_tab_idx_from_control(_weapon_tab), "SHIP WEAPON")
	_tabs.set_tab_title(_tabs.get_tab_idx_from_control(_station_tab), "STATION")
	_close_button.pressed.connect(close)
	_rebuild_all_tabs()
	close()


func _rebuild_all_tabs() -> void:
	_rebuild_tab("ship", _ship_tab, "No ship upgrades researched yet.\nVisit the Research Lab.")
	_rebuild_tab("weapon", _weapon_tab, "No weapon upgrades researched yet.\nVisit the Research Lab.")
	_rebuild_tab("station", _station_tab, "No upgrades available yet.")


func _rebuild_tab(category: String, container: VBoxContainer, locked_msg: String) -> void:
	for child in container.get_children():
		child.queue_free()
	var ids := Upgrades.ids_in_category(category)
	var available := ids.filter(_is_available)
	if available.is_empty():
		_add_placeholder(container, locked_msg)
		return
	for id in available:
		var row := ROW_SCENE.instantiate()
		container.add_child(row)
		row.setup(id)


func _is_available(id: String) -> bool:
	if _needs_research(id) and not ResearchManager.has(id):
		return false
	var requires: String = Upgrades.CATALOG[id].get("requires", "")
	return requires == "" or UpgradeManager.level_of(requires) >= 1


func _needs_research(id: String) -> bool:
	for item: Dictionary in Research.CATALOG:
		if item["id"] == id:
			return true
	return false


func _add_placeholder(container: VBoxContainer, msg: String) -> void:
	var lbl := Label.new()
	lbl.text = msg
	lbl.add_theme_color_override("font_color", Color(0.45, 0.52, 0.65))
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	container.add_child(lbl)


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	_rebuild_all_tabs()
	_root.visible = true
	EventBus.overlay_opened.emit()


func close() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()
