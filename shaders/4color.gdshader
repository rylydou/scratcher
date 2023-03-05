shader_type canvas_item;

uniform vec4 topleft:source_color =   vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 topright:source_color =  vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 bottomleft:source_color= vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 bottomright:source_color=vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 top = mix(topleft, topright, SCREEN_UV.x);
	vec4 bottom = mix(bottomleft, bottomright, SCREEN_UV.x);
	COLOR =  mix(top, bottom, SCREEN_UV.y) *0.2;
}