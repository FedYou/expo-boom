
shader_type canvas_item;

uniform vec2 cell_size = vec2(32.0, 32.0);
uniform vec4 grid_color : source_color = vec4(0.3, 0.8, 0.4, 0.8);
uniform float line_width = 1.0;

void fragment() {
    // Coordenadas locales del objeto.
    vec2 pos = VERTEX;

    // Distancia al borde de cada celda.
    vec2 grid = abs(fract(pos / cell_size) - 0.5) * cell_size;

    // Dibujar líneas.
    float line_x = 1.0 - step(line_width, grid.x);
    float line_y = 1.0 - step(line_width, grid.y);
    float line = max(line_x, line_y);

    // Mantener el color original y dibujar la cuadrícula.
    COLOR.rgb = mix(COLOR.rgb, grid_color.rgb, line * grid_color.a);
}
