tool 
class_name TimeOfDay extends Node 
"""========================================================
°                       Universal Sky.
°                   ======================
°
°   Category: TimeOfDay.
°   -----------------------------------------------------
°   Description:
°       Time Of Day Manager.
°       Planetary coords based on Paul Schlyter papers.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2020. MIT License.
°                   See: LICENSE Archive.
========================================================"""
var sky_node: SkyManager
var sky_node_found: bool = false

var sky_node_path: NodePath setget set_sky_node_path
func set_sky_node_path(value: NodePath) -> void:
	sky_node_path = value
	if value != null:
		sky_node = get_node_or_null(value) as SkyManager
		
	sky_node_found = true if sky_node != null else false

# DateTime.
var system_sync: bool = false
var total_cycle_in_minutes: float = 15.0

var total_hours: float = 7.0 setget set_total_hours
func set_total_hours(value: float) -> void:
	total_hours = value
	emit_signal("total_hours_changed", value)
	if Engine.editor_hint:
		_set_celestials_coords()

var day: int = 12 setget set_day
func set_day(value: int) -> void:
	day = value
	if Engine.editor_hint:
		_set_celestials_coords()

var month: int = 2 setget set_month
func set_month(value: int) -> void:
	month = value
	if Engine.editor_hint:
		_set_celestials_coords()

var year: int = 2021
func set_year(value: int) -> void:
	year = value
	if Engine.editor_hint:
		_set_celestials_coords()

var _is_leap_year: bool
func get_is_leap_year() -> bool:
	return _is_leap_year

var _date_time_os 
var _max_days_per_month: int
var _time_cycle_duration: float
var _is_beging_of_time: bool
var _is_end_of_time: bool
var _total_hours_utc: float

signal total_hours_changed(value)
signal day_changed(value)
signal month_changed(value)
signal year_changed(value)
#-------------------------------------------------------------------------------

#---------------------
# Planetary.
#---------------------

# Calculations type.
enum CelestialCalculationsMode{
	Simple = 0,
	Realistic
}
var celestial_calculations: int = 0 setget set_celestial_calculations
func set_celestial_calculations(value: int) -> void:
	celestial_calculations = value
	if Engine.editor_hint:
		_set_celestials_coords()
		property_list_changed_notify() 

# Location.
var latitude: float  = 42.0 setget set_latitude
func set_latitude(value: float) -> void:
	latitude = value
	if Engine.editor_hint:
		_set_celestials_coords()

var longitude: float = 0.0 setget set_longitude
func set_longitude(value: float) -> void:
	longitude = value
	if Engine.editor_hint:
		_set_celestials_coords()

var utc: float = 0.0 setget set_utc
func set_utc(value: float) -> void:
	utc = value
	if Engine.editor_hint:
		_set_celestials_coords()

var celestials_update_time: float = 0.0
var _celestials_update_timer: float

var compute_moon_coords: bool = false setget set_compute_moon_coords
func set_compute_moon_coords(value: bool) -> void:
	compute_moon_coords = value
	if Engine.editor_hint:
		_set_celestials_coords()
		property_list_changed_notify()

var moon_coords_offset:= Vector2.ZERO setget set_moon_coords_offset
func set_moon_coords_offset(value: Vector2) -> void:
	moon_coords_offset = value
	if Engine.editor_hint:
		_set_celestials_coords()

var _sun_coords: Vector2
var _moon_coords: Vector2
var _latitude_rad: float
var _sun_distance: float
var _true_sun_longitude: float 
var _mean_sun_longitude: float
var _sideral_time: float 
var _local_sideral_time: float
var _time_scale: float
var _oblecl: float # Obliquity of the ecliptic
var _sun_orbital_elements:= OrbitalElements.new()
var _moon_orbital_elements:= OrbitalElements.new()

func _set_latitude_rad() -> void:
	_latitude_rad = deg2rad(latitude)

func _set_total_hours_utc() -> void:
	_total_hours_utc = total_hours - utc

func _set_time_scale() -> void:
	_time_scale = (367.0 * year - (7.0 * (year + ((month + 9.0) / 12.0))) / 4.0 + (275.0 * month) / 9.0 + day - 730530.0) + total_hours / 24.0;

func _set_oblecl() -> void:
	_oblecl = deg2rad(23.4393 - 3.563e-7 * _time_scale);

func _init() -> void:
	set_total_hours(total_hours)
	set_day(day)
	set_month(month)
	set_year(year)
	set_latitude(latitude)
	set_longitude(longitude)
	set_utc(utc)

func _ready() -> void:
	set_sky_node_path(sky_node_path)

func _process(delta: float) -> void:
	if Engine.editor_hint: 
		return
	if not system_sync:
		_set_is_leap_year()
		_set_max_days_per_month()
		_set_time_cycle_duracion()
		_set_is_beging_of_time()
		_set_is_end_of_time()
		_time_process(delta)
		_check_cycle()
	else:
		_get_date_time_os()
	
	_celestials_update_timer += delta
	if _celestials_update_timer > celestials_update_time:
		_set_celestials_coords()
		_celestials_update_timer = 0.0

func set_time(hour: int, minute: int, second: int) -> void:
	set_total_hours(DateTimeUtil.hours_to_total_hours(hour, minute, second))

func _set_is_leap_year() -> void:
	_is_leap_year = DateTimeUtil.get_leap_year(year)

func _set_max_days_per_month() -> void:
	match month:
		1, 3, 5, 7, 8, 10, 12: _max_days_per_month = 31
		2: _max_days_per_month = 29 if _is_leap_year else 28
		
	_max_days_per_month = 30

func _set_time_cycle_duracion() -> void:
	_time_cycle_duration = total_cycle_in_minutes * 60.0

func _set_is_beging_of_time() -> void:
	_is_beging_of_time = year == 1 && month == 1 && day == 1
	
func _set_is_end_of_time() -> void:
	_is_end_of_time = year == 9999 && month == 12 && day == 31
#-------------------------------------------------------------------------------

func _time_process(delta: float) -> void:
	if _time_cycle_duration != 0.0:
		total_hours += delta / _time_cycle_duration * DateTimeUtil.TOTAL_HOURS

func _get_date_time_os() -> void:
	_date_time_os = OS.get_datetime()
	set_time(_date_time_os.hour, _date_time_os.minute, _date_time_os.second)
	day = _date_time_os.day
	month = _date_time_os.month
	year = _date_time_os.year

func _repeat_full_cycle() -> void:
	if _is_end_of_time && total_hours >= 23.9999:
		year = 1; month = 1; day = 1
		total_hours = 0.0
	
	if _is_beging_of_time && total_hours < 0.0:
		year = 9999; month = 12; day = 31
		total_hours = 23.9999

func _check_cycle() -> void:
	# Check time cycle.
	if total_hours > 23.9999:
		day += 1 
		total_hours = 0.0
		emit_signal("day_changed", day)
	if total_hours < 0.0000:
		day -= 1 
		total_hours = 23.9999
		emit_signal("day_changed", day)
	
	# Check days and add month.
	if day > _max_days_per_month: 
		month += 1; 
		day = 1
		emit_signal("month_changed", month)
	if day < 1: 
		month -= 1; day = 31
		emit_signal("month_changed", month)
	
	# Check months and add years.
	if month > 12: 
		year += 1; month = 1
		emit_signal("year_changed", year)
	if month < 1: 
		year -= 1; month = 12
		emit_signal("year_changed", year)

func _set_celestials_coords():
	if sky_node_found:
		match celestial_calculations:
			CelestialCalculationsMode.Realistic:
				_compute_sun_coordinates()
				sky_node.sun_altitude = _sun_coords.y * SkyMath.RAD_2_DEG
				sky_node.sun_azimuth = _sun_coords.x * SkyMath.RAD_2_DEG
				if compute_moon_coords:
					_compute_moon_coordinates()
					sky_node.moon_altitude = _moon_coords.y * SkyMath.RAD_2_DEG
					sky_node.moon_azimuth = _moon_coords.x * SkyMath.RAD_2_DEG
			
			CelestialCalculationsMode.Simple:
				_compute_simple_sun_coordinates()
				sky_node.sun_altitude = _sun_coords.y
				sky_node.sun_azimuth = _sun_coords.x
				if compute_moon_coords:
					_compute_simple_moon_coordinates()
					sky_node.moon_altitude = _moon_coords.y
					sky_node.moon_azimuth = _moon_coords.x
					

func _compute_simple_sun_coordinates() -> void:
	_set_total_hours_utc(); 
	_set_latitude_rad()
	var t = _total_hours_utc + (SkyMath.DEG_2_RAD * longitude)
	var alt = t * (360/24);
	_sun_coords.y = (180.0) -alt;
	_sun_coords.x = latitude

func _compute_simple_moon_coordinates() -> void:
	_moon_coords.y = (180.0 - _sun_coords.y) + moon_coords_offset.y
	_moon_coords.x = (180.0 + _sun_coords.x) + moon_coords_offset.x

# x = azimuth y = altitude.
func _compute_sun_coordinates() -> void:
	_set_latitude_rad(); _set_total_hours_utc(); _set_time_scale()
	_set_oblecl()
	
	# Get orbital elements.
	_sun_orbital_elements.get_orbital_elements(0, _time_scale) 
	_sun_orbital_elements.M = SkyMath.rev(_sun_orbital_elements.M)
	
	# Mean Anomaly in radians.
	var MRad: float = SkyMath.DEG_2_RAD * _sun_orbital_elements.M
	
	# Eccentric anomaly.
	#E = M + (180/pi) * e * sin(M) * (1 + e * cos(M))
	var E: float = _sun_orbital_elements.M + SkyMath.RAD_2_DEG * _sun_orbital_elements.e * sin(MRad) * (1 + _sun_orbital_elements.e * cos(MRad))
	
	var ERad = SkyMath.DEG_2_RAD * E
	
	# Rectangular coordinates.
	# Rectangular coordinates of the sun in the plane of the ecliptic.
	var xv: float = cos(ERad) - _sun_orbital_elements.e
	var yv: float = sin(ERad) * sqrt(1 - _sun_orbital_elements.e * _sun_orbital_elements.e)
	
	# Convert to distance and true anomaly(r = radians, v = degrees).
	var r: float = sqrt(xv * xv + yv * yv)
	var v: float = SkyMath.RAD_2_DEG * atan2(yv, xv)
	_sun_distance = r # Set sun distance.

	# True longitude.
	var lonSun: float = v + _sun_orbital_elements.w
	lonSun = SkyMath.rev(lonSun) # Normalize.
	var lonSunRad: float = SkyMath.DEG_2_RAD * lonSun # To radians.
	_true_sun_longitude = lonSunRad # Set sun longitude
	
	# Ecliptic and Ecuatorial coords.
	# Ecliptic rectangular coordinates
	var xs: float = r * cos(lonSunRad)
	var ys: float = r * sin(lonSunRad)
	
	# Ecliptic rectangular coordinates rotate these to equatorial coordinates
	var oblecCos: float = cos(_oblecl)
	var oblecSin: float = sin(_oblecl)
	var xe: float = xs
	var ye: float = ys * oblecCos - 0.0 * oblecSin
	var ze: float = ys * oblecSin + 0.0 * oblecCos

	# ascension and declination.
	var RA: float = SkyMath.RAD_2_DEG * atan2(ye, xe) / 15 # Right ascension.
	
	# Decl =  atan2( zequat, sqrt( xequat*xequat + yequat*yequat) )
	var decl = atan2(ze, sqrt(xe * xe + ye * ye)) # Declination.
	
	# Mean longitude.
	var L: float = _sun_orbital_elements.w + _sun_orbital_elements.M
	L = SkyMath.rev(L)
	
	# Set mean sun longitude.
	_mean_sun_longitude = L
	
	# Sideral time.
	var GMST0 = ((L/15) + 12)
	
	_sideral_time = GMST0 + _total_hours_utc + longitude / 15 # + 15 / 15
	_local_sideral_time =  SkyMath.DEG_2_RAD * _sideral_time * 15
	
	# Hour angle.
	var HA: float = (_sideral_time - RA) * 15
	
	# Hour angle in radians.
	var HARAD: float = SkyMath.DEG_2_RAD * HA
	
	# Hour angle and declination in rectangular coords.
	# HA anf Decl in rectangular coordinates.
	var declCos: float = cos(decl)
	var x: float = cos(HARAD) * declCos # X Axis points to the celestial equator in the south.
	var y: float = sin(HARAD) * declCos # Y axis points to the horizon in the west.
	var z: float = sin(decl) # Z axis points to the north celestial pole.
	
	# Rotate the rectangualar coordinates system along of the Y axis.
	var sinLat: float = sin(latitude * SkyMath.DEG_2_RAD)
	var cosLat: float = cos(latitude * SkyMath.DEG_2_RAD)
	var xhor: float = x * sinLat - z * cosLat
	var yhor: float = y
	var zhor: float = x * cosLat + z * sinLat
	
	# Return azimtuh and altitude.
	_sun_coords.x = atan2(yhor, xhor) + PI
	_sun_coords.y =(PI * 0.5) - asin(zhor) # atan2(zhor, sqrt(xhor * xhor + yhor * yhor)) 
	

func _compute_moon_coordinates() -> void:
	# Orbital elements.
	_moon_orbital_elements.get_orbital_elements(1, _time_scale)
	_moon_orbital_elements.N = SkyMath.rev(_moon_orbital_elements.N)
	_moon_orbital_elements.w = SkyMath.rev(_moon_orbital_elements.w)
	_moon_orbital_elements.M = SkyMath.rev(_moon_orbital_elements.M)
	
	var NRad: float = SkyMath.DEG_2_RAD * _moon_orbital_elements.N
	var IRad: float = SkyMath.DEG_2_RAD * _moon_orbital_elements.i
	var MRad: float = SkyMath.DEG_2_RAD * _moon_orbital_elements.M
	
	# Eccentric anomaly.
	var E: float = _moon_orbital_elements.M + SkyMath.RAD_2_DEG * _moon_orbital_elements.e * sin(MRad) * (1 + _sun_orbital_elements.e * cos(MRad)) 
	var ERad: float = SkyMath.DEG_2_RAD * E
	
	# Rectangular coordinates of the sun in the plane of the ecliptic.
	var xv: float = _moon_orbital_elements.a * (cos(ERad) - _moon_orbital_elements.e)
	var yv: float = _moon_orbital_elements.a *(sin(ERad) * sqrt(1 - _moon_orbital_elements.e * _moon_orbital_elements.e)) * sin(ERad)
	
	# Convert to distance and true anomaly(r = radians, v = degrees).
	var r: float = sqrt(xv * xv + yv * yv)
	var v: float = SkyMath.RAD_2_DEG * atan2(yv, xv)
	v = SkyMath.rev(v)
	
	var l: float = SkyMath.DEG_2_RAD * v + _moon_orbital_elements.w
	
	var cosL: float = cos(l)
	var sinL: float = sin(l)
	var cosNRad: float = cos(NRad)
	var sinNRad: float = sin(NRad)
	var cosIRad: float = cos(IRad)
	
	var xeclip: float = r * (cosNRad * cosL - sinNRad * sinL * cosIRad)
	var yeclip: float = r * (sinNRad * cosL + cosNRad * sinL * cosIRad)
	var zeclip: float = r * (sinL * sin(IRad))
	
	# Geocentric coordinates.
	# Geocentric position for the moon and Heliocentric position for the planets.
	var lonecl: float = SkyMath.RAD_2_DEG * atan2(yeclip, xeclip)
	lonecl = SkyMath.rev(lonecl)
	
	var latecl: float = SkyMath.RAD_2_DEG * atan2(zeclip, sqrt(xeclip * xeclip + yeclip * yeclip))
	
	# Get true sun longitude.
	var lonsun: float = _true_sun_longitude
	
	# Ecliptic longitude and latitude in radians.
	var loneclRad: float = SkyMath.DEG_2_RAD * lonecl
	var lateclRad: float = SkyMath.DEG_2_RAD * latecl
	
	var nr: float = 1.0
	var xh: float = nr * cos(loneclRad) * cos(lateclRad)
	var yh: float = nr * sin(loneclRad) * cos(lateclRad)
	var zh: float = nr * sin(lateclRad)
	
	# Geocentric position.
	var xs: float = 0.0
	var ys: float = 0.0
	
	# Convert the geocentric position to heliocentric position.
	var xg: float = xh + xs
	var yg: float = yh + ys 
	var zg: float = zh
	
	# Ecuatorial coordinates.
	# Convert xg, yg in equatorial coordinates.
	var obleclCos: float = cos(_oblecl)
	var obleclSin: float = sin(_oblecl)
	
	var xe: float = xg 
	var ye: float = yg * obleclCos - zg * obleclSin
	var ze: float = yg * obleclSin + zg * obleclCos
	
	# Right ascension.
	var RA: float = SkyMath.RAD_2_DEG * atan2(ye, xe)
	RA = SkyMath.rev(RA)
	
	# Declination.
	var decl: float = SkyMath.RAD_2_DEG * atan2(ze, sqrt(xe * xe + ye * ye))
	var declRad: float = SkyMath.DEG_2_RAD * decl

	# Hour angle.
	var HA: float = ((_sideral_time * 15) - RA)
	HA = SkyMath.rev(HA)
	var HARad: float = SkyMath.DEG_2_RAD * HA
	
	# HA y Decl in rectangular coordinates.
	var declCos: float = cos(declRad)
	var xr = cos(HARad) * declCos
	var yr = sin(HARad) * declCos
	var zr = sin(declRad)
	
	# Rotate the rectangualar coordinates system along of the Y axis(radians).
	var sinLat: float = sin(_latitude_rad)
	var cosLat: float = cos(_latitude_rad)
	
	var xhor: float = xr * sinLat - zr * cosLat
	var yhor: float = yr
	var zhor: float = xr * cosLat + zr * sinLat
	
	_moon_coords.x = atan2(yhor, xhor) + PI 
	_moon_coords.y = (PI * 0.5) - atan2(zhor, sqrt(xhor * xhor + yhor * yhor)) # asin(zhor) 

func _get_property_list() -> Array:
	var ret: Array 
	ret.push_back({name = "Time Of Day", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	
	ret.push_back({name = "DateTime", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "system_sync", type=TYPE_BOOL})
	
	ret.push_back({name = "total_cycle_in_minutes", type=TYPE_REAL})
	ret.push_back({name = "total_hours", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0.0, 24.0"})
	ret.push_back({name = "day", type=TYPE_INT, hint=PROPERTY_HINT_RANGE, hint_string="0, 31"})
	ret.push_back({name = "month", type=TYPE_INT, hint=PROPERTY_HINT_RANGE, hint_string="0, 12"})
	ret.push_back({name = "year", type=TYPE_INT, hint=PROPERTY_HINT_RANGE, hint_string="-9999, 9999"})
	
	ret.push_back({name = "Planetary And Location", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "celestial_calculations", type=TYPE_INT, hint=PROPERTY_HINT_ENUM, hint_string="Simple, Realistic"})
	ret.push_back({name = "compute_moon_coords", type=TYPE_BOOL})
	
	if celestial_calculations == 0 && compute_moon_coords:
		ret.push_back({name = "moon_coords_offset", type=TYPE_VECTOR2})
	
	ret.push_back({name = "latitude", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-90.0, 90.0"})
	ret.push_back({name = "longitude", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	ret.push_back({name = "utc", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="-12.0, 12.0"})
	ret.push_back({name = "celestials_update_time", type=TYPE_REAL})
	ret.push_back({name = "Target", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sky_node_path", type=TYPE_NODE_PATH})
	
	return ret
