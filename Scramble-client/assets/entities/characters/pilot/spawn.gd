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

const ENTITIES_PATH = "/root/Scramble/World/Entities"

func spawn(spawn_settings):
    var newPilot = load(spawn_settings.scene_path).instance()
    newPilot.set_name(spawn_settings.id)
    newPilot.is_posessed = spawn_settings.posessed
    newPilot.transform.origin = spawn_settings.position
    get_node(ENTITIES_PATH).add_child(newPilot)

