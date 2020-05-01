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

extends KinematicBody

var is_posessed = false

var target_position = Vector3(0,0,0)
var target_rotation = Vector3(0,0,0)

# Relevant if this instance is a slave/puppet
remote func _update_position(new_position, new_rotation, target_animation_state):
    if get_tree().get_rpc_sender_id() == 1:
        self.target_position = new_position
        self.target_rotation = new_rotation
        $"WalkAnimation".set_animation(target_animation_state)

func _process(_delta):
    if self.is_posessed:
        var animation_state = $"Visuals/AnimationTree".get("parameters/movement/blend_amount")
        rpc_id(1, "_update_position", self.translation, self.rotation, animation_state)
    else:
        self.transform.origin = self.transform.origin.linear_interpolate(self.target_position, 0.3)
        self.rotation = self.rotation.linear_interpolate(self.target_rotation, 0.1)


func _vehicle_enter_request():
    pass
