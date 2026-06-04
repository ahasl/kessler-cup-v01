shader_type canvas_item;
// Procedural twinkling starfield for a full-screen ColorRect.
// Three layers of stars at different scales give a sense of depth.

uniform vec4 bg_color : source_color = vec4(0.03, 0.04, 0.08, 1.0);
uniform float density = 60.0;
uniform float twinkle_speed = 1.5;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float star_layer(vec2 uv, float scale, float brightness) {
	uv *= scale;
	vec2 gv = fract(uv) - 0.5;
	vec2 id = floor(uv);
	float n = hash21(id);
	if (n <= 0.62) {
		return 0.0;
	}
	vec2 offset = vec2(hash21(id + 1.7), hash21(id + 4.3)) - 0.5;
	float d = length(gv - offset * 0.7);
	float size = mix(0.02, 0.07, hash21(id + 8.1));
	float twinkle = 0.5 + 0.5 * sin(TIME * twinkle_speed + n * 6.2831);
	return smoothstep(size, 0.0, d) * twinkle * brightness;
}

void fragment() {
	vec2 uv = UV;
	uv.x *= 1.6; // compensate for wide aspect
	float s = 0.0;
	s += star_layer(uv + 2.0, density * 0.5, 0.55);
	s += star_layer(uv + 17.0, density, 0.85);
	s += star_layer(uv + 41.0, density * 1.8, 0.45);
	vec3 col = bg_color.rgb + vec3(s) * vec3(0.85, 0.92, 1.0);
	COLOR = vec4(col, 1.0);
}
