shader_type canvas_item;

// This allows the shader to "see" the game behind the ColorRect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// This controls how blurry it is (0 is clear, 5 is very blurry)
uniform float lod: hint_range(0.0, 5.0) = 2.0;

void fragment() {
    // textureLod takes the screen image and applies the blur level (lod)
    vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
    
    // This applies the result to your ColorRect
    COLOR = color;
}