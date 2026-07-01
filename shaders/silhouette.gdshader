shader_type canvas_item;
// Flattens a sprite to one solid color (keeping only its alpha shape) so
// background debris reads as a dark silhouette regardless of the source
// art's own shading/color.

uniform vec4 tint : source_color = vec4(0.17, 0.18, 0.2, 1.0);

void fragment() {
	float a = texture(TEXTURE, UV).a;
	COLOR = vec4(tint.rgb, a * tint.a);
}
