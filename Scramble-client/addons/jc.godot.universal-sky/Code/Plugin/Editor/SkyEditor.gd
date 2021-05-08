tool extends EditorPlugin
"""========================================================
°                       Universal Sky.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Editor Plugin.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2020. MIT License.
°                   See: LICENSE Archive.
========================================================"""
#---------------
# Manager.
var _sky_manager_script: Script =\
preload("res://addons/jc.godot.universal-sky/Code/Sky/SkyManager.gd")

var _sky_manager_icon: Texture =\
preload("res://addons/jc.godot.universal-sky-common/Assets/MyAssets/Graphics/Gizmos/SkyIcon.png")

# ToD.
var _time_of_day_script: Script =\
preload("res://addons/jc.godot.universal-sky/Code/TimeOfDay/TimeOfDay.gd")

var _time_of_day_icon: Texture =\
preload("res://addons/jc.godot.universal-sky-common/Assets/MyAssets/Graphics/Gizmos/SkyIcon.png")

func _enter_tree() -> void:
	add_custom_type("SkyManager", "Node", _sky_manager_script, _sky_manager_icon)
	add_custom_type("TimeOfDay", "Node", _time_of_day_script, _time_of_day_icon)

func _exit_tree() -> void:
	remove_custom_type("SkyManager")
	remove_custom_type("TimeOfDay")
