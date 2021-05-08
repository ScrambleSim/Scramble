tool
class_name SkyManager extends Node
"""========================================================
°                       Universal Sky.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Dynamic Skydome.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2020. MIT License.
°                   See: LICENSE Archive.
========================================================"""
#-------------------
# Resources.
#-------------------
# Shaders. 
var _SKYPASS_SHADER =\
preload("res://addons/jc.godot.universal-sky-common/Shaders/Skypass.shader")

var _PER_VERTEX_SKYPASS_SHADER =\
preload("res://addons/jc.godot.universal-sky-common/Shaders/PerVertexSkypass.shader")

var _SCATTER_FOG_PASS_SHADER =\
preload("res://addons/jc.godot.universal-sky-common/Shaders/ScatterFogPass.shader")

var _MOONPASS_SHADER =\
preload("res://addons/jc.godot.universal-sky-common/Shaders/SimpleMoon.shader")

# Textures.
var _DEFAULT_MOON_TEXTURE =\
preload("res://addons/jc.godot.universal-sky-common/Assets/ThirdParty/Graphics/Textures/MoonMap/MoonMap.png")

var _DEFAULT_BACKGROUND_TEXTURE =\
preload("res://addons/jc.godot.universal-sky-common/Assets/ThirdParty/Graphics/Textures/MilkyWay/Milkyway.jpg")

var _DEFAULT_STARS_FIELD_TEXTURE =\
preload("res://addons/jc.godot.universal-sky-common/Assets/ThirdParty/Graphics/Textures/MilkyWay/StarField.jpg")

var _DEFAULT_STARS_FIELD_NOISE_TEXTURE =\
preload("res://addons/jc.godot.universal-sky-common/Assets/MyAssets/Graphics/Textures/noise.jpg")

var _DEFAULT_CLOUDS_TEXTURE =\
preload("res://addons/jc.godot.universal-sky-common/Resources/SNoise.tres")

var _CLOUDS_CUMULUS_SHADER =\
preload("res://addons/jc.godot.universal-sky-common/Shaders/CloudsCumulus.shader")

var _CLOUDS_CUMULUS_TEXTURE =\
preload("res://addons/jc.godot.universal-sky-common/Assets/MyAssets/Graphics/Textures/noise2.png")

# Scenes.
var _MOON_RENDER =\
preload("res://addons/jc.godot.universal-sky-common/Scenes/Moon/MoonRender.tscn")

var _DEFAULT_SUN_MOON_LIGHT_CURVE_FADE =\
preload("res://addons/jc.godot.universal-sky-common/Resources/SunMoonLightFade.tres")

# Meshes.
var _sky_mesh:= SphereMesh.new()
var _clouds_mesh := SphereMesh.new()
var _fog_mesh:= QuadMesh.new()

# Materials.
var _skypass_material:= ShaderMaterial.new()
var _fogpass_material:= ShaderMaterial.new()
var _moonpass_material:= ShaderMaterial.new()
var _clouds_cumulus_material:= ShaderMaterial.new()

# Instances.
var _sky_node: MeshInstance = null
var _fog_node: MeshInstance = null
var _clouds_cumulus_node: MeshInstance = null
var _moon_instance: Viewport
var _moon_viewport_texture: ViewportTexture
var _moon_instance_transform: Spatial
var _moon_instance_mesh: MeshInstance
#-------------------
# Constants.
#-------------------
const _DEFAULT_ORIGIN:= Vector3(0.0000001, 0.0000001, 0.0000001)
const _MAX_EXTRA_CULL_MARGIN:= 16384.0
const _SKY_INSTANCE_NAME:= "SkyNode"
const _FOG_INSTANCE_NAME:= "FogNode"
const _CLOUDS_CUMULUS_INSTANCE_NAME:= "CloudsCumulus"
const _MOON_INSTANCE_NAME:= "MoonRender"
const _SUN_DIR_PARAM:= "_sun_direction"
const _MOON_DIR_PARAM:= "_moon_direction"
const _COLOR_CORRECTION_PARAMS:= "_color_correction_params"

#-------------------
# Properties
#-------------------
# Global
var _init_properties_ok: bool = false

var sky_visible:= true setget set_sky_visible
func set_sky_visible(value: bool) -> void:
	sky_visible = value
	if not _init_properties_ok: return 
	assert(_sky_node != null)
	_sky_node.visible = value

var skydome_radius: float = 10.0 setget set_skydome_radius
func set_skydome_radius(value: float) -> void:
	skydome_radius = value
	if not _init_properties_ok: return
	assert(_sky_node != null)
	_sky_node.transform.basis.x = Vector3(value, 0.0, 0.0)
	_sky_node.transform.basis.y = Vector3(0.0, value, 0.0)
	_sky_node.transform.basis.z = Vector3(0.0, 0.0, value)
	_clouds_cumulus_node.transform.basis.x = Vector3(value, 0.0, 0.0)
	_clouds_cumulus_node.transform.basis.y = Vector3(0.0, value, 0.0)
	_clouds_cumulus_node.transform.basis.z = Vector3(0.0, 0.0, value)

var contrast_level: float = 0.0 setget set_contrast_level
func set_contrast_level(value: float) -> void:
	contrast_level = value
	set_color_correction_params(value, tonemaping, exposure)

var tonemaping: float = 0.0 setget set_tonemaping
func set_tonemaping(value: float) -> void:
	tonemaping = value
	set_color_correction_params(contrast_level, value, exposure)

var exposure: float = 1.3 setget set_exposure
func set_exposure(value: float) -> void:
	exposure = value
	set_color_correction_params(contrast_level, tonemaping, value)

func set_color_correction_params(contrast: float, tonemap: float, expo: float) -> void:
	var params:= Vector3(contrast, tonemap, expo)
	_skypass_material.set_shader_param(_COLOR_CORRECTION_PARAMS, params)
	_fogpass_material.set_shader_param(_COLOR_CORRECTION_PARAMS, params)

var ground_color:= Color(0.3, 0.3, 0.3, 1.0) setget set_ground_color
func set_ground_color(value: Color) -> void:
	ground_color = value 
	_skypass_material.set_shader_param("_ground_color", value)

var sky_layers: int = 4 setget set_sky_layers
func set_sky_layers(value: int) -> void:
	sky_layers = value
	if not _init_properties_ok: return
	assert(_sky_node != null)
	_sky_node.layers = value
	assert(_clouds_cumulus_node != null)
	_clouds_cumulus_node.layers = value

var sky_render_priority: int = -128 setget set_sky_render_priority
func set_sky_render_priority(value: int) -> void:
	sky_render_priority = value
	_skypass_material.render_priority = value

# Near Space
# Sun Coords.
var sun_azimuth: float = 0.0 setget set_sun_azimuth
func set_sun_azimuth(value: float) -> void:
	sun_azimuth = value
	_set_sun_coords(value, sun_altitude)

var sun_altitude: float = -27.387 setget set_sun_altitude
func set_sun_altitude(value: float) -> void:
	sun_altitude = value
	_set_sun_coords(sun_azimuth, value)

var _finish_set_sun_position := false
var _sun_transform := Transform()
func get_sun_transform() -> Transform: 
	return _sun_transform

var sun_direction:= Vector3.ZERO
signal sun_direction_changed(value)
signal sun_transform_changed(value)

# Sun Graphics.
var sun_disk_color:= Color(0.996094, 0.541334, 0.140076, 1.0) setget set_sun_disk_color
func set_sun_disk_color(value: Color) -> void:
	sun_disk_color = value 
	value.r *=  sun_disk_multiplier
	value.g *=  sun_disk_multiplier
	value.b *=  sun_disk_multiplier
	_skypass_material.set_shader_param("_sun_disk_color", value)

var sun_disk_size: float = 0.015 setget set_sun_disk_size
func set_sun_disk_size(value: float) -> void:
	sun_disk_size = value
	_skypass_material.set_shader_param("_sun_disk_size", value)

var sun_disk_multiplier: float = 2.0 setget set_sun_disk_multiplier
func set_sun_disk_multiplier(value: float) -> void:
	sun_disk_multiplier = value 
	set_sun_disk_color(sun_disk_color)

# Sun Light.
var _sun_light_enable: bool = false
var _sun_light_node: DirectionalLight = null
var _sun_light_altitude_mult: float = 0.0
var sun_light_path: NodePath setget set_sun_light_path
func set_sun_light_path(value: NodePath) -> void:
	sun_light_path = value
	if value != null:
		_sun_light_node = get_node_or_null(value)
	_sun_light_enable = true if _sun_light_node != null else false
	set_sun_light_color(sun_light_color)
	set_sun_light_energy(sun_light_energy)
	_set_sun_coords(sun_azimuth, sun_altitude)

var sun_light_color:= Color(0.984314, 0.843137, 0.788235) setget set_sun_light_color
func set_sun_light_color(value: Color) -> void:
	sun_light_color = value
	_set_sun_light_color(value, sun_horizon_light_color)

var sun_horizon_light_color:= Color(1, 0.384314, 0.243137) setget set_sun_horizon_light_color
func set_sun_horizon_light_color(value: Color) -> void:
	sun_horizon_light_color = value
	_set_sun_light_color(sun_light_color, value)

var sun_light_energy: float = 1.0 setget set_sun_light_energy
func set_sun_light_energy(value: float) -> void:
	sun_light_energy = value
	_set_sun_light_intensity()

# Moon Coords.
var moon_azimuth: float = 5.0 setget set_moon_azimuth
func set_moon_azimuth(value: float) -> void:
	moon_azimuth = value
	_set_moon_coords(value, moon_altitude)

var moon_altitude: float = -79.437 setget set_moon_altitude
func set_moon_altitude(value: float) -> void:
	moon_altitude = value
	_set_moon_coords(moon_azimuth, value)

var _finish_set_moon_position := false
var _moon_transform := Transform()
func get_moon_transform() -> Transform:
	return _moon_transform

var moon_direction := Vector3.ZERO
signal moon_direction_changed(value)
signal moon_transform_changed(value)

# Moon Graphics.
var moon_color:= Color(1.0, 1.0, 1.0, 0.3) setget set_moon_color
func set_moon_color(value: Color) -> void: 
	moon_color = value
	_skypass_material.set_shader_param("_moon_color", value)

var moon_size: float = 0.07 setget set_moon_size
func set_moon_size(value: float) -> void:
	moon_size = value
	_skypass_material.set_shader_param("_moon_size", value)

var enable_set_moon_texture: bool = false setget set_enable_set_moon_texture
func set_enable_set_moon_texture(value: bool) -> void:
	enable_set_moon_texture = value
	if not value:
		set_moon_texture(_DEFAULT_MOON_TEXTURE)
	
	property_list_changed_notify()

var moon_texture: Texture = null setget set_moon_texture
func set_moon_texture(value: Texture) -> void:
	moon_texture = value
	_moonpass_material.set_shader_param("_texture", value)

var moon_texture_size: int = 2 setget set_moon_texture_size
func set_moon_texture_size(value: int) -> void:
	moon_texture_size = value
	if not _init_properties_ok: return
	assert(_moon_instance != null)
	match value:
		0: _moon_instance.size = Vector2(64, 64)
		1: _moon_instance.size = Vector2(128, 128)
		2: _moon_instance.size = Vector2(256, 256)
		3: _moon_instance.size = Vector2(512, 512)
		4: _moon_instance.size = Vector2(1024, 1024)
		
	_set_moon_viewport_texture()

# Moon Light
var _moon_light_node: DirectionalLight = null
var _moon_light_enable: bool = false
var _moon_light_altitude_mult: float = 0.0

var moon_light_path: NodePath setget set_moon_light_path
func set_moon_light_path(value: NodePath) -> void:
	moon_light_path = value 
	if value != null:
		_moon_light_node = get_node_or_null(value)
	_moon_light_enable = true if _moon_light_node != null else false
	
	set_moon_light_color(moon_light_color)
	set_moon_light_energy(moon_light_energy)
	_set_moon_coords(moon_azimuth, moon_altitude)

var moon_light_color:= Color(0.572549, 0.776471, 0.956863) setget set_moon_light_color
func set_moon_light_color(value: Color) -> void:
	moon_light_color = value
	if _moon_light_enable:
		_moon_light_node.light_color = value

var moon_light_energy: float = 0.3 setget set_moon_light_energy
func set_moon_light_energy(value: float) -> void:
	moon_light_energy = value
	_set_moon_light_intensity()

# Day State.
signal is_day(value)

#====================- Deep Space -====================#
var _deep_space_basis := Basis()

var deep_space_follow_sun: bool = true setget set_deep_space_follow_sun
func set_deep_space_follow_sun(value:bool) -> void:
	deep_space_follow_sun = value
	_set_sun_coords(sun_azimuth, sun_altitude)

var deep_space_euler:= Vector3(-95.0, 10.0, 0.0) setget set_deep_space_euler
func set_deep_space_euler(value: Vector3) -> void:
	deep_space_euler  = value
	_deep_space_basis = Basis(value)
	deep_space_quat   = _deep_space_basis.get_rotation_quat()
	_set_deep_space_matrix()

var deep_space_quat: Quat = Quat.IDENTITY setget set_deep_space_quat
func set_deep_space_quat(value: Quat) -> void:
	deep_space_quat   = value 
	_deep_space_basis = Basis(value)
	deep_space_euler  = _deep_space_basis.get_euler()
	_set_deep_space_matrix()

# Background.
var background_color: Color = Color(0.19, 0.19, 0.19, 0.3) setget set_background_color
func set_background_color(value: Color) -> void:
	background_color = value 
	_skypass_material.set_shader_param("_background_color", value)

var enable_set_background_texture: bool = false setget set_enable_set_background_texture
func set_enable_set_background_texture(value: bool) -> void:
	enable_set_background_texture = value
	if not value:
		set_background_texture(_DEFAULT_BACKGROUND_TEXTURE)
	
	property_list_changed_notify()

var background_texture: Texture = null setget set_background_texture
func set_background_texture(value: Texture) -> void:
	background_texture = value
	_skypass_material.set_shader_param("_background_texture", value)

# Stars Field.
var stars_field_color: Color = Color(1.0, 1.0, 1.0, 1.0) setget set_stars_field_color
func set_stars_field_color(value: Color) -> void:
	stars_field_color = value
	_skypass_material.set_shader_param("_stars_field_color", value)

var enable_set_stars_field_texture: bool = false setget set_enable_set_stars_field_texture
func set_enable_set_stars_field_texture(value: bool) -> void:
	enable_set_stars_field_texture = value
	if not value:
		set_stars_field_texture(_DEFAULT_STARS_FIELD_TEXTURE)
	
	property_list_changed_notify()

var stars_field_texture: Texture = null setget set_stars_field_texture
func set_stars_field_texture(value: Texture) -> void:
	stars_field_texture = value 
	_skypass_material.set_shader_param("_stars_field_texture", value)

var stars_scintillation: float = 0.75 setget set_stars_scintillation
func set_stars_scintillation(value: float) -> void:
	stars_scintillation = value 
	_skypass_material.set_shader_param("_stars_scintillation", value)

var stars_scintillation_speed: float = 0.01 setget set_stars_scintillation_speed
func set_stars_scintillation_speed(value: float) -> void:
	stars_scintillation_speed = value 
	_skypass_material.set_shader_param("_stars_scintillation_speed", value)

# Atmospheric Scattering.

var atm_quality: int = 0 setget set_atm_quality
func set_atm_quality(value: int) -> void:
	atm_quality = value
	
	if value == 0:
		_skypass_material.shader = _SKYPASS_SHADER
		_sky_mesh.radial_segments = 16
		_sky_mesh.rings = 8
	else:
		_skypass_material.shader = _PER_VERTEX_SKYPASS_SHADER
		_sky_mesh.radial_segments = 64
		_sky_mesh.rings = 64
		

var atm_wavelenghts:= Vector3(680.0, 550.0, 440.0) setget set_atm_wavelenghts
func set_atm_wavelenghts(value: Vector3) -> void:
	atm_wavelenghts = value
	_set_beta_ray()

var atm_darkness: float = 0.5 setget set_atm_darkness
func set_atm_darkness(value: float) -> void:
	atm_darkness = value
	var param = "_atm_darkness"
	_skypass_material.set_shader_param(param, value)
	_fogpass_material.set_shader_param(param, value)

var atm_sun_intensity: float = 30.0 setget set_atm_sun_intensity
func set_atm_sun_intensity(value: float) -> void:
	atm_sun_intensity = value 
	var param = "_atm_sun_intensity"
	_skypass_material.set_shader_param(param, value)
	_fogpass_material.set_shader_param(param, value)

var atm_day_tint := Color(0.784314, 0.854902, 0.988235) setget set_atm_day_tint
func set_atm_day_tint(value: Color) -> void:
	atm_day_tint = value
	var param = "_atm_day_tint"
	_skypass_material.set_shader_param(param, value)
	_fogpass_material.set_shader_param(param, value)

var atm_horizon_light_tint := Color(0.988235, 0.698039, 0.505882) setget set_atm_horizon_light_tint
func set_atm_horizon_light_tint(value: Color) -> void:
	atm_horizon_light_tint = value
	var param = "_atm_horizon_light_tint"
	_skypass_material.set_shader_param(param, value)
	_fogpass_material.set_shader_param(param, value)
	_clouds_cumulus_material.set_shader_param(param, value)

var atm_moon_phases_mult: float

var atm_night_scatter_mode: int = 0 setget set_atm_night_scatter_mode
func set_atm_night_scatter_mode(value: int) -> void:
	atm_night_scatter_mode = value
	_set_night_intensity()

var atm_night_tint := Color(0.168627, 0.2, 0.25098) setget set_atm_night_tint
func set_atm_night_tint(value: Color) -> void:
	atm_night_tint = value
	_set_night_intensity()

var atm_params:= Vector3(1.0, 0.0, 0.0) setget set_atm_params
func set_atm_params(value: Vector3) -> void:
	atm_params = value
	var param = "_atm_params"
	_skypass_material.set_shader_param(param, value)
	_fogpass_material.set_shader_param(param, value)

var atm_thickness: float = 0.7 setget set_atm_thickness
func set_atm_thickness(value: float) -> void:
	atm_thickness = value
	_set_beta_ray()

var atm_mie: float = 0.07 setget set_atm_mie
func set_atm_mie(value: float) -> void:
	atm_mie = value
	_set_beta_mie()

var atm_turbidity: float = 0.001 setget set_atm_turbidity
func set_atm_turbidity(value: float) -> void:
	atm_turbidity = value
	_set_beta_mie()

var atm_sun_mie_tint:= Color(1.0, 1.0, 1.0, 1.0) setget set_atm_sun_mie_tint
func set_atm_sun_mie_tint(value:Color)-> void:
	atm_sun_mie_tint = value 
	var param = "_atm_sun_mie_tint"
	_skypass_material.set_shader_param(param, value)
	_fogpass_material.set_shader_param(param, value)
	_clouds_cumulus_material.set_shader_param(param, value)

var atm_sun_mie_intensity: float = 1.0 setget set_atm_sun_mie_intensity
func set_atm_sun_mie_intensity(value: float) -> void:
	atm_sun_mie_intensity = value 
	var param = "_atm_sun_mie_intensity"
	_skypass_material.set_shader_param(param, value)
	_fogpass_material.set_shader_param(param, value)

var atm_sun_mie_anisotropy: float = 0.8 setget set_atm_sun_mie_anisotropy
func set_atm_sun_mie_anisotropy(value: float) -> void:
	atm_sun_mie_anisotropy = value 
	var partialMiePhase: Vector3 = AtmScatter.partial_mie_phase(value)
	var param = "_atm_sun_partial_mie_phase"
	_skypass_material.set_shader_param(param, partialMiePhase)
	_fogpass_material.set_shader_param(param, partialMiePhase)

var atm_moon_mie_tint:= Color(0.137255, 0.184314, 0.290196) setget set_atm_moon_mie_tint
func set_atm_moon_mie_tint(value:Color)-> void:
	atm_moon_mie_tint = value 
	var param = "_atm_moon_mie_tint"
	_skypass_material.set_shader_param(param, value)
	_fogpass_material.set_shader_param(param, value)
	_clouds_cumulus_material.set_shader_param(param, value)

var atm_moon_mie_intensity: float = 0.7 setget set_atm_moon_mie_intensity
func set_atm_moon_mie_intensity(value: float) -> void:
	atm_moon_mie_intensity = value 
	var param = "_atm_moon_mie_intensity"
	_skypass_material.set_shader_param(param, value * atm_moon_phases_mult)
	_fogpass_material.set_shader_param(param, value * atm_moon_phases_mult)

var atm_moon_mie_anisotropy: float = 0.8 setget set_atm_moon_mie_anisotropy
func set_atm_moon_mie_anisotropy(value: float) -> void:
	atm_moon_mie_anisotropy = value 
	var param = "_atm_moon_partial_mie_phase"
	var partialMiePhase: Vector3 = AtmScatter.partial_mie_phase(value)
	_skypass_material.set_shader_param(param, partialMiePhase)
	_fogpass_material.set_shader_param(param, partialMiePhase)

# Fog.
var fog_visible:= false setget set_fog_visible
func set_fog_visible(value: bool) -> void:
	fog_visible = value 
	if not _init_properties_ok: return
	assert(_fog_node != null)
	_fog_node.visible = value

var fog_density: float = 0.000735 setget set_fog_density
func set_fog_density(value: float) -> void:
	fog_density = value
	_fogpass_material.set_shader_param("_density", value)

var fog_rayleigh_depth: float= 0.035 setget set_fog_rayleigh_depth
func set_fog_rayleigh_depth(value: float) -> void:
	fog_rayleigh_depth = value
	_fogpass_material.set_shader_param("_rayleigh_depth", value)

var fog_mie_depth: float = 0.007 setget set_fog_mie_depth
func set_fog_mie_depth(value: float) -> void:
	fog_mie_depth = value
	_fogpass_material.set_shader_param("_mie_depth", value)

var fog_layers: int = 524288 setget set_fog_layers
func set_fog_layers(value: int) -> void:
	fog_layers = value
	if not _init_properties_ok: return
	assert(_fog_node != null)
	_fog_node.layers = value

var fog_render_priority: int = 123 setget set_fog_render_priority
func set_fog_render_priority(value: int) -> void:
	fog_render_priority = value 
	_fogpass_material.render_priority = value

# Clouds Simple.
var clouds_thickness: float = 2.5 setget set_clouds_thickness
func set_clouds_thickness(value: float) -> void:
	clouds_thickness = value
	_skypass_material.set_shader_param("_clouds_thickness", value)

var clouds_coverage: float = 0.4 setget set_clouds_coverage
func set_clouds_coverage(value: float) -> void:
	clouds_coverage = value 
	_skypass_material.set_shader_param("_clouds_coverage", value)

var clouds_absorption: float = 6.7 setget set_clouds_absorption
func set_clouds_absorption(value: float) -> void:
	clouds_absorption = value 
	_skypass_material.set_shader_param("_clouds_absorption", value)


var clouds_sky_tint_fade: float = 0.0 setget set_clouds_sky_tint_fade
func set_clouds_sky_tint_fade(value: float) -> void:
	clouds_sky_tint_fade = value 
	_skypass_material.set_shader_param("_clouds_sky_tint_fade", value)

var clouds_intensity: float = 20.0 setget set_clouds_intensity
func set_clouds_intensity(value: float) -> void:
	clouds_intensity = value
	_skypass_material.set_shader_param("_clouds_intensity", value)

var clouds_size: float = 0.415 setget set_clouds_size
func set_clouds_size(value: float) -> void:
	clouds_size = value
	_skypass_material.set_shader_param("_clouds_size", value)

var clouds_uv:= Vector2(1.0, 1.0) setget set_clouds_uv
func set_clouds_uv(value: Vector2) -> void:
	clouds_uv = value 
	_skypass_material.set_shader_param("_clouds_uv", value)

var clouds_offset:= Vector2(0.1, 0.254) setget set_clouds_offset
func set_clouds_offset(value: Vector2) -> void:
	clouds_offset = value
	_skypass_material.set_shader_param("_clouds_offset", value)

var clouds_offset_speed: float = 0.005 setget set_clouds_offset_speed
func set_clouds_offset_speed(value: float) -> void:
	clouds_offset_speed = value 
	_skypass_material.set_shader_param("_clouds_offset_speed", value)

var clouds_enable_set_texture: bool setget set_clouds_enable_set_texture
func set_clouds_enable_set_texture(value: bool) -> void:
	clouds_enable_set_texture = value
	
	if not value:
		set_clouds_texture(_DEFAULT_CLOUDS_TEXTURE)
		
	property_list_changed_notify()

var clouds_texture: Texture setget set_clouds_texture
func set_clouds_texture(value: Texture) -> void:
	clouds_texture = value
	_skypass_material.set_shader_param("_clouds_texture", value)

# Clouds Cumulus.
var clouds_cumulus_visible: bool = true setget set_clouds_cumulus_visible
func set_clouds_cumulus_visible(value: bool) -> void:
	clouds_cumulus_visible = value
	if not _init_properties_ok: return
	assert(_clouds_cumulus_node != null)
	_clouds_cumulus_node.visible = value

var clouds_cumulus_thickness: float = 0.032 setget set_clouds_cumulus_thickness
func set_clouds_cumulus_thickness(value: float) -> void:
	clouds_cumulus_thickness = value
	_clouds_cumulus_material.set_shader_param("_clouds_thickness", value)

var clouds_cumulus_coverage: float = 0.7 setget set_clouds_cumulus_coverage
func set_clouds_cumulus_coverage(value: float) -> void:
	clouds_cumulus_coverage = value 
	_clouds_cumulus_material.set_shader_param("_clouds_coverage", value)

var clouds_cumulus_absorption: float = 6.0 setget set_clouds_cumulus_absorption
func set_clouds_cumulus_absorption(value: float) -> void:
	clouds_cumulus_absorption = value 
	_clouds_cumulus_material.set_shader_param("_clouds_absorption", value)

var clouds_cumulus_noise_frequency: float = 2.7 setget set_clouds_cumulus_noise_frequency
func set_clouds_cumulus_noise_frequency(value: float) -> void:
	clouds_cumulus_noise_frequency = value
	_clouds_cumulus_material.set_shader_param("_clouds_noise_freq", value)

var clouds_cumulus_intensity: float = 1.0 setget set_clouds_cumulus_intensity
func set_clouds_cumulus_intensity(value: float) -> void:
	clouds_cumulus_intensity = value
	_clouds_cumulus_material.set_shader_param("_clouds_intensity", value)

var clouds_cumulus_mie_intensity: float = 1.5 setget set_clouds_cumulus_mie_intensity
func set_clouds_cumulus_mie_intensity(value: float) -> void:
	clouds_cumulus_mie_intensity = value
	_clouds_cumulus_material.set_shader_param("_mie_intensity", value)

var clouds_cumulus_mie_anisotropy: float = 0.245 setget set_clouds_cumulus_mie_anisotropy
func set_clouds_cumulus_mie_anisotropy(value: float) -> void:
	clouds_cumulus_mie_anisotropy = value 
	var partialMiePhase: Vector3 = AtmScatter.partial_mie_phase(value)
	var param = "_partial_mie_phase"
	_clouds_cumulus_material.set_shader_param(param, partialMiePhase)


var clouds_cumulus_size: float = 0.4 setget set_clouds_cumulus_size
func set_clouds_cumulus_size(value: float) -> void:
	clouds_cumulus_size = value
	_clouds_cumulus_material.set_shader_param("_clouds_size", value)
	
var clouds_cumulus_offset:= Vector3(0.1, 0.254, -0.075) setget set_clouds_cumulus_offset
func set_clouds_cumulus_offset(value: Vector3) -> void:
	clouds_cumulus_offset = value
	_clouds_cumulus_material.set_shader_param("_clouds_offset", value)

var clouds_cumulus_offset_speed: float = 0.005 setget set_clouds_cumulus_offset_speed
func set_clouds_cumulus_offset_speed(value: float) -> void:
	clouds_cumulus_offset_speed = value 
	_clouds_cumulus_material.set_shader_param("_clouds_offset_speed", value)

var clouds_cumulus_enable_set_texture: bool setget set_clouds_cumulus_enable_set_texture
func set_clouds_cumulus_enable_set_texture(value: bool) -> void:
	clouds_cumulus_enable_set_texture = value
	
	if not value:
		set_clouds_cumulus_texture(_CLOUDS_CUMULUS_TEXTURE)
		
	property_list_changed_notify()

var clouds_cumulus_texture: Texture setget set_clouds_cumulus_texture
func set_clouds_cumulus_texture(value: Texture) -> void:
	clouds_cumulus_texture = value
	_clouds_cumulus_material.set_shader_param("_clouds_texture", value)

# Environment.
var _enable_enviro: bool = false
var enviro: Environment setget set_enviro
func set_enviro(value: Environment) -> void:
	enviro = value 
	_enable_enviro = true if enviro != null else false
	if _enable_enviro && _init_properties_ok:
		_update_enviro()

func _init():
	_init_resources()
	_sky_node = get_node_or_null(_SKY_INSTANCE_NAME)
	_fog_node = get_node_or_null(_FOG_INSTANCE_NAME)
	_clouds_cumulus_node = get_node_or_null(_CLOUDS_CUMULUS_INSTANCE_NAME)
	_moon_instance = get_node_or_null(_MOON_INSTANCE_NAME)
	if _sky_node != null && _fog_node != null && _moon_instance != null && _clouds_cumulus_node != null:
		_init_properties_ok = true
		_init_mesh_instances()
	_skypass_material.set_shader_param("_noise_tex", _DEFAULT_STARS_FIELD_NOISE_TEXTURE)

func _enter_tree() -> void:
	_build_dome()
	_init_properties()
	#_set_nodes_owner() # Debug.

func _ready():
	#var all_child_nodes = get_children()
	#print(all_child_nodes)
	_set_sun_coords(sun_azimuth, sun_altitude)
	_set_moon_coords(moon_azimuth, moon_altitude)

func _init_properties() -> void:
	_init_properties_ok = true
	set_sky_visible(sky_visible)
	set_skydome_radius(skydome_radius)
	set_contrast_level(contrast_level)
	set_tonemaping(tonemaping)
	set_exposure(exposure)
	set_ground_color(ground_color)
	set_sky_layers(sky_layers)
	set_sky_render_priority(sky_render_priority)
	
	set_sun_azimuth(sun_azimuth)
	set_sun_altitude(sun_altitude)
	set_sun_disk_color(sun_disk_color)
	set_sun_disk_multiplier(sun_disk_multiplier)
	set_sun_disk_size(sun_disk_size)
	set_sun_light_path(sun_light_path)
	set_sun_light_color(sun_light_color)
	set_sun_horizon_light_color(sun_horizon_light_color)
	set_sun_light_energy(sun_light_energy)
	
	set_moon_altitude(moon_altitude)
	set_moon_azimuth(moon_azimuth)
	
	set_moon_color(moon_color)
	set_moon_size(moon_size)
	set_enable_set_moon_texture(enable_set_moon_texture)
	if enable_set_moon_texture:
		set_moon_texture(moon_texture)
	
	set_moon_texture_size(moon_texture_size)
	set_moon_light_path(moon_light_path)
	set_moon_light_color(moon_light_color)
	set_moon_light_energy(moon_light_energy)
	
	set_deep_space_euler(deep_space_euler)
	set_background_color(background_color)
	set_enable_set_background_texture(enable_set_background_texture)
	if enable_set_background_texture:
		set_background_texture(background_texture)
	
	set_stars_field_color(stars_field_color)
	set_enable_set_stars_field_texture(enable_set_stars_field_texture)
	if enable_set_stars_field_texture:
		set_stars_field_texture(stars_field_texture)
	
	set_stars_scintillation(stars_scintillation)
	set_stars_scintillation_speed(stars_scintillation_speed)
	
	set_atm_wavelenghts(atm_wavelenghts)
	set_atm_darkness(atm_darkness)
	set_atm_sun_intensity(atm_sun_intensity)
	set_atm_day_tint(atm_day_tint)
	set_atm_night_tint(atm_night_tint)
	set_atm_horizon_light_tint(atm_horizon_light_tint)
	set_atm_params(atm_params)
	set_atm_thickness(atm_thickness)
	set_atm_mie(atm_mie)
	set_atm_turbidity(atm_turbidity)
	set_atm_sun_mie_tint(atm_sun_mie_tint)
	set_atm_sun_mie_intensity(atm_sun_mie_intensity)
	set_atm_sun_mie_anisotropy(atm_sun_mie_anisotropy)
	set_atm_moon_mie_tint(atm_moon_mie_tint)
	set_atm_moon_mie_intensity(atm_moon_mie_intensity)
	set_atm_moon_mie_anisotropy(atm_moon_mie_anisotropy)
	set_fog_visible(fog_visible)
	set_fog_density(fog_density)
	set_fog_rayleigh_depth(fog_rayleigh_depth)
	set_fog_mie_depth(fog_mie_depth)
	set_fog_render_priority(fog_render_priority)
	
	set_clouds_thickness(clouds_thickness)
	set_clouds_coverage(clouds_coverage)
	set_clouds_absorption(clouds_absorption)
	set_clouds_sky_tint_fade(clouds_sky_tint_fade)
	set_clouds_intensity(clouds_intensity)
	set_clouds_size(clouds_size)
	set_clouds_uv(clouds_uv)
	set_clouds_offset(clouds_offset)
	set_clouds_offset_speed(clouds_offset_speed)
	set_clouds_enable_set_texture(clouds_enable_set_texture)
	if clouds_enable_set_texture:
		set_clouds_texture(clouds_texture)
	
	set_clouds_cumulus_visible(clouds_cumulus_visible)
	set_clouds_cumulus_thickness(clouds_cumulus_thickness)
	set_clouds_cumulus_coverage(clouds_cumulus_coverage)
	set_clouds_cumulus_absorption(clouds_cumulus_absorption)
	set_clouds_cumulus_noise_frequency(clouds_cumulus_noise_frequency)
	set_clouds_cumulus_intensity(clouds_cumulus_intensity)
	set_clouds_cumulus_mie_intensity(clouds_cumulus_mie_intensity)
	set_clouds_cumulus_mie_anisotropy(clouds_cumulus_mie_anisotropy)
	set_clouds_cumulus_size(clouds_cumulus_size)
	set_clouds_cumulus_offset(clouds_cumulus_offset)
	set_clouds_cumulus_offset_speed(clouds_cumulus_offset_speed)
	set_clouds_cumulus_enable_set_texture(clouds_cumulus_enable_set_texture)
	if clouds_cumulus_enable_set_texture:
		set_clouds_cumulus_texture(clouds_cumulus_texture)
	
	set_enviro(enviro)

func _init_resources() -> void:
	#_sky_mesh.radial_segments = 32
	#_sky_mesh.rings = 16
	#_skypass_material.shader = _SKYPASS_SHADER
	set_atm_quality(atm_quality)
	_skypass_material.setup_local_to_scene()
	_skypass_material.render_priority = sky_render_priority
	
	_fog_mesh.size = Vector2(2.0, 2.0);
	_fogpass_material.shader = _SCATTER_FOG_PASS_SHADER
	_fogpass_material.render_priority = fog_render_priority;
	
	_moonpass_material.shader = _MOONPASS_SHADER
	_moonpass_material.setup_local_to_scene()
	
	_clouds_mesh.radial_segments = 16
	_clouds_mesh.rings = 8
	_clouds_cumulus_material.shader = _CLOUDS_CUMULUS_SHADER
	_clouds_cumulus_material.render_priority = sky_render_priority + 1
	

func _build_dome() -> void:
	# Skydome.
	_sky_node = get_node_or_null(_SKY_INSTANCE_NAME)
	if _sky_node == null:
		_sky_node = MeshInstance.new()
		_sky_node.name = _SKY_INSTANCE_NAME
		self.add_child(_sky_node)
	
	# Fog.
	_fog_node = get_node_or_null(_FOG_INSTANCE_NAME)
	if _fog_node == null:
		_fog_node = MeshInstance.new()
		_fog_node.name = _FOG_INSTANCE_NAME
		self.add_child(_fog_node)
	
	# Moon.
	_moon_instance = get_node_or_null(_MOON_INSTANCE_NAME)
	if _moon_instance == null:
		_moon_instance = _MOON_RENDER.instance() 
		self.add_child(_moon_instance)
	
	# Clouds.
	_clouds_cumulus_node = get_node_or_null(_CLOUDS_CUMULUS_INSTANCE_NAME)
	if _clouds_cumulus_node == null:
		_clouds_cumulus_node = MeshInstance.new()
		_clouds_cumulus_node.name = _CLOUDS_CUMULUS_INSTANCE_NAME
		self.add_child(_clouds_cumulus_node)
	
	_init_mesh_instances()

func _init_mesh_instances() -> void:
	assert(_sky_node != null)
	_sky_node.transform.origin = _DEFAULT_ORIGIN
	_sky_node.mesh = _sky_mesh
	_sky_node.extra_cull_margin = _MAX_EXTRA_CULL_MARGIN
	_sky_node.cast_shadow = _sky_node.SHADOW_CASTING_SETTING_OFF
	_sky_node.material_override = _skypass_material
	
	assert(_fog_node != null)
	_fog_node.transform.origin = Vector3.ZERO
	_fog_node.mesh = _fog_mesh 
	_fog_node.extra_cull_margin = _MAX_EXTRA_CULL_MARGIN
	_fog_node.cast_shadow = _sky_node.SHADOW_CASTING_SETTING_OFF
	_fog_node.material_override = _fogpass_material
	
	assert(_moon_instance != null)
	_moon_instance_transform = _moon_instance.get_node_or_null("MoonTransform")
	_moon_instance_mesh = _moon_instance_transform.get_node_or_null("Camera/Mesh")
	_moon_instance_mesh.material_override = _moonpass_material
	
	assert(_clouds_cumulus_node != null)
	_clouds_cumulus_node.transform.origin = Vector3.ZERO
	_clouds_cumulus_node.mesh = _clouds_mesh
	_clouds_cumulus_node.extra_cull_margin = _MAX_EXTRA_CULL_MARGIN
	_clouds_cumulus_node.cast_shadow = _clouds_cumulus_node.SHADOW_CASTING_SETTING_OFF
	_clouds_cumulus_node.material_override = _clouds_cumulus_material

func _set_nodes_owner() -> void: # Debug.
	_sky_node.owner = self.get_tree().edited_scene_root
	_fog_node.owner = self.get_tree().edited_scene_root
	_moon_instance.owner = self.get_tree().edited_scene_root
	_clouds_cumulus_node.owner = self.get_tree().edited_scene_root

func _set_sun_coords(azimuth: float, altitude: float) -> void:
	if not _init_properties_ok: return
	assert(_sky_node != null)
	azimuth = deg2rad(azimuth); altitude = deg2rad(altitude)
	_finish_set_sun_position = false
	if not _finish_set_sun_position:
		_sun_transform.origin = SkyMath.to_orbit(altitude, azimuth)
		_finish_set_sun_position = true
	if _finish_set_sun_position:
		_sun_transform = _sun_transform.looking_at(_sky_node.transform.origin, Vector3(-1.0, 0.0, 0.0))
		
	emit_signal("sun_transform_changed", _sun_transform)
	
	# Sun direction.
	sun_direction = _sun_transform.origin - _sky_node.transform.origin
	emit_signal("sun_direction_changed", sun_direction)
	_set_day_state(altitude)
	
	_skypass_material.set_shader_param(_SUN_DIR_PARAM, sun_direction)
	_fogpass_material.set_shader_param(_SUN_DIR_PARAM, sun_direction)
	_moonpass_material.set_shader_param(_SUN_DIR_PARAM, sun_direction)
	_clouds_cumulus_material.set_shader_param(_SUN_DIR_PARAM, sun_direction)
	
	if _sun_light_enable: 
		if _sun_light_node.light_energy > 0.0:
			_sun_light_node.transform.origin = _sun_transform.origin
			_sun_light_node.transform.basis = _sun_transform.basis
	_sun_light_altitude_mult = SkyMath.saturate(sun_direction.y + 0.25)
	
	set_deep_space_quat(_sun_transform.basis.get_rotation_quat().inverse())
		
	_set_sun_light_color(sun_light_color, sun_horizon_light_color)
	_set_sun_light_intensity()
	_set_moon_light_intensity()
	_set_night_intensity() 
	_update_enviro()

func _set_moon_coords(azimuth: float, altitude: float) -> void:
	if not _init_properties_ok: return
	assert(_sky_node != null)
	azimuth = deg2rad(azimuth); altitude = deg2rad(altitude)
	_finish_set_moon_position = false
	if not _finish_set_moon_position:
		_moon_transform.origin = SkyMath.to_orbit(altitude, azimuth, 1.0)
		_finish_set_moon_position = true
	if _finish_set_moon_position:
		_moon_transform = _moon_transform.looking_at(_sky_node.transform.origin, Vector3(-1.0, 0.0, 0.0))
	
	emit_signal("moon_transform_changed", _moon_transform)
	
	# Moon Direction.
	moon_direction = _moon_transform.origin - _sky_node.transform.origin
	emit_signal("moon_direction_changed", moon_direction)
	
	_skypass_material.set_shader_param(_MOON_DIR_PARAM, moon_direction)
	_clouds_cumulus_material.set_shader_param(_MOON_DIR_PARAM, moon_direction)
	_skypass_material.set_shader_param("_moon_matrix", _moon_transform.basis.inverse())
	_fogpass_material.set_shader_param(_MOON_DIR_PARAM, moon_direction)
	_moonpass_material.set_shader_param(_SUN_DIR_PARAM, sun_direction)
	
	_moon_instance_transform.transform.origin = _moon_transform.origin
	_moon_instance_transform.transform.basis = _moon_transform.basis
	
	if _moon_light_enable:
		if _moon_light_node.light_energy > 0.0:
			_moon_light_node.transform.origin = _moon_transform.origin 
			_moon_light_node.transform.basis = _moon_transform.basis
	_moon_light_altitude_mult = SkyMath.saturate(moon_direction.y + 0.30)
	set_moon_light_color(moon_light_color)
	_set_moon_light_intensity()
	_set_night_intensity()
	_update_enviro()

func _set_moon_viewport_texture() -> void:
	_moon_viewport_texture = _moon_instance.get_texture()
	_skypass_material.set_shader_param("_moon_texture", _moon_viewport_texture)

func _set_day_state(value: float, threshold: float = 1.80) -> void:
	if abs(value) > threshold:
		emit_signal("is_day", false)
	else:
		emit_signal("is_day", true)
		
	_evaluate_light_enable()

func _evaluate_light_enable() -> void:
	var enable: bool
	if _sun_light_enable:
		enable = true if _sun_light_node.light_energy > 0.0 else false
		_sun_light_node.visible = enable
	if _moon_light_enable:
		_moon_light_node.visible = !enable

func _set_sun_light_color(dayCol: Color, horizonCol: Color) -> void:
	if _sun_light_enable:
		_sun_light_node.light_color = lerp(horizonCol, dayCol, _sun_light_altitude_mult)

func _set_sun_light_intensity() -> void:
	if _sun_light_enable:
		_sun_light_node.light_energy = lerp(0.0, sun_light_energy, _sun_light_altitude_mult)

func _set_moon_light_intensity() -> void:
	if _moon_light_enable: 
		var l: float = lerp(0.0, moon_light_energy, _moon_light_altitude_mult)
		l *= atm_moon_phases_mult
		var curveFade = (1.0 - sun_direction.y) * 0.5
		_moon_light_node.light_energy = l * _DEFAULT_SUN_MOON_LIGHT_CURVE_FADE.interpolate_baked(curveFade)

func _set_deep_space_matrix() -> void:
	_skypass_material.set_shader_param("_deep_space_matrix", _deep_space_basis)

func _set_beta_ray() -> void:
	var wl_la: Vector3 = AtmScatter.get_wavelenght_lambda(atm_wavelenghts)
	var wl = AtmScatter.get_wavelenght(wl_la)
	var param = "_atm_beta_ray"
	var br: Vector3 = AtmScatter.beta_ray(wl) * atm_thickness
	_skypass_material.set_shader_param(param, br)
	_fogpass_material.set_shader_param(param, br)

func _set_beta_mie() -> void:
	var param = "_atm_beta_mie"
	var bm: Vector3 = AtmScatter.beta_mie(atm_mie, atm_turbidity)
	_skypass_material.set_shader_param(param, bm)
	_fogpass_material.set_shader_param(param, bm)

var n_intensity: float
func _set_night_intensity() -> void:
	if atm_night_scatter_mode == 0:
		n_intensity = SkyMath.saturate(-sun_direction.y + 0.30)
		atm_moon_phases_mult = n_intensity
	else:
		atm_moon_phases_mult = SkyMath.saturate(-sun_direction.dot(moon_direction)+0.60) 
		n_intensity = SkyMath.saturate(moon_direction.y) * atm_moon_phases_mult
	_skypass_material.set_shader_param("_atm_night_tint", atm_night_tint * n_intensity)
	_fogpass_material.set_shader_param("_atm_night_tint", atm_night_tint * n_intensity)
	_clouds_cumulus_material.set_shader_param("_atm_night_tint", atm_night_tint * n_intensity)
	set_atm_moon_mie_intensity(atm_moon_mie_intensity)

func _update_enviro() -> void:
	if not _enable_enviro: return 
	var ax:= SkyMath.saturate(1.0 - sun_direction.y)
	var aw:= SkyMath.saturate(-sun_direction.y + 0.60)
	var colA: Color = lerp(atm_day_tint * 0.5, atm_horizon_light_tint, ax)
	var colB: Color = lerp(colA, atm_night_tint * n_intensity, aw)
	enviro.ambient_light_color = colB


func _get_property_list() -> Array:
	var ret: Array
	ret.push_back({name = "Dynamic Sky", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	
	# Global.
	ret.push_back({name = "Global", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sky_visible", type = TYPE_BOOL})
	ret.push_back({name = "skydome_radius", type = TYPE_REAL})
	ret.push_back({name = "contrast_level", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "tonemaping", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "exposure", type = TYPE_REAL})
	ret.push_back({name = "ground_color", type = TYPE_COLOR})
	ret.push_back({name = "sky_layers", type=TYPE_INT, hint=PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "sky_render_priority", type=TYPE_INT, hint=PROPERTY_HINT_RANGE, hint_string="-128, 128"})
	
	# Sun. 
	ret.push_back({name = "Sun", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP, hint_string = "sun_"})
	ret.push_back({name = "sun_altitude", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	ret.push_back({name = "sun_azimuth", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-180, 180"})
	ret.push_back({name = "sun_disk_color", type=TYPE_COLOR})
	ret.push_back({name = "sun_disk_multiplier", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 2.0"})
	ret.push_back({name = "sun_disk_size", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "sun_light_path", type=TYPE_NODE_PATH})
	ret.push_back({name = "sun_light_color", type=TYPE_COLOR})
	ret.push_back({name = "sun_horizon_light_color", type=TYPE_COLOR})
	ret.push_back({name = "sun_light_energy", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 8.0"})
	
	# Moon.
	ret.push_back({name = "Moon", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "moon_altitude", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	ret.push_back({name = "moon_azimuth", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	ret.push_back({name = "moon_color", type=TYPE_COLOR})
	ret.push_back({name = "moon_size", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "moon_texture_size", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="64, 128, 256, 512, 1024"})
	ret.push_back({name = "enable_set_moon_texture", type=TYPE_BOOL})
	if enable_set_moon_texture:
		ret.push_back({name = "moon_texture", type=TYPE_OBJECT, hint=PROPERTY_HINT_FILE, hint_string="Texture"})
	
	ret.push_back({name = "moon_light_path", type=TYPE_NODE_PATH})
	ret.push_back({name = "moon_light_color", type=TYPE_COLOR})
	ret.push_back({name = "moon_light_energy", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 8.0"})
	
	# Deep Space.
	ret.push_back({name = "DeepSpace", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "deep_space_follow_sun", type=TYPE_BOOL})
	ret.push_back({name = "deep_space_euler", type=TYPE_VECTOR3})
	ret.push_back({name = "background_color", type=TYPE_COLOR})
	ret.push_back({name = "enable_set_background_texture", type=TYPE_BOOL})
	if enable_set_background_texture:
		ret.push_back({name = "background_texture", type=TYPE_OBJECT, hint=PROPERTY_HINT_FILE, hint_string="Texture"})
	
	ret.push_back({name = "stars_field_color", type=TYPE_COLOR})
	ret.push_back({name = "enable_set_stars_field_texture", type=TYPE_BOOL})
	if enable_set_stars_field_texture:
		ret.push_back({name = "stars_field_texture", type=TYPE_OBJECT, hint=PROPERTY_HINT_FILE, hint_string="Texture"})
	
	ret.push_back({name = "stars_scintillation", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "stars_scintillation_speed", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 0.1"})
	
	ret.push_back({name = "Atmosphere", type=TYPE_NIL,usage=PROPERTY_USAGE_GROUP, hint_string = "atm_"})
	ret.push_back({name = "atm_quality", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="PerPixel, PerVertex"})
	ret.push_back({name = "atm_darkness", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "atm_wavelenghts", type=TYPE_VECTOR3})
	ret.push_back({name = "atm_sun_intensity", type=TYPE_REAL})
	ret.push_back({name = "atm_day_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_horizon_light_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_night_scatter_mode", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="OppositeSun, Moon"})
	ret.push_back({name = "atm_night_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_params", type=TYPE_VECTOR3})
	ret.push_back({name = "atm_thickness", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 10.0"})
	ret.push_back({name = "atm_mie", type=TYPE_REAL})
	ret.push_back({name = "atm_turbidity", type=TYPE_REAL})
	ret.push_back({name = "atm_sun_mie_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_sun_mie_intensity", type=TYPE_REAL})
	ret.push_back({name = "atm_sun_mie_anisotropy", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 0.999"})
	ret.push_back({name = "atm_moon_mie_tint", type=TYPE_COLOR})
	ret.push_back({name = "atm_moon_mie_intensity", type=TYPE_REAL})
	ret.push_back({name = "atm_moon_mie_anisotropy", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-0.999, 0.999"})
	
	# Fog. 
	ret.push_back({name = "Fog", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP, hint_string = "fog_"})
	ret.push_back({name = "fog_visible", type=TYPE_BOOL})
	ret.push_back({name = "fog_density", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_EASING, hint_string="0.0, 1.0"})
	ret.push_back({name = "fog_rayleigh_depth", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_EASING, hint_string="0.0, 1.0"})
	ret.push_back({name = "fog_mie_depth", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_EASING, hint_string="0.0, 1.0"})
	ret.push_back({name = "fog_layers", type=TYPE_INT, hint=PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "fog_render_priority", type=TYPE_INT, hint=PROPERTY_HINT_RANGE, hint_string="-128, 127"})
	
	# Clouds.
	ret.push_back({name = "Clouds", type=TYPE_NIL,usage=PROPERTY_USAGE_GROUP, hint_string = "clouds_"})
	ret.push_back({name = "clouds_thickness", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 10.0"})
	ret.push_back({name = "clouds_coverage", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "clouds_absorption", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 10.0"})
	ret.push_back({name = "clouds_sky_tint_fade", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "clouds_intensity", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 100.0"})
	ret.push_back({name = "clouds_size", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "clouds_uv", type=TYPE_VECTOR2})
	ret.push_back({name = "clouds_offset", type=TYPE_VECTOR2})
	ret.push_back({name = "clouds_offset_speed", type=TYPE_REAL,  hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "clouds_enable_set_texture", type=TYPE_BOOL})
	
	if clouds_enable_set_texture:
		ret.push_back({name = "clouds_texture", type=TYPE_OBJECT, hint=PROPERTY_HINT_FILE, hint_string="Texture"})
	
	
	
	# Clouds Cumulus.
	ret.push_back({name = "Clouds Cumulus", type=TYPE_NIL,usage=PROPERTY_USAGE_GROUP, hint_string = "clouds_cumulus_"})
	ret.push_back({name = "clouds_cumulus_visible", type=TYPE_BOOL})
	ret.push_back({name = "clouds_cumulus_thickness", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 0.1"})
	ret.push_back({name = "clouds_cumulus_coverage", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "clouds_cumulus_absorption", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 100.0"})
	
	ret.push_back({name = "clouds_cumulus_mie_intensity", type=TYPE_REAL})
	ret.push_back({name = "clouds_cumulus_mie_anisotropy", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 0.9999"})
	
	ret.push_back({name = "clouds_cumulus_noise_frequency", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 4.0"})
	ret.push_back({name = "clouds_cumulus_intensity", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 100.0"})
	ret.push_back({name = "clouds_cumulus_size", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 50.0"})
	ret.push_back({name = "clouds_cumulus_offset", type=TYPE_VECTOR3})
	ret.push_back({name = "clouds_cumulus_offset_speed", type=TYPE_REAL,  hint=PROPERTY_HINT_RANGE, hint_string="0.0, 1.0"})
	ret.push_back({name = "clouds_cumulus_enable_set_texture", type=TYPE_BOOL})
	
	if clouds_cumulus_enable_set_texture:
		ret.push_back({name = "clouds_cumulus_texture", type=TYPE_OBJECT, hint=PROPERTY_HINT_FILE, hint_string="Texture"})
	
	
	ret.push_back({name = "Environment", type=TYPE_NIL,usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "enviro", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string="Environment"})
	
	return ret;
