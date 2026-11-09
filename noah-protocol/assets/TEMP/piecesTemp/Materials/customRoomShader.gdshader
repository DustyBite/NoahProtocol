shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back;

group_uniforms Textures.Base;
uniform sampler2D mainTexture : filter_nearest;
group_uniforms Textures.Surface;
uniform sampler2D metallicTexture : filter_nearest, hint_default_black;
uniform sampler2D roughnessTexture : filter_nearest;
group_uniforms Textures.Masks;
uniform sampler2D lightFilter : filter_nearest, hint_default_black;
uniform sampler2D alphaFilter : filter_nearest, hint_default_white;

group_uniforms Colors;
uniform vec4 lightColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);

group_uniforms Fog;
uniform vec4 fogColor : source_color = vec4(0.8, 0.85, 0.9, 1.0);
// Minimum opacity of the glass. Higher = foggier / less see-through.
uniform float minAlpha : hint_range(0.0, 1.0) = 0.25;
// How strongly clear areas get tinted toward the fog color.
uniform float fogAmount : hint_range(0.0, 1.0) = 0.5;
// Extra roughness in the fogged areas so reflections look diffused.
uniform float fogRoughness : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec4 mainTex = texture(mainTexture, UV);
	vec4 lFilter = texture(lightFilter, UV);
	float mask = texture(alphaFilter, UV).r; // 1 = solid/dirty, 0 = clear glass

	// Emission and albedo (same as before)
	EMISSION = mainTex.rgb * (lightColor.rgb * lFilter.r);
	vec3 albedo = mix(mainTex.rgb, mainTex.rgb * lightColor.rgb, lFilter.r);

	// Tint the clearer parts toward the fog color; dirt (high mask) keeps its own color
	float clearness = 1.0 - mask;
	albedo = mix(albedo, fogColor.rgb, clearness * fogAmount);
	ALBEDO = albedo;

	// Fogged areas are rougher so they scaatter light instead of mirroring it
	float baseRough = texture(roughnessTexture, UV).r;
	ROUGHNESS = mix(baseRough, max(baseRough, fogRoughness), clearness);
	METALLIC = texture(metallicTexture, UV).r;

	// Never fully clear: remap mask into [minAlpha, 1]
	ALPHA = mix(minAlpha, 1.0, mask);
}