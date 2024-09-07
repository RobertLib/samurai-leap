shader_type canvas_item;

uniform float wave_speed = 1.0;
uniform float wave_amplitude = 5.0;
uniform float wave_frequency = 2.0;
uniform float time : hint_range(0.0, 10.0) = 0.0;

void fragment() {
	vec2 uv = UV;

	uv.x += sin(uv.x * wave_frequency + time * wave_speed) * wave_amplitude / 400.0;
	uv.y += sin(uv.x * wave_frequency + time * wave_speed) * wave_amplitude / 600.0;

	COLOR = texture(TEXTURE, uv);
}