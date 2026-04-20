shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec2 screen_size = vec2(16.0, 9.0);
uniform float screenSizeMultiplier = 1.0;
uniform float brightness_boost = 2.5;
uniform float bleed = 0.3;
uniform float effect_strength : hint_range(0.0, 1.0) = 0.25;
uniform float gap_strength : hint_range(0.0, 1.0) = 0.5;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	vec2 scaled_size = screen_size * screenSizeMultiplier;

	vec2 pixel = SCREEN_UV * scaled_size;
	float offset = 1.0 / scaled_size.x;
	vec4 base = texture(screen_texture, SCREEN_UV);
	float r   = texture(screen_texture, SCREEN_UV + vec2(-offset, 0.0)).r;
	float g   = base.g;
	float b   = texture(screen_texture, SCREEN_UV + vec2( offset, 0.0)).b;

	// Triad width matches row height so each subpixel is a tall rectangle
	float triad_width = scaled_size.y / scaled_size.x * 3.0;

	// Shadow mask row stagger (offset by half a triad)
	float row = floor(pixel.y);
	float row_offset = mod(row, 2.0) * (triad_width * 0.5);

	// Column and triad index in triad-space
	float col = floor((pixel.x + row_offset) / triad_width * 3.0);
	float triad = mod(col, 3.0);

	float r_mask = float(triad == 0.0);
	float g_mask = float(triad == 1.0);
	float b_mask = float(triad == 2.0);

	// Sub-position within the current subpixel column (0.0–1.0)
	float subpos = fract((pixel.x + row_offset) / triad_width * 3.0);
	float left_bleed  = smoothstep(0.5, 0.0, subpos);
	float right_bleed = smoothstep(0.5, 1.0, subpos);

	float left_triad  = mod(col - 1.0, 3.0);
	float right_triad = mod(col + 1.0, 3.0);

	float r_out = r * r_mask
				+ r * float(left_triad  == 0.0) * left_bleed  * bleed
				+ r * float(right_triad == 0.0) * right_bleed * bleed;

	float g_out = g * g_mask
				+ g * float(left_triad  == 1.0) * left_bleed  * bleed
				+ g * float(right_triad == 1.0) * right_bleed * bleed;

	float b_out = b * b_mask
				+ b * float(left_triad  == 2.0) * left_bleed  * bleed
				+ b * float(right_triad == 2.0) * right_bleed * bleed;

	// Triad gap mask (vertical, one per full triad)
	float triad_pos = fract((pixel.x + row_offset) / triad_width);
	float h_gap = smoothstep(0.0, 0.08, triad_pos) * (1.0 - smoothstep(0.92, 1.0, triad_pos));
	float gap_mask = mix(1.0, h_gap, gap_strength);

	// Scanline gap mask (horizontal, one per row)
	float row_pos = fract(pixel.y);
	float v_gap = smoothstep(0.0, 0.1, row_pos) * (1.0 - smoothstep(0.9, 1.0, row_pos));
	float scanline_mask = mix(1.0, v_gap, scanline_strength);

	vec3 crt_color = vec3(r_out, g_out, b_out) * brightness_boost * gap_mask * scanline_mask;
	vec3 final_color = mix(base.rgb, crt_color, effect_strength);

	COLOR = vec4(final_color, base.a);
}