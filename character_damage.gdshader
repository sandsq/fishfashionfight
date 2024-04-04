shader_type canvas_item;

uniform bool active = true;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 previouscolor = texture(TEXTURE, UV);
	vec4 redcolor = vec4(1.0, 0.2, 0.25, previouscolor.a);
	vec4 newcolor = previouscolor;
	if (active == true)
	{
		newcolor = redcolor;
	}
	COLOR = newcolor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
