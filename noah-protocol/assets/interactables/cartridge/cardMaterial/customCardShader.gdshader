shader_type spatial;

uniform sampler2D mainTexture : filter_nearest;
uniform sampler2D handleFilter : filter_nearest;
uniform sampler2D caseFilter : filter_nearest;
uniform sampler2D indicAFilter : filter_nearest;
uniform sampler2D indicBFilter : filter_nearest;

uniform vec4 handleColor : source_color;
uniform vec4 caseColor : source_color;
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
	
	vec4 emisionTex1 = texture(indicAFilter, UV);
	vec4 emisionTex2 = texture(indicBFilter, UV);
	
	emisionTex1 = indicAColor * emisionTex1;
	emisionTex2 = indicBColor * emisionTex2;
	
	vec4 emission = emisionTex1 + emisionTex2;
	
	EMISSION = emission.rgb;
	
	vec3 mainAdbedo = mainTex.rgb;
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * caseColor.rgb, cFilter.r);
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * handleColor.rgb, hFilter.r);
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * indicAColor.rgb, iAFilter.r);
	mainAdbedo = mix(mainAdbedo, mainTex.rgb * indicBColor.rgb, iBFilter.r);
	
	ALBEDO = mainAdbedo;
}