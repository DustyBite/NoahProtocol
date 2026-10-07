shader_type spatial;

uniform sampler2D mainTexture : filter_nearest;
uniform sampler2D handleFilter : filter_nearest;
uniform sampler2D caseFilter : filter_nearest;
uniform sampler2D indicAFilter : filter_nearest;
uniform sampler2D indicBFilter : filter_nearest;

uniform vec4 handleColor : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 texColor1 = texture(mainTexture, UV);
	vec4 texColor2 = texture(caseFilter, UV);
	
	vec4 emisionTex1 = texture(indicAFilter, UV);
	vec4 emisionTex2 = texture(indicBFilter, UV);
	
	emisionTex1 = handleColor*emisionTex1;
	emisionTex2 = handleColor*emisionTex2;
	
	vec4 emission = emisionTex1 + emisionTex2;
	EMISSION = emission.rgb;
	
	ALBEDO = texColor1.rgb;
}