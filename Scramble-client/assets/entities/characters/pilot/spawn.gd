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

extends Node

const SCENE_PATH = "res://assets/entities/characters/pilot/pilot.tscn"

func spawn(spawn_info, parent_node):
    var newPilot = load(SCENE_PATH).instance()
    newPilot.set_name(str(spawn_info.client_id))
    newPilot.is_posessed = spawn_info.is_posessed
    parent_node.add_child(newPilot)
    #newPilot.transform.translation = spawn_info.position
