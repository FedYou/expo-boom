
shader_type canvas_item;

uniform float brightness : hint_range(0.0, 3.0) = 0.5;
uniform float darkness_threshold : hint_range(0.0, 1.0) = 0.15;
uniform float fade_range : hint_range(0.001, 1.0) = 0.25;

uniform float glow_strength : hint_range(0.0, 2.0) = 0.3;
uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.6, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

// Intensidad del difuminado
uniform float blur_strength : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * blur_strength;

    // Difuminado usando 9 muestras
    vec4 tex = texture(TEXTURE, UV) * 4.0;

    tex += texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)) * 2.0;
    tex += texture(TEXTURE, UV - vec2(pixel_size.x, 0.0)) * 2.0;
    tex += texture(TEXTURE, UV + vec2(0.0, pixel_size.y)) * 2.0;
    tex += texture(TEXTURE, UV - vec2(0.0, pixel_size.y)) * 2.0;

    tex += texture(TEXTURE, UV + pixel_size) * 1.0;
    tex += texture(TEXTURE, UV - pixel_size) * 1.0;
    tex += texture(TEXTURE, UV + vec2(pixel_size.x, -pixel_size.y));
    tex += texture(TEXTURE, UV + vec2(-pixel_size.x, pixel_size.y));

    tex /= 16.0;

    float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

    float alpha_mask = smoothstep(
        darkness_threshold,
        darkness_threshold + fade_range,
        luminance
    );

    vec3 bright_color = tex.rgb * (1.0 + brightness);

    vec3 final_color = mix(
        bright_color,
        bright_color * glow_color.rgb,
        glow_strength
    );

COLOR = vec4(final_color, tex.a * alpha_mask * opacity);
}
