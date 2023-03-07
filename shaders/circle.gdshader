shader_type canvas_item;

uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float border: hint_range(0.0, 1.0) = 0.1;

void fragment() {
	const vec2 center = vec2(.5, .5);
	const float s = SCREEN_PIXEL_SIZE.x*2.;
	
	float l = length(UV - center);
	float a = smoothstep(s, 0., abs(l - radius + border/2.+s) - border/2.);   
	COLOR.a = a;
}
