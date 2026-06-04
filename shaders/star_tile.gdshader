shader_type canvas_item;
// One tileable layer of twinkling stars on a transparent background, so several
// can stack as parallax layers. `cells` is integer -> tiles seamlessly with a
// ParallaxLayer whose motion_mirroring equals the rect size.

uniform float cells = 8.0;
uniform float brightness = 0.8;
uniform float twinkle_speed = 1.0;
uniform vec4 tint : source_color = vec4(0.85, 0.92, 1.0, 1.0);

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 uv = UV * cells;
	vec2 gv = fract(uv) - 0.5;
	vec2 id = floor(uv);
	float n = hash21(id);
	float c = 0.0;
	if (n > 0.45) {
		vec2 off = vec2(hash21(id + 1.3), hash21(id + 7.1)) - 0.5;
		float d = length(gv - off * 0.8);
		float size = mix(0.015, 0.05, hash21(id + 3.7));  // small, crisp points
		float tw = 0.7 + 0.3 * sin(TIME * twinkle_speed + n * 6.2831);
		c = smoothstep(size, 0.0, d) * tw * brightness;
	}
	COLOR = vec4(tint.rgb * c, c);
}
