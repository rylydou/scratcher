shader_type canvas_item;

uniform float vignette_intensity = 0.4;

float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity);
}

void fragment(){
	float vig = (1.-vignette(SCREEN_UV));
	
	COLOR.a = vig;
}