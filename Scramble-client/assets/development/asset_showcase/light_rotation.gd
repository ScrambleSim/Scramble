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

extends DirectionalLight

var rotate_sun = false
var rotation_speed = 0.01

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2:
			self.rotate_sun = event.pressed

	if rotate_sun:
		if event is InputEventMouseMotion:
			var y_axis = Vector3(0, 1, 0)
			self.rotate(y_axis, event.relative.x * rotation_speed)
			
			var x_axis = Vector3(1, 0, 0)
			self.rotate_object_local(x_axis, event.relative.y * rotation_speed)
