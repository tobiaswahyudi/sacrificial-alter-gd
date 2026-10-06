shader_type canvas_item;
render_mode world_vertex_coords;

#include "res://shader/noise3.gdshaderinc"

varying vec2 world_pos;

uniform float noise_period = 0.001;
uniform float time_period = 0.01;
uniform float displace_amp = 1;

uniform vec4 modulator : source_color;

// Simple pseudo-random hash function
float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Basic value noise implementation
float noise(vec2 st) {
	vec2 i = floor(st);
	vec2 f = fract(st);

	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));

	vec2 u = smoothstep(0.0, 1.0, f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void vertex() {
	world_pos = VERTEX;
}

void fragment() {
	vec2 seed = world_pos * noise_period;

	// seed = vec2(seed.x, seed.y, TIME);
	float dx = cnoise(vec3(seed, TIME * time_period));
	float dy = cnoise(vec3(seed.y * 0.7123 + 100.3123, seed.x * 0.93123 + 1321.123, TIME * time_period));

	vec2 displacement = vec2(dx, dy) * displace_amp;
	// float displacement = cnoise(vec3(world_pos, 0.0));

	vec4 tex_color = texture(TEXTURE, UV + displacement);
	COLOR = tex_color * modulator;
	// COLOR.rg = displacement;
	// COLOR.b = 0.0;
}