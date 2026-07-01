extends CPUParticles2D
## Small glowing ambient motes — "space fireflies". Purely decorative, additive
## blend so they pop with the scene glow. Scatter several with different
## `tint` values into any biome for a fuller, livelier feel.

@export var tint: Color = Color(0.6, 1.0, 0.85):
	set(value):
		tint = value
		if is_inside_tree():
			_apply_tint()


func _ready() -> void:
	_apply_tint()


func _apply_tint() -> void:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	grad.colors = PackedColorArray([
		Color(tint.r, tint.g, tint.b, 0.0),
		Color(tint.r, tint.g, tint.b, 0.9),
		Color(tint.r, tint.g, tint.b, 0.9),
		Color(tint.r, tint.g, tint.b, 0.0),
	])
	color_ramp = grad
