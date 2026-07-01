extends PanelContainer
## One selectable research target in the Research panel. The player picks
## freely among all not-yet-researched catalog entries — pressing RESEARCH
## starts THIS entry's minigame (ship puzzle or weapon reflex game).

signal start_requested(id: String)

@onready var _name_label: Label = $Margin/HBox/Info/Name
@onready var _desc_label: Label = $Margin/HBox/Info/Desc
@onready var _start_button: Button = $Margin/HBox/StartButton

var _id: String = ""


func setup(item: Dictionary) -> void:
	_id = item["id"]
	_name_label.text = item["name"]
	_desc_label.text = item.get("desc", "")
	_start_button.pressed.connect(func(): start_requested.emit(_id))


func set_affordable(can_afford: bool) -> void:
	_start_button.disabled = not can_afford
