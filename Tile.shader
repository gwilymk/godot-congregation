shader_type canvas_item;

uniform bool is_greyscale;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	if (is_greyscale) {
		float rms = length(current_color.xyz) / 3.0;
		COLOR = (current_color + rms) / 2.0;
	} else {
		COLOR = current_color;
	}
}