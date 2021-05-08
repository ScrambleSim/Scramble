/*========================================================
°                       Universal Sky.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Moon render pass.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2020. MIT License.
°                   See: LICENSE Archive.
========================================================*/
shader_type spatial;
render_mode unshaded;

uniform sampler2D _texture: hint_albedo;
uniform vec3 _sun_direction = vec3(0.5);

float saturate(float value){
	return clamp(value, 0.0, 1.0);
}

/*vec3 mul(mat4 mat, vec3 vec){
	vec3 ret;
	ret.x = dot(mat[0].xyz, vec.xyz);
	ret.y = dot(mat[1].xyz, vec.xyz);
	ret.z = dot(mat[2].xyz, vec.xyz);
	return ret; 
}*/

varying vec3 normal;
void vertex(){
	//normal = mul(transpose(WORLD_MATRIX), VERTEX);
	normal = (WORLD_MATRIX * vec4(VERTEX, 0.0)).xyz;
}

void fragment(){
	float lightMult = saturate(max(0.0, dot(_sun_direction, normal)) * 2.0);
	ALBEDO = texture(_texture, UV).rgb;
	ALBEDO *= lightMult;
}