shader_type canvas_item;
render_mode unshaded;

void fragment() {
    vec4 curr = texture(TEXTURE, UV);
	float alpha = curr.a;
	curr = vec4(1.0) - curr;
	curr.a = alpha;
	COLOR = curr;
}
