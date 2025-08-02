// Shader by Rendoog

shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform vec4 shine_color : source_color = vec4(1.,1.,1.,1.);

// Control how often passes occur (passes per second),
// and how long each shine takes to sweep across the mesh.
uniform float passes_per_second : hint_range(0.0, 5.0, 0.1) = 0.5;
uniform float pass_duration      : hint_range(0.01, 5.0, 0.01) = 0.4;

// Controls width of the glow strip
uniform float edge_width         : hint_range(0.0, 1.0, 0.01) = 0.1;

// Controls how tightly shine wraps (z‑spacing)
uniform float cycle_interval     : hint_range(0.1, 10.0, 0.1) = 1.0;

// Orientation of the shine relative to world axes
uniform float shine_angle_x      : hint_range(-90.0, 90.0, 5.0) = 0.0;
uniform float shine_angle_y      : hint_range(-90.0, 90.0, 5.0) = 0.0;
uniform float shine_angle_z      : hint_range(-90.0, 90.0, 5.0) = 0.0;

mat3 rot_x(float a) {
    float c = cos(radians(a)), s = sin(radians(a));
    return mat3(vec3(1,0,0), vec3(0,c,-s), vec3(0,s,c));
}
mat3 rot_y(float a) {
    float c = cos(radians(a)), s = sin(radians(a));
    return mat3(vec3(c,0,s), vec3(0,1,0), vec3(-s,0,c));
}
mat3 rot_z(float a) {
    float c = cos(radians(a)), s = sin(radians(a));
    return mat3(vec3(c,-s,0), vec3(s,c,0), vec3(0,0,1));
}

void fragment() {
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX,1.0)).xyz;
    mat3 R = rot_x(shine_angle_x) * rot_y(shine_angle_y) * rot_z(shine_angle_z);
    vec3 p = R * world_pos;

    float period = passes_per_second > 0.0
        ? (1.0 / passes_per_second)
        : 1e6;

    float t = fract(TIME / period);

    // Skip the shine unless we’re within the pass window:
    if (t > pass_duration / period) {
        ALBEDO = shine_color.rgb;
        ALPHA  = 0.0;
    }

    // Normalized phase within the active pass (0 → 1):
    float phase = min(1.0, t * (period / pass_duration));
    // Advance shine across Z during pass only
    float frac_z = fract(p.z * cycle_interval); // in [0,1)
    float distance = abs(frac_z - phase);
    distance = min(distance, 1.0 - distance); // wrap around Z

    float glow = smoothstep(edge_width, 0.0, distance);

    ALBEDO = shine_color.rgb;
    ALPHA  = glow * shine_color.a * (1.0 - dot(NORMAL, VIEW));
}
