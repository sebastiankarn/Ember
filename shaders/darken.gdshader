shader_type canvas_item;

uniform bool darken = false;
uniform float mix_weight = 1.0;

void fragment() {
    vec4 texture_color = texture(TEXTURE,UV);
    if (darken) {
        vec3 black = vec3(0,0,0);
        vec3 darkened_texture_rgb = mix(texture_color.rgb, black, mix_weight);
        COLOR = vec4(darkened_texture_rgb.rgb, COLOR.a);
    } else {
        COLOR = texture_color;
    }
}