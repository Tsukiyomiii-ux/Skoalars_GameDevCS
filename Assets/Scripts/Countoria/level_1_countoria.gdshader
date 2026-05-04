shader_type canvas_item;

// This allows the shader to "see" the game behind the ColorRect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Controls blur amount (2.0 is usually the "sweet spot")
uniform float lod: hint_range(0.0, 5.0) = 2.0;

// Controls darkness (0.3 - 0.5 works best for a "dimmed" background)
uniform float dark_intensity: hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // 1. Grab the pixels from the screen behind the ColorRect with blur (lod)
    vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
    
    // 2. Darken the RGB values
    color.rgb *= dark_intensity;
    
    // 3. Keep the alpha at 1.0 so it fully covers the screen
    color.a = 1.0;
    
    COLOR = color;
}
