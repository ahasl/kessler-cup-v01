# DoorInteractable.gd
extends Interactable

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _is_open := false


func _ready() -> void:
	super()

	_sprite.play("idle_door")


func set_highlight(on: bool) -> void:
	super(on)

	if on and not _is_open:
		_sprite.play("open_door")
		_is_open = true

	elif not on and _is_open:
		_sprite.play("close_door")
		_is_open = false
