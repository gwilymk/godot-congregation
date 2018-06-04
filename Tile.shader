shader_type canvas_item;

uniform float greyscale;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	float rms = length(current_color.xyz) / 3.0;
	COLOR = (current_color + (greyscale * rms)) / (1.0 + greyscale);
}