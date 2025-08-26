shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float wiggleMult:hint_range(0.0, 0.01, 0.0001)=0.005;

void fragment( ){
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy / iResolution.xy;
	
	float x = sin(0.3*TIME+uv.y*21.0)*sin(0.7*TIME+uv.y*29.0)*sin(0.3+0.33*TIME+uv.y*31.0)*wiggleMult;
	
	COLOR = texture(screen_texture, vec2(x+uv.x, uv.y));
}