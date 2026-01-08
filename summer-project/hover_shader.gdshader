shader_type spatial;

void vertex() {
}

void fragment() {
	// Called for every pixel the material is visible on.
		ALBEDO = vec3(255,255,255);
		ALPHA = 0.002;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
