shader_type canvas_item;

uniform float brightness: hint_range(0.0, 1.0);

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    c.rgb += vec3(brightness);
    COLOR = c;
}