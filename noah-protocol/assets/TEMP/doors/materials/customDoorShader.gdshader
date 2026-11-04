shader_type spatial;

group_uniforms Textures.Base;
uniform sampler2D mainTexture : filter_nearest;
group_uniforms Textures.Surface;
uniform sampler2D metallicTexture : filter_nearest, hint_default_black;
uniform sampler2D roughnessTexture : filter_nearest;
group_uniforms Textures.Masks;
uniform sampler2D lightFilter : filter_nearest;
uniform sampler2D scannerFilter : filter_nearest;
uniform sampler2D button1Filter : filter_nearest;
uniform sampler2D button2Filter : filter_nearest;

group_uniforms Colors;
uniform vec4 lightColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 scannerColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 button1Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 button2Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 mainTex = texture(mainTexture, UV);

	vec4 lFilter = texture(lightFilter, UV);
	vec4 sFilter = texture(scannerFilter, UV);
	vec4 b1Filter = texture(button1Filter, UV);
	vec4 b2Filter = texture(button2Filter, UV);

	// black color or black mask = no emission
	vec3 emission = mainTex.rgb * (lightColor.rgb * lFilter.r +
	scannerColor.rgb * sFilter.r +
	button1Color.rgb * b1Filter.r +
	button2Color.rgb * b2Filter.r);
	EMISSION = emission;

	vec3 mainAdbedo = mainTex.rgb;
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * lightColor.rgb, lFilter.r);

	ALBEDO = mainAdbedo;

	ROUGHNESS = texture(roughnessTexture, UV).r;
	METALLIC = texture(metallicTexture, UV).r;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}