class_name OrbitalElements
"""========================================================
°                       Universal Sky.
°                   ======================
°
°   Category: TimeOfDay.
°   -----------------------------------------------------
°   Description:
°       Planetary orbital elements.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2020. MIT License.
°                   See: LICENSE Archive.
========================================================"""
var N: float # Longitude of the ascending node.
var i: float # The Inclination to the ecliptic.
var w: float # Argument of perihelion.
var a: float # Semi-major axis, or mean distance from sun.
var e: float # Eccentricity.
var M: float # Mean anomaly.

func get_orbital_elements(index: int, timeScale: float) -> void:
	if index == 0: # Sun.
		N = 0.0
		i = 0.0
		w = 282.9404 + 4.70935e-5 * timeScale
		a = 0.0
		e = 0.016709 - 1.151e-9 * timeScale
		M = 356.0470 + 0.9856002585 * timeScale
	else: # Moon.
		N = 125.1228 - 0.0529538083 * timeScale
		i = 5.1454
		w = 318.0634 + 0.1643573223 * timeScale
		a = 60.2666
		e = 0.054900
		M = 115.3654 + 13.0649929509 * timeScale
