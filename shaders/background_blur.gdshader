shader_type canvas_item;

uniform float blur_amount : hint_range(-2.0, 10.0);
uniform float mix_amount : hint_range(0.0, 1.0);
uniform vec4 color_over : source_color;

uniform float noise_size = 12.0;
uniform float noise_fps = 6.0;
uniform vec4 noise_color : source_color;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

void fragment() {
	vec2 screen_resolution = 1.0 / (SCREEN_PIXEL_SIZE * noise_size);
	
	vec4 blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	
	vec4 fin = mix(blurred, color_over, mix_amount);
	
	float noies_seed = fract(floor(TIME * noise_fps) / noise_fps);
	float noise = clamp(random((ceil(SCREEN_UV * screen_resolution) / screen_resolution) + noies_seed).x, 0.0, 1.0);
	fin.rgb += noise_color.rgb * noise * noise_color.a;
	
	COLOR = fin;
}