shader_type canvas_item;

uniform float carb_master: hint_range(-10.0, 10.0) = 1.0;
uniform vec2 carb_red = vec2(0.0, 0.0);
uniform vec2 carb_green = vec2(3.0, 0.0);
uniform vec2 carb_blue = vec2(-3.0, 0.0);

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	float r = texture(SCREEN_TEXTURE, SCREEN_UV + SCREEN_PIXEL_SIZE*carb_red*carb_master, 0.0).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV + SCREEN_PIXEL_SIZE*carb_green*carb_master, 0.0).g;
	float b = texture(SCREEN_TEXTURE, SCREEN_UV + SCREEN_PIXEL_SIZE*carb_blue*carb_master, 0.0).b;
	
	COLOR.rgb *= vec3(r, g, b);
}
