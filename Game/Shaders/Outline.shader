shader_type canvas_item;
render_mode unshaded;

uniform float width : hint_range(0.0, 30.0);
uniform vec4  color : hint_color;

void fragment() {
    vec4 curr = texture(TEXTURE,UV);
	float alpha = curr.a;
	curr = vec4(1.0) - curr;
	curr.a = alpha;
	COLOR = curr;
}
