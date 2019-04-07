shader_type canvas_item;

uniform float blur = 3.0;
uniform float brightness = 0.6;
uniform float contrast = 0.6;
uniform float saturation = 1.0;

void fragment() {
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur).rgb;
	
	//c.rgb = mix(vec3(0.0), c.rgb, brightness);
	c.rgb = mix(vec3(0.5), c.rgb, contrast);
	c.rgb = mix(vec3(dot(vec3(1.0), c.rgb)*0.33333), c.rgb, saturation);
	
	COLOR.rgb = c;
}