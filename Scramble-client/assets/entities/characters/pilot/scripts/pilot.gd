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

var target_pos = Vector3(0,0,0)

# Relevant if this instance is a slave/puppet
puppet func _update_position(new_transform):
    if get_tree().get_rpc_sender_id() == 1:
        self.target_pos = new_transform.origin


func _process(_delta):
    if self.is_posessed:
        rpc_id(1, "_update_position", self.transform)
    else:
        self.transform.origin = self.transform.origin.linear_interpolate(self.target_pos, 0.3)


func _vehicle_enter_request():
    pass
