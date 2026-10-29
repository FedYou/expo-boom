
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.4, 0.8, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float glow_size : hint_range(1.0, 10.0) = 3.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Detectar los píxeles cercanos
    float glow = 0.0;
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * glow_size;

    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * pixel_size;
            float alpha = texture(TEXTURE, UV + offset).a;

            glow = max(glow, alpha);
        }
    }

    // Evitar que el brillo cubra el interior de la textura
    glow = max(glow - tex.a, 0.0);

    vec3 final_color = tex.rgb + glow_color.rgb * glow * glow_intensity;

    COLOR = vec4(final_color, max(tex.a, glow * glow_color.a * glow_intensity));
}
