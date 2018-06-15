shader_type canvas_item;

uniform vec3 color;

void fragment() {
       vec4 current_color = texture(TEXTURE, UV);
       if (current_color.a == 1.0 && current_color.g == 0.0 && current_color.r == current_color.b) {
               COLOR = vec4(color * current_color.x, 1);
       } else {
               COLOR = current_color;
       }
}
