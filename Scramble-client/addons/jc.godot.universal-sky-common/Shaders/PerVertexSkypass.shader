/*========================================================
°                       Universal Sky.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Sky pass, per vertex atmosphere.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2020. MIT License.
°                   See: LICENSE Archive.
========================================================*/
shader_type spatial;
render_mode unshaded, depth_draw_never, cull_front, skip_vertex_transform;

// Sun.
uniform vec4 _sun_disk_color;
uniform float _sun_disk_size;
uniform vec3 _sun_direction;

// Moon.
uniform sampler2D _moon_texture;
uniform vec4 _moon_color: hint_color = vec4(1.0);
uniform float _moon_size;
uniform vec3 _moon_direction;
uniform mat3 _moon_matrix;

// x = contrast, y = tonemap level, exposure..
uniform vec3 _color_correction_params;
uniform vec4 _ground_color: hint_color;

// Background.
uniform sampler2D _background_texture: hint_albedo;
uniform vec4 _background_color;

// Stars Field.
uniform vec4 _stars_field_color;
uniform sampler2D _stars_field_texture: hint_albedo;
uniform float _stars_scintillation;
uniform float _stars_scintillation_speed;

uniform sampler2D _noise_tex: hint_albedo;
uniform mat3 _deep_space_matrix;

// Atmospheric Scattering.
uniform float _atm_darkness;
uniform float _atm_sun_intensity;
uniform vec4 _atm_day_tint: hint_color;
uniform vec4 _atm_horizon_light_tint: hint_color;
uniform vec4 _atm_night_tint: hint_color;

// x = ymultiplier, y= down offset, z = horizon offset.
uniform vec3 _atm_params = vec3(1.0, 0.0, 0.0);

// Sun mie phase.
uniform vec4 _atm_sun_mie_tint: hint_color;
uniform float _atm_sun_mie_intensity;
uniform vec4 _atm_moon_mie_tint: hint_color;
uniform float _atm_moon_mie_intensity;
uniform vec3 _atm_beta_ray;
uniform vec3 _atm_beta_mie;
uniform vec3 _atm_sun_partial_mie_phase;
uniform vec3 _atm_moon_partial_mie_phase;

const float kRAYLEIGH_ZENITH_LENGTH = 8.4e3;
const float kMIE_ZENITH_LENGTH = 1.25e3;

// Clouds.
uniform float _clouds_coverage;
uniform float _clouds_thickness;
uniform float _clouds_absorption;
uniform float _clouds_sky_tint_fade;
uniform float _clouds_intensity;
uniform float _clouds_size;
uniform vec2 _clouds_uv;
uniform float _clouds_offset_speed;
uniform vec2 _clouds_offset;
uniform sampler2D _clouds_texture;

// Common.
// Math Constants.
const float kPI          = 3.1415927f;
const float kINV_PI      = 0.3183098f;
const float kHALF_PI     = 1.5707963f;
const float kINV_HALF_PI = 0.6366198f;
const float kQRT_PI      = 0.7853982f;
const float kINV_QRT_PI  = 1.2732395f;
const float kPI4         = 12.5663706f;
const float kINV_PI4     = 0.0795775f;
const float k3PI16       = 0.1193662f;
const float kTAU         = 6.2831853f;
const float kINV_TAU     = 0.1591549f;
const float kE           = 2.7182818f;

float saturate(float value){
	return clamp(value, 0.0, 1.0);
}

vec3 saturateRGB(vec3 value){
	return clamp(value.rgb, 0.0, 1.0);
}

// pow3
vec3 contrastLevel(vec3 vec, float level){
	return mix(vec, vec * vec * vec, level);
}

vec3 tonemapPhoto(vec3 color, float exposure, float level){
	color.rgb *= exposure;
	return mix(color.rgb, 1.0 - exp(-color.rgb), level);
}

vec3 mul(mat3 mat, vec3 vec){
	vec3 ret;
	ret.x = dot(mat[0].xyz, vec.xyz);
	ret.y = dot(mat[1].xyz, vec.xyz);
	ret.z = dot(mat[2].xyz, vec.xyz);
	return ret;
}

vec4 mul44(mat4 mat, vec4 vec){
	vec4 ret;
	ret.x = dot(mat[0].xyzw, vec.xyzw);
	ret.y = dot(mat[1].xyzw, vec.xyzw);
	ret.z = dot(mat[2].xyzw, vec.xyzw);
	ret.w = dot(mat[3].xyzw, vec.xyzw);
	return ret;
}

vec2 equirectUV(vec3 norm){
	vec2 ret;
	ret.x = (atan(norm.x, norm.z) + kPI) * kINV_TAU;
	ret.y = acos(norm.y) * kINV_PI;
	return ret;
}

float random(vec2 uv){
	float ret = dot(uv, vec2(12.9898, 78.233));
	return fract(43758.5453 * sin(ret));
}

float disk(vec3 norm, vec3 coords, lowp float size){
	float dist = length(norm - coords);
	return 1.0 - step(size, dist);
}

float rayleighPhase(float mu){
	return k3PI16 * (1.0 + mu * mu);
}

float miePhase(float mu, vec3 partial){
	return kPI4 * (partial.x) * (pow(partial.y - partial.z * mu, -1.5));
}

void opticalDepth(float y, out float sr, out float sm){
	y = max(0.03, y + 0.03) + _atm_params.y;
	y = 1.0 / (y * _atm_params.x);
	sr = y * kRAYLEIGH_ZENITH_LENGTH;
	sm = y * kMIE_ZENITH_LENGTH;
}

// Paper based.
void _opticalDepth(float y, out float sr, out float sm)
{
	y = max(0.0, y);
	y = saturate(y * _atm_params.x);
	
	float zenith = acos(y);
	zenith = cos(zenith) + 0.15 * pow(93.885 - ((zenith * 180.0) / kPI), -1.253);
	zenith = 1.0 / (zenith + _atm_params.y);
	
	sr = zenith * kRAYLEIGH_ZENITH_LENGTH;
	sm = zenith * kMIE_ZENITH_LENGTH;
}

vec3 atmosphericScattering(float sr, float sm, vec2 mu, vec3 mult){
	vec3 betaMie = _atm_beta_mie;
	vec3 betaRay = _atm_beta_ray;
	
	vec3 extcFactor = saturateRGB(exp(-(betaRay * sr + betaMie * sm)));
	vec3 finalExtcFactor = mix(1.0 - extcFactor, (1.0 - extcFactor) * extcFactor, mult.x);
	
	float rayleighPhase = rayleighPhase(mu.x);
	vec3 BRT = betaRay * rayleighPhase;
	vec3 BMT = betaMie * miePhase(mu.x, _atm_sun_partial_mie_phase);
	BMT *= _atm_sun_mie_intensity * _atm_sun_mie_tint.rgb;
	
	vec3 BRMT = (BRT + BMT) / (betaRay + betaMie);
	vec3 scatter = _atm_sun_intensity * (BRMT * finalExtcFactor) * _atm_day_tint.rgb * mult.y;
	scatter = mix(scatter, scatter * (1.0 - extcFactor), _atm_darkness);
	
	vec3 lcol = mix(_atm_day_tint.rgb, _atm_horizon_light_tint.rgb, mult.x);
	vec3 nscatter = (1.0 - extcFactor) * _atm_night_tint.rgb;
	nscatter += miePhase(mu.y, _atm_moon_partial_mie_phase) * 
		_atm_moon_mie_tint.rgb * _atm_moon_mie_intensity * 0.005;
	return (scatter * lcol) + nscatter;
}

// Simple 2D clouds.
float noiseClouds(vec2 coords, vec2 offset)
{
	float a = textureLod(_clouds_texture, coords.xy * _clouds_uv + offset.x, 0.0).r;
	float b = textureLod(_clouds_texture, coords.xy * _clouds_uv + offset.y, 0.0).r;
	return (a + b) * 0.5;
}

float cloudsDensity(vec2 p, vec2 offset)
{
	float d = noiseClouds(p, offset);
	float c = 1.0 - _clouds_coverage;
	d = d - c;
	return saturate(d);
}

vec4 renderClouds(vec3 pos, float tm)
{
	pos.xy = pos.xz / pos.y;
	pos *= _clouds_size;
	vec2 wind = _clouds_offset.xy * (tm * _clouds_offset_speed);
	float density = cloudsDensity(pos.xy, wind);
	float sh = saturate(exp(-_clouds_absorption * density));
	float a = saturate(density * _clouds_thickness);
	return vec4(vec3(density*sh) * _clouds_intensity, a);
}

varying vec4 world_pos;
varying vec4 moon_coords;
varying vec3 deep_space_coords;
varying vec4 angle_mult;
varying vec3 vscatter;

void vertex(){
	vec4 vert = vec4(VERTEX, 0.0);
	
	// mvp * vec4(vert, 0.0)
	vec4 clip_pos = PROJECTION_MATRIX * inverse(CAMERA_MATRIX) * WORLD_MATRIX * vert;
	POSITION = clip_pos;
	POSITION.z = clip_pos.w; // Ignore far clip.
	
	world_pos = (WORLD_MATRIX * vert);
	moon_coords.xyz  = (_moon_matrix * VERTEX).xyz / _moon_size + 0.5;
	moon_coords.w = dot(world_pos.xyz, _moon_direction); 
	deep_space_coords.xyz = (_deep_space_matrix * VERTEX).xyz;
	angle_mult.x = saturate(1.0 - _sun_direction.y);
	angle_mult.y = saturate(_sun_direction.y + 0.45);
	angle_mult.z = saturate(-_sun_direction.y + 0.30);
	angle_mult.w = saturate(-_sun_direction.y + 0.60);
	
	// Atmospheric Scattering.
	vec3 nrm = normalize(world_pos).xyz;
	vec2 mu = vec2(dot(_sun_direction, nrm), dot(_moon_direction, nrm));
	float sr; float sm; opticalDepth(nrm.y + _atm_params.z, sr, sm);
	vscatter = atmosphericScattering(sr, sm, mu.xy, angle_mult.xyz);
}

void fragment(){
	vec3 col = vec3(0.0);
	vec3 ray = normalize(world_pos).xyz;
	float horizonBlend = saturate((ray.y - 0.03) * 10.0);
	vec3 scatter = vscatter.rgb;

	col.rgb += scatter.rgb;
	
	// Near Space.
	vec3 nearSpace = vec3(0.0);
	vec3 sunDisk = disk(ray, _sun_direction, _sun_disk_size) * _sun_disk_color.rgb * scatter.rgb;
	
	// Moon.
	vec4 moon = texture(_moon_texture, vec2(-moon_coords.x+1.0, moon_coords.y));
	moon.rgb = contrastLevel(moon.rgb * _moon_color.rgb, _moon_color.a);
	moon *= saturate(moon_coords.w);
	float moonMask = saturate(1.0 - moon.a);
	nearSpace = moon.rgb + (sunDisk.rgb * moonMask);
	col.rgb += nearSpace;
	
	vec3 deepSpace = vec3(0.0);
	vec2 deepSpaceUV = equirectUV(normalize(deep_space_coords));
	
	// Background.
	vec3 deepSpaceBackground = textureLod(_background_texture, deepSpaceUV, 0.0).rgb;
	deepSpaceBackground *= _background_color.rgb;
	deepSpaceBackground = contrastLevel(deepSpaceBackground, _background_color.a);
	deepSpace.rgb += deepSpaceBackground.rgb * moonMask;
	
	// Stars Field.
	float starsScintillation = textureLod(_noise_tex, UV + (TIME * _stars_scintillation_speed), 0.0).r;
	starsScintillation = mix(1.0, starsScintillation * 1.5, _stars_scintillation);
	
	vec3 starsField = textureLod(_stars_field_texture, deepSpaceUV, 0.0).rgb * _stars_field_color.rgb;
	starsField = saturateRGB(mix(starsField.rgb, starsField.rgb * starsScintillation, _stars_scintillation));
	//deepSpace.rgb -= saturate(starsField.r*10.0);
	deepSpace.rgb += starsField.rgb * moonMask;
	deepSpace.rgb *= angle_mult.z;
	col.rgb += deepSpace.rgb * horizonBlend;
	
	// Clouds.
	vec4 clouds = renderClouds(ray, TIME);
	clouds.a = saturate(clouds.a);
	clouds.rgb *= mix(mix(vec3(1.0), _atm_horizon_light_tint.rgb, angle_mult.x), 
		_atm_night_tint.rgb, angle_mult.w);
	
	clouds.a = mix(0.0, clouds.a, horizonBlend);
	col.rgb = mix(col.rgb, clouds.rgb + mix(vec3(0.0), scatter, _clouds_sky_tint_fade), clouds.a);
	col.rgb = mix(col.rgb, _ground_color.rgb * scatter, saturate((-ray.y - _atm_params.z)*100.0));
	col.rgb = tonemapPhoto(col.rgb, _color_correction_params.z, _color_correction_params.y);
	col.rgb = contrastLevel(col.rgb, _color_correction_params.x);
	
	ALBEDO = col.rgb;
}


