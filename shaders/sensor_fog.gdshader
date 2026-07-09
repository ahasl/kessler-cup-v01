shader_type canvas_item;
// Soft "sensor range" dimming: the area around the ship (screen centre, since
// the camera follows it) stays clear; the edges dim toward the void. Not a
// hard fog-of-war — objects are still visible at range, just dimmer, so it
// reads as "sensor reach" rather than "hidden". Experimental (STYLE_GUIDE.md).
// Uses real pixel coordinates (not UV) so the circle stays a circle
// regardless of the viewport's aspect ratio.

uniform float clear_radius_px = 220.0;
uniform float fade_radius_px = 520.0;
uniform float max_dim = 0.7;

void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 center = resolution * 0.5;
	float d = length(FRAGCOORD.xy - center);
	float v = smoothstep(clear_radius_px, fade_radius_px, d) * max_dim;
	COLOR = vec4(0.0, 0.0, 0.0, v);
}
