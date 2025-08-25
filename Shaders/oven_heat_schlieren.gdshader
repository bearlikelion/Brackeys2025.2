shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D noise_texture : hint_default_white;

uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float turbulence_scale : hint_range(0.5, 10.0) = 3.0;
uniform float flow_speed : hint_range(0.0, 2.0) = 0.5;
uniform float vertical_rise_speed : hint_range(0.0, 2.0) = 0.8;
uniform float shimmer_frequency : hint_range(1.0, 20.0) = 8.0;
uniform float depth_fade_distance : hint_range(0.0, 10.0) = 2.0;
uniform float edge_softness : hint_range(0.0, 1.0) = 0.3;
uniform vec2 distortion_direction = vec2(0.3, 1.0);
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.003;


vec3 sample_noise_3d(vec2 uv, float time) {
    vec3 noise1 = texture(noise_texture, uv * turbulence_scale + vec2(time * flow_speed, time * vertical_rise_speed)).rgb;
    vec3 noise2 = texture(noise_texture, uv * turbulence_scale * 2.0 - vec2(time * flow_speed * 0.7, time * vertical_rise_speed * 1.2)).rgb;
    vec3 noise3 = texture(noise_texture, uv * turbulence_scale * 4.0 + vec2(time * flow_speed * 0.3, time * vertical_rise_speed * 0.5)).rgb;
    
    return (noise1 * 0.5 + noise2 * 0.3 + noise3 * 0.2) - 0.5;
}


float calculate_depth_fade(float depth) {
    return 1.0 - smoothstep(0.0, depth_fade_distance, depth);
}


vec2 calculate_distortion(vec2 uv, float time, float depth_fade) {
    vec3 noise = sample_noise_3d(uv, time);
    
    float shimmer = sin(uv.y * shimmer_frequency + time * 3.0) * 0.5 + 0.5;
    shimmer *= sin(uv.x * shimmer_frequency * 0.7 + time * 2.0) * 0.5 + 0.5;
    
    vec2 base_distortion = noise.xy * distortion_strength;
    base_distortion += vec2(noise.z * 0.3, noise.z) * distortion_strength * 0.5;
    
    base_distortion *= distortion_direction;
    base_distortion *= (1.0 + shimmer * 0.3);
    
    float edge_fade = smoothstep(0.0, edge_softness, min(uv.x, 1.0 - uv.x)) * 
                      smoothstep(0.0, edge_softness, min(uv.y, 1.0 - uv.y));
    
    return base_distortion * depth_fade * edge_fade;
}


void fragment() {
    float depth = texture(depth_texture, SCREEN_UV).r;
    float linear_depth = 1.0 / (1.0 - depth);
    float depth_fade = calculate_depth_fade(linear_depth);
    
    vec2 distortion = calculate_distortion(SCREEN_UV, TIME, depth_fade);
    
    vec2 distorted_uv = SCREEN_UV + distortion;
    
    vec3 color;
    if (chromatic_aberration > 0.0) {
        float r = texture(screen_texture, distorted_uv + vec2(chromatic_aberration, 0.0) * depth_fade).r;
        float g = texture(screen_texture, distorted_uv).g;
        float b = texture(screen_texture, distorted_uv - vec2(chromatic_aberration, 0.0) * depth_fade).b;
        color = vec3(r, g, b);
    } else {
        color = texture(screen_texture, distorted_uv).rgb;
    }
    
    ALBEDO = color;
    ALPHA = 1.0;
}