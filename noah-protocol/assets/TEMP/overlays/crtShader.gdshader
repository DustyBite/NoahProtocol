shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float curvature = 7.0;
uniform float vignette_strength = 0.3; // Even lower default
uniform float vignette_power = 2.0;
uniform float scanline_intensity = 0.1;

void fragment() {
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	vec2 uv_offset = centered_uv.yx / curvature;
	vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
	
	// Cutoff for screen edges
	vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));
	
	// Scanlines
	float scanline = sin(warped_uv.y * 600.0) * scanline_intensity + (1.0 - scanline_intensity);
	vec3 scanlines = vec3(scanline);
	
	// FIX: Rectangular vignette - uses max of x and y distance instead of circular length
	// This creates a vignette that follows the screen edges more naturally
	float vignette_dist = max(abs(centered_uv.x), abs(centered_uv.y));
	float vignette = pow(vignette_dist, vignette_power) * vignette_strength;
	
	// Sample screen texture
	vec3 screen_color = textureLod(screen_texture, (warped_uv + 1.0) / 2.0, 0.2).rgb;
	
	// Apply effects
	screen_color *= cutoff;
	screen_color *= scanlines;
	screen_color -= vignette;
	
	COLOR = vec4(screen_color, 1.0);
}