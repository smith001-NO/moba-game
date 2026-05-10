shader_type spatial;
render_mode diffuse_toon, specular_toon, cull_back;

uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.28, 0.28, 0.34, 1.0);
uniform vec4 rim_color : source_color = vec4(0.65, 0.85, 1.0, 1.0);
uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_strength : hint_range(0.0, 3.0) = 0.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.55;
uniform float rim_strength : hint_range(0.0, 2.0) = 0.45;

void fragment() {
    vec3 n = normalize(NORMAL);
    vec3 v = normalize(VIEW);
    float facing = clamp(dot(n, vec3(0.25, 0.85, 0.45)), 0.0, 1.0);
    float level = 0.34;
    if (facing > 0.72) {
        level = 1.0;
    } else if (facing > 0.38) {
        level = 0.68;
    }
    vec3 color = mix(shadow_color.rgb, base_color.rgb, level);
    float rim = pow(1.0 - clamp(dot(n, -v), 0.0, 1.0), 2.35) * rim_strength;
    ALBEDO = color + rim_color.rgb * rim;
    ALPHA = base_color.a;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    EMISSION = emission_color.rgb * emission_strength;
}
