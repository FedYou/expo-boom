shader_type canvas_item;

uniform float intensity : hint_range(0.0, 10.0) = 0.001;
uniform float speed : hint_range(1.0, 100.0) = 35.0;

void vertex() {
    VERTEX.x += sin(TIME * speed) * intensity;
    VERTEX.y += cos(TIME * speed * 1.3) * intensity;
}