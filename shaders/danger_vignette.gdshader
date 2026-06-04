shader_type canvas_item;
// Red edge vignette that intensifies as `intensity` rises (low-fuel danger).

uniform float intensity = 0.0;

void fragment() {
	vec2 uv = (UV - 0.5) * vec2(1.1, 1.4);
	float d = length(uv);
	float v = smoothstep(0.35, 0.85, d);
	COLOR = vec4(1.0, 0.08, 0.08, v * clamp(intensity, 0.0, 1.0));
}
