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

# Adds flying camera movement to its parent

extends Node

var parent
var pitch

func _ready():
    self.parent = get_parent()
    self.pitch = self.parent.get_node("Pitch")


func _process(delta):
    var offset = Vector3(PropertyManager.debug_cam_left_right * delta * (-1), PropertyManager.debug_cam_up_down * delta * (-1), PropertyManager.debug_cam_forward_back * delta)
    parent.translate_object_local(offset)


func _input(event):
    if event is InputEventMouseMotion:
        self.parent.rotate_y(event.relative.x * 0.01 * -1)
        self.pitch.rotate_x(event.relative.y * 0.01 * -1)

