extends Control
## Entry point. New Game starts fresh (overwrites the save on the next save);
## Continue loads the existing save. Continue is disabled when there's no save.

@onready var _new_game_button: Button = $Center/Menu/NewGameButton
@onready var _continue_button: Button = $Center/Menu/ContinueButton
@onready var _quit_button: Button = $Center/Menu/QuitButton


func _ready() -> void:
	_new_game_button.pressed.connect(_on_new_game)
	_continue_button.pressed.connect(_on_continue)
	_quit_button.pressed.connect(func(): get_tree().quit())

	_continue_button.disabled = not SaveManager.has_save()
	if SaveManager.has_save():
		_continue_button.grab_focus()
	else:
		_new_game_button.grab_focus()


func _on_new_game() -> void:
	SaveManager.new_game()
	GameManager.goto_station()


func _on_continue() -> void:
	SaveManager.load_game()
	GameManager.goto_station()
