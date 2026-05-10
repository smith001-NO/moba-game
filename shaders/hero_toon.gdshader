shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.18, 0.18, 0.22, 1.0);
uniform vec4 rim_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform float rim_strength : hint_range(0.0, 2.0) = 0.25;
uniform float metallic_amount : hint_range(0.0, 1.0) = 0.0;
uniform float roughness_amount : hint_range(0.0, 1.0) = 0.48;
uniform float emission_strength : hint_range(0.0, 3.0) = 0.0;

void fragment() {
    ALBEDO = base_color.rgb;
    METALLIC = metallic_amount;
    ROUGHNESS = roughness_amount;
    float rim = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.2);
    EMISSION = rim_color.rgb * rim * rim_strength + base_color.rgb * emission_strength;
}

void light() {
    float ndotl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
    float band = 0.28;
    if (ndotl > 0.72) {
        band = 1.0;
    } else if (ndotl > 0.38) {
        band = 0.62;
    }
    DIFFUSE_LIGHT += mix(shadow_color.rgb, base_color.rgb, band) * ATTENUATION;
    float spec = pow(max(dot(reflect(-LIGHT, NORMAL), VIEW), 0.0), 24.0);
    SPECULAR_LIGHT += vec3(step(0.72, spec)) * ATTENUATION * 0.35;
}
