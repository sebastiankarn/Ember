shader_type canvas_item;

void fragment() {
    // Use UV.x, which ranges from 0.0 (left) to 1.0 (right) inside the ColorRect
    float gradient = UV.x;

    // Set the color to black with varying transparency (from left to right)
    COLOR = vec4(0.0, 0.0, 0.0, gradient * 1.5); // Adjust the multiplier for more opacity
}