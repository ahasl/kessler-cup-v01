shader_type canvas_item;
// Holographic scanlines: dims brightness and alpha in horizontal bands so a
// flat-coloured shape reads as a projected hologram. Screen-space (FRAGCOORD)
// so it works on Polygon2D without UVs.

uniform float line_freq = 0.5;       // bands per screen pixel
uniform float line_strength = 0.35;  // how dark/transparent the bands get

void fragment() {
	float s = 0.5 + 0.5 * sin(FRAGCOORD.y * line_freq);
	float scan = 1.0 - line_strength * (1.0 - s);
	COLOR.rgb *= scan;
	COLOR.a *= scan;
}
