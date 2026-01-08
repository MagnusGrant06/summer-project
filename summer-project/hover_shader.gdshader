shader_type spatial;

void vertex() {
}

void fragment() {
	// Called for every pixel the material is visible on.
		ALBEDO = vec3(100,255,0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
