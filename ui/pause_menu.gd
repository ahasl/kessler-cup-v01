extends CanvasLayer
## Pause/options overlay — [ESC] toggles it, in both the station and space
## scenes. Shows the full control reference (previously a small top-of-screen
## hint) plus Resume / Main Menu / Quit. Added last in both scenes so other
## panels get first pick of an [ESC] press (they mark it handled when they
## close themselves for it).

@onready var _root: Control = $Root
@onready var _resume_button: Button = $Root/Center/Panel/VBox/Buttons/ResumeButton
@onready var _main_menu_button: Button = $Root/Center/Panel/VBox/Buttons/MainMenuButton
@onready var _quit_button: Button = $Root/Center/Panel/VBox/Buttons/QuitButton


func _ready() -> void:
	_resume_button.pressed.connect(close)
	_main_menu_button.pressed.connect(_on_main_menu)
	_quit_button.pressed.connect(func(): get_tree().quit())
	close()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _root.visible:
		close()
	else:
		open()
	get_viewport().set_input_as_handled()


func open() -> void:
	_root.visible = true
	EventBus.overlay_opened.emit()


func close() -> void:
	_root.visible = false
	EventBus.overlay_closed.emit()


func _on_main_menu() -> void:
	if GameManager.run_active:
		GameManager.abandon_run()
	close()
	GameManager.goto_main_menu()
