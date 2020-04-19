# Scramble
# Copyright (C) 2018  ScrambleSim and contributors
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Serves as the interface to the settings UI for other nodes.

extends Control

# warning-ignore:unused_signal
signal settings_opened
# warning-ignore:unused_signal
signal settings_closed

var previous_mouse_mode = 0

func show_settings():
    self._play_animation("blend_in")
    self.previous_mouse_mode = Input.get_mouse_mode()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    emit_signal("settings_opened")


func hide_settings():
    self._play_animation("blend_out")
    Input.set_mouse_mode(previous_mouse_mode)
    emit_signal("settings_closed")


func _play_animation(animation_name):
    get_node("AnimationPlayer").play(animation_name)
