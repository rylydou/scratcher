shader_type canvas_item;

uniform float radius = 1.0;
uniform float border = 0.1;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float s = SCREEN_PIXEL_SIZE.x*2.0;
	
	float l = length(UV - center);
	COLOR.a *= smoothstep(s, 0.0, abs(l - radius*.5 + border*0.25 + s) - border*0.25);
}
