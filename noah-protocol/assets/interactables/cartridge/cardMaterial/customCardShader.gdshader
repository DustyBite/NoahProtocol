shader_type spatial;

uniform sampler2D mainTexture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = mainTexture
}