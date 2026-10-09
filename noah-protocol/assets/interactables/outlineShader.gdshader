shader_type spatial;
render_mode cull_front, depth_draw_always, unshaded;

uniform vec4 outlineColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outlineThickness : hint_range(0.0, 0.1) = 0.01;

uniform bool outlineToggle = false;

void vertex() {
	if (outlineToggle) {
		VERTEX += NORMAL * outlineThickness;
	}
}

void fragment() {
	if (outlineToggle) {
		ALBEDO = outlineColor.rgb;
		ALPHA = 1.0;
	} else {
		ALPHA = 0.0;
	}
}