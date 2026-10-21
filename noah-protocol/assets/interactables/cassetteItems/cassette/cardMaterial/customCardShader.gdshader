shader_type spatial;

group_uniforms Textures.Base;
uniform sampler2D mainTexture : filter_nearest;
group_uniforms Textures.Surface;
uniform sampler2D alphaTexture : filter_nearest;
uniform sampler2D metallicTexture : filter_nearest, hint_default_black;
uniform sampler2D roughnessTexture : filter_nearest;
group_uniforms Textures.Masks;
uniform sampler2D handleFilter : filter_nearest;
uniform sampler2D caseFilter : filter_nearest;
uniform sampler2D indicAFilter : filter_nearest;
uniform sampler2D indicBFilter : filter_nearest;

group_uniforms Colors;
uniform vec4 handleColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 caseColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 indicAColor : source_color;
uniform vec4 indicBColor : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 mainTex = texture(mainTexture, UV);

	vec4 cFilter = texture(caseFilter, UV);
	vec4 hFilter = texture(handleFilter, UV);
	vec4 iAFilter = texture(indicAFilter, UV);
	vec4 iBFilter = texture(indicBFilter, UV);

	// 0 if the color is black (off), 1 otherwise
	float aOn = step(0.01, max(max(indicAColor.r, indicAColor.g), indicAColor.b));
	float bOn = step(0.01, max(max(indicBColor.r, indicBColor.g), indicBColor.b));

	// black color or black mask = no emission
	vec3 emission = mainTex.rgb * (indicAColor.rgb * iAFilter.r + indicBColor.rgb * iBFilter.r);
	EMISSION = emission;

	vec3 mainAdbedo = mainTex.rgb;
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * caseColor.rgb, cFilter.r);
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * handleColor.rgb, hFilter.r);
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * indicAColor.rgb, iAFilter.r * aOn);
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * indicBColor.rgb, iBFilter.r * bOn);

	ALBEDO = mainAdbedo;

	ROUGHNESS = texture(roughnessTexture, UV).r;
	METALLIC = texture(metallicTexture, UV).r;
	ALPHA = texture(alphaTexture, UV).r;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}