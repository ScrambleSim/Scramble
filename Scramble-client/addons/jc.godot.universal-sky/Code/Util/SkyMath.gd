"""========================================================
°                       Universal Sky.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Math functions and constats.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2020. MIT License.
°                   See: LICENSE Archive.
========================================================"""
class_name SkyMath

const RAD_2_DEG: float = 57.2957795
const DEG_2_RAD: float = 0.0174533

static func saturate(value: float) -> float:
	return clamp(value, 0.0, 1.0)

static func rev(val: float) -> float:
	return val - int(floor(val / 360.0)) * 360.0

static func precise_lerp(from: float, to: float, t: float) -> float:
	return (1 - t) * from + t * to;

static func lerp_color(from: Color, to: Color, t: float) -> Color:
	var ret:Color
	ret.r = precise_lerp(from.r, to.r, t)
	ret.g = precise_lerp(from.g, to.g, t)
	ret.b = precise_lerp(from.b, to.b, t)
	ret.a = precise_lerp(from.a, to.a, t)
	return ret

static func distance(a: Vector3, b: Vector3) -> float:
	var ret: float
	var x: float = a.x - b.x
	var y: float = a.y - b.y
	var z: float = a.z - b.z 
	ret = x * x + y * y + z * z
	
	return sqrt(ret)

static func to_orbit(theta: float, pi: float, radius: float = 1.0) -> Vector3:
	var ret: Vector3 
	var sinTheta:  float = sin(theta)
	var cosTheta:  float = cos(theta)
	var sinPI:     float = sin(pi)
	var cosPI:     float = cos(pi)
	
	ret.x = sinTheta * sinPI
	ret.y = cosTheta
	ret.z = sinTheta * cosPI
	return ret * radius
