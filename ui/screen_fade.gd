extends CanvasLayer
## A full-screen black fade used for the sleep transition. Call flash() to fade
## to black and back.

@onready var _rect: ColorRect = $Rect


func flash() -> void:
	_rect.color = Color(0, 0, 0, 0)
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", 1.0, 0.35)
	tw.tween_interval(0.25)
	tw.tween_property(_rect, "color:a", 0.0, 0.5)
