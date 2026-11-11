
shader_type canvas_item;

uniform float blur_radius : hint_range(1.0, 20.0) = 7.0;
uniform float blur_strength : hint_range(0.0, 1.0) = 1.0;

uniform float cloud_softness : hint_range(0.1, 3.0) = 1.5;
uniform float scattering : hint_range(0.0, 2.0) = 0.8;
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.15;

float gaussian(float x, float sigma) {
    return exp(-(x * x) / (2.0 * sigma * sigma));
}

float cloud_blur(
    sampler2D tex,
    vec2 uv,
    vec2 pixel_size,
    float radius
) {
    vec2 pixel = pixel_size * radius;

    float alpha_sum = 0.0;
    float weight_sum = 0.0;

    for (int x = -5; x <= 5; x++) {
        for (int y = -5; y <= 5; y++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;

            float weight = gaussian(float(x), 2.5)
                         * gaussian(float(y), 2.5);

            float alpha = texture(tex, uv + offset).a;

            alpha_sum += alpha * weight;
            weight_sum += weight;
        }
    }

    return alpha_sum / weight_sum;
}

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    float blur_small = cloud_blur(
        TEXTURE, UV, TEXTURE_PIXEL_SIZE, blur_radius * 0.5
    );

    float blur_medium = cloud_blur(
        TEXTURE, UV, TEXTURE_PIXEL_SIZE, blur_radius
    );

    float blur_large = cloud_blur(
        TEXTURE, UV, TEXTURE_PIXEL_SIZE, blur_radius * 1.8
    );

    float cloud_alpha = mix(
        blur_small,
        blur_medium,
        0.55
    );

    cloud_alpha = mix(
        cloud_alpha,
        blur_large,
        scattering * 0.5
    );

    cloud_alpha = smoothstep(
        edge_threshold,
        1.0,
        cloud_alpha * cloud_softness
    );

    float edge = abs(original.a - blur_medium);

    float mask = smoothstep(0.0, 0.5, edge);

    float final_alpha = mix(
        original.a,
        cloud_alpha,
        mask * blur_strength
    );

    COLOR = vec4(original.rgb, final_alpha);
}
