shader_type canvas_item;

// Captures the game screen behind the ColorRect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Set to 2.0 or 3.0 for a nice blur
uniform float lod: hint_range(0.0, 5.0) = 2.5;

// Set to 0.4 or 0.5 to make it dark
uniform float dark_intensity: hint_range(0.0, 1.0) = 0.4;

void fragment() {
    vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
    color.rgb *= dark_intensity; // Apply darkening
    color.a = 1.0; // Ensure it's opaque
    COLOR = color;
}