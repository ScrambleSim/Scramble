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

extends RayCast

var wants_to_interact = false


func _ready():
	PropertyManager.connect("interact_with_changed", self, "_on_interact_with")


# Raycasts use physics to _fixed_process is used
func _physics_process(delta):
	if self.wants_to_interact:
		if self.is_colliding():
			var other = self.get_collider()
			if other.name == "Seat1":
				wants_to_interact = false
				# TODO send server entry request
				pass


func _on_interact_with(newVal):
	if newVal > 0:
		self.wants_to_interact = true
	else:
		self.wants_to_interact = false
