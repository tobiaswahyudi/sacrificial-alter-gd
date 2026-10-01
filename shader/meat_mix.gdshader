shader_type canvas_item;
render_mode world_vertex_coords;

uniform sampler2D bottom_layer : hint_default_black;
uniform float tex_width;
uniform float tex_height;


varying vec2 world_pos;

void vertex() {
    world_pos = VERTEX;
}

void fragment() {
    vec4 top_color = texture(TEXTURE, UV);
	float i_vx = floor(world_pos.x / tex_width);
	float vx = world_pos.x / tex_width - i_vx;
	float i_vy = floor(world_pos.y / tex_height);
	float vy = world_pos.y / tex_height - i_vy;
    vec4 bottom_color = texture(bottom_layer, vec2(vx, vy));
    
     //Multiply RGB values of both layers
    COLOR.rgb = bottom_color.rgb * top_color.rgb;
    
    // Combine alpha channels gracefully
    COLOR.a = bottom_color.a * top_color.a;
}