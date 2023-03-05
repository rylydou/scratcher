shader_type canvas_item;

uniform float sl_count: hint_range(0, 1800) = 50.0;
uniform float sl_speed: hint_range(-10.0, 10.0) = -0.05;
uniform float sl_xfactor: hint_range(-1.0, 1.0) = 0.0;
uniform float sl_yfactor: hint_range(-1.0, 1.0) = 1.0;

uniform float sl_opacity: hint_range(0.0, 1.0) = 1.0;
uniform float sl_power: hint_range(0.0, 1.0) = 0.1;
uniform float sl_sharpness: hint_range(0.0, 100.0) = 0.9;
uniform float sl_bias: hint_range(-10.0, 10.0) = 0.1;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment()
{
	//If you dont want scanlines you can just delete this part
	float s = sin(fract(SCREEN_UV.x*sl_xfactor + SCREEN_UV.y*sl_yfactor + TIME*sl_speed) * sl_count * PI * 2.0);
	s = (s*0.5 + 0.5)*sl_sharpness + sl_bias;
	float scan_line = pow(s, sl_power);
	
	COLOR.a = 1. - scan_line*sl_opacity;
}
