shader_type canvas_item;

uniform vec2 strum_coords;

void fragment() {
	COLOR.a *= float(FRAGCOORD.y < strum_coords.y);
}
