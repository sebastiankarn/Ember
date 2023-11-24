shader_type canvas_item;

uniform float outline_width = 1.0;
uniform vec4 outline_color : source_color;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float a;

	float alpha = 0.0;
	
	a = texture(TEXTURE, UV + vec2(0.0, -outline_width) * ps).a;
	alpha = max(a, alpha);

	a = texture(TEXTURE, UV + vec2(0.0, outline_width) * ps).a;
	alpha = max(a, alpha);

	a = texture(TEXTURE, UV + vec2(-outline_width, 0.0) * ps).a;
	alpha = max(a, alpha);

	a = texture(TEXTURE, UV + vec2(outline_width, 0.0) * ps).a;
	alpha = max(a, alpha);

	if (alpha > col.a) {
		COLOR = outline_color;
	} else {
		COLOR = col;
	}
}
