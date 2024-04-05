shader_type canvas_item;

// top right bottom left
uniform vec4 edge = vec4(0.0, 0.0, 
0.0, 0.0);
uniform vec4 hl_color = vec4(0.5, 0.9, 0.7, 0.5);
uniform vec2 grid_size = vec2(32.0, 32.0);
uniform vec2 atlas_pos = vec2(0.0, 0.0);
uniform vec2 atlas_size = vec2(32.0, 32.0);

uniform float border_thickness_px = 5.0; // pixels

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 region_from_texture(vec2 uv, vec2 size, vec4 region) {
	return  region.zw + uv / size * region.xy;
}

vec2 texture_from_region(vec2 uv, vec2 size, vec4 region) {
	return uv * size / region.xy - region.zw;
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	float sprite_width = 1.0 / TEXTURE_PIXEL_SIZE.x;
	float sprite_height = 1.0 / TEXTURE_PIXEL_SIZE.y;
	float border_thickness_x_uv = border_thickness_px / sprite_width;
	float border_thickness_y_uv = border_thickness_px / sprite_height;
	
	vec2 bounds_x_uv = vec2(atlas_pos.x / sprite_width, (atlas_pos.x + grid_size.x) / sprite_width);
	vec2 bounds_y_uv = vec2(atlas_pos.y / sprite_height, (atlas_pos.y + grid_size.y) / sprite_height);
	bool horz_region = (UV.x >= bounds_x_uv[0] + border_thickness_x_uv) && (UV.x <= bounds_x_uv[1] - border_thickness_x_uv);
	bool vert_region = (UV.y >= bounds_y_uv[0] + border_thickness_y_uv) && (UV.y <= bounds_y_uv[1] - border_thickness_y_uv);
	if (edge.r >= 0.99) {
		if ((UV.y <= bounds_y_uv[0] + border_thickness_y_uv) && horz_region) {
			COLOR = hl_color;
		}
	}
	if (edge.g >= 0.99) {
		if ((UV.x >= bounds_x_uv[1] - border_thickness_x_uv) && vert_region) {
			COLOR = hl_color;
		}
	}
	if (edge.b >= 0.99) {
		if ((UV.y >= bounds_y_uv[1] - border_thickness_y_uv) && horz_region) {
			COLOR = hl_color;
		}
	}
	if (edge.a >= 0.99) {
		if ((UV.x <= bounds_x_uv[0] + border_thickness_x_uv) && vert_region) {
			COLOR = hl_color;
		}
	}
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
