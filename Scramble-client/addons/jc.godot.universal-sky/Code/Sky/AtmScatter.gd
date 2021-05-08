class_name AtmScatter
"""========================================================
°                       Universal Sky.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Atmospheric Scattering Functions and Constants.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2020. MIT License.
°                   See: LICENSE Archive.
========================================================"""
#---------------------------------------
# Based on Hoffman and Preetham paper.
# See: 
#---------------------------------------
# Index of the air refraction.
const n: float = 1.0003

# Index of the air refraction ˆ 2
const n2: float = 1.00060009

# Molecular Density.
const N: float = 2.545e25 

# Depolatization factor for standard air.
const pn: float = 0.035

static func get_wavelenght_lambda(wavelenghts: Vector3) -> Vector3:
	return wavelenghts * 1e-9

static func get_wavelenght(lambda: Vector3) -> Vector3:
	var ret: Vector3 = lambda
	ret.x = pow(ret.x, 4.0)
	ret.y = pow(ret.y, 4.0)
	ret.z = pow(ret.z, 4.0)
	return ret

static func beta_ray(wavelenghts: Vector3) -> Vector3:
	var kr: float = (8.0 * pow(PI, 3.0) * pow(n2 - 1.0, 2.0) * (6.0 + 3.0 * pn))
	var ret: Vector3 = 3.0 * N * wavelenghts * (6.0 - 7.0 * pn)
	ret.x = kr / ret.x
	ret.y = kr / ret.y
	ret.z = kr / ret.z
	return ret

static func partial_mie_phase(g: float) -> Vector3:
	var g2: float = g * g
	var ret: Vector3
	#ret.x = ((1.0 - g2) / (2.0 + g2))
	ret.x = ((1.0 - g2))
	ret.y = 1.0 + g2
	ret.z = 2.0 * g
	return ret

# Simplifield.
static func beta_mie(mie: float, turbidity: float) -> Vector3:
	return Vector3.ONE * mie * turbidity * 0.000434

