shader_type canvas_item;
// render_mode world_vertex_coords;

#include "res://shader/noise3.gdshaderinc"

// varying vec2 world_pos;

uniform float noise_period = 0.001;

uniform float threshold = 1;
uniform float vicinity = 0.01;

uniform vec4 burn_color : source_color;

// void vertex() {
// 	world_pos = VERTEX;
// }

void fragment() {
	float noise = cnoise(vec3(VERTEX * noise_period, 0.0)) * 0.5 + 0.5;
	vec4 tex_color = texture(TEXTURE, UV);

    if(abs(noise - threshold) < vicinity) {
        COLOR = burn_color;
    } else if(noise > threshold) {
        COLOR.a = 0.0;
    } else {
	    COLOR = tex_color;
    }
    // COLOR.rgb = vec3(noise, noise, noise);
}