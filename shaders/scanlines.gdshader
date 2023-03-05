//---CRT Shader---
shader_type canvas_item;

uniform float carb_master: hint_range(-10.0, 10.0) = 1.0;
uniform vec2 carb_red = vec2(0.0, 0.0);
uniform vec2 carb_green = vec2(3.0, 0.0);
uniform vec2 carb_blue = vec2(-3.0, 0.0);

uniform float sl_count: hint_range(0, 1800) = 50.0;
uniform float sl_speed: hint_range(-10.0, 10.0) = -0.05;
uniform float sl_xfactor: hint_range(-1.0, 1.0) = 0.0;
uniform float sl_yfactor: hint_range(-1.0, 1.0) = 1.0;

uniform float sl_opacity: hint_range(0.0, 1.0) = 1.0;
uniform float sl_power: hint_range(0.0, 1.0) = 0.1;
uniform float sl_sharpness: hint_range(0.0, 10.0) = 0.9;
uniform float sl_bias: hint_range(-10.0, 10.0) = 0.1;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform float vignette_intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_rgb : source_color = vec4(0.0, 0.0, 0.0, 1.0);
float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_opacity);
}

void fragment()
{
	const vec2 PXS = SCREEN_PIXEL_SIZE;
	const vec2 SUV = SCREEN_UV;
	
	float r = texture(SCREEN_TEXTURE, SUV + PXS*carb_red*carb_master, 0.0).r;
	float g = texture(SCREEN_TEXTURE, SUV + PXS*carb_green*carb_master, 0.0).g;
	float b = texture(SCREEN_TEXTURE, SUV + PXS*carb_blue*carb_master, 0.0).b;
	
	//If you dont want scanlines you can just delete this part
	float s = sin(fract(SUV.x*sl_xfactor + SUV.y*sl_yfactor + TIME*sl_speed) * sl_count * PI * 2.0);
	s = (s*0.5 + 0.5)*sl_sharpness + sl_bias;
	vec4 scan_line = vec4(vec3(pow(s, sl_power)), 1.0);
	
	COLOR = vec4(r, g, b, 1.0)*(scan_line*sl_opacity);
}
