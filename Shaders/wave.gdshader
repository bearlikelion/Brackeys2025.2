shader_type canvas_item;

uniform bool  shaking        = false;
uniform float amplitude_px   = 1.0;   // shake amplitude in pixels (region pixels)
uniform float noise_scale    = 20.0;
uniform float noise_speed    = 20.0;

uniform vec2  region_size_px = vec2(64.0, 64.0); // size of the visible frame
uniform float edge_margin_px = 2.0;              // inner border without shake

// --- noise helpers ---
float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123); }
float noise(vec2 p){
    vec2 i = floor(p), f = fract(p);
    float a = hash(i), b = hash(i+vec2(1,0));
    float c = hash(i+vec2(0,1)), d = hash(i+vec2(1,1));
    vec2 u = f*f*(3.0-2.0*f);
    return mix(a,b,u.x) + (c-a)*u.y*(1.0-u.x) + (d-b)*u.x*u.y;
}

vec2 px_to_uv(vec2 px){ return px / region_size_px; }

void fragment(){
    vec2 uv = UV; // 0..1 inside the region/frame

    // Compute safe area in UV, include amplitude so shaking never hits the edge.
    float safe_px = max(edge_margin_px, amplitude_px + 1.0); // +1px headroom
    vec2  uv_pad  = px_to_uv(vec2(safe_px));
    vec2  uv_min  = uv_pad;
    vec2  uv_max  = vec2(1.0) - uv_pad;

    // Feather width ~1px in UV to avoid hard seam
    float feather = max(px_to_uv(vec2(1.0)).x, px_to_uv(vec2(1.0)).y);

    // Mask 0 at edges → 1 in interior (smooth)
    float mx = smoothstep(0.0, feather, uv.x - uv_min.x) * smoothstep(0.0, feather, uv_max.x - uv.x);
    float my = smoothstep(0.0, feather, uv.y - uv_min.y) * smoothstep(0.0, feather, uv_max.y - uv.y);
    float interior_mask = mx * my;

    vec2 uv2 = uv;

    if (shaking && interior_mask > 0.0){
        float nx = noise(uv * noise_scale + vec2(TIME * noise_speed, 0.0));
        float ny = noise(uv * noise_scale + vec2(0.0, TIME * noise_speed));
        vec2 dir = normalize(vec2(nx * 2.0 - 1.0, ny * 2.0 - 1.0));

        // offset in **region pixels**, convert to UV
        uv2 = uv + dir * px_to_uv(vec2(amplitude_px));

        // Hard clamp to safe interior to prevent sampling outside the frame
        uv2 = clamp(uv2, uv_min, uv_max);
    }

    vec4 shaken = texture(TEXTURE, uv2);
    vec4 plain  = texture(TEXTURE, clamp(uv, uv_min, uv_max));
    // Blend so edges stay stable; interior gets shake
    COLOR = mix(plain, shaken, interior_mask);
}
