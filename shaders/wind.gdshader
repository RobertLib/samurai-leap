shader_type canvas_item;

uniform float wind_strength : hint_range(0.0, 2.0) = 1.0;
uniform float wind_speed : hint_range(0.0, 10.0) = 2.0;

void vertex() {
	VERTEX.x += sin(TIME * wind_speed + VERTEX.y) * wind_strength;
}
