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

# Represents the mappings from input events to properties

extends Node

var mappings    # the parsed settings from JSON

func _ready():
    var file = File.new()
    file.open("res://config/input_mappings.json", file.READ)
    var content = file.get_as_text()
    file.close()
    
    self.mappings = JSON.parse(content).result


func save_settings():
    var file = File.new()
    file.open("res://config/input_mappings.json", file.WRITE)
    file.store_string(JSON.print(self.mappings))
    file.close()
