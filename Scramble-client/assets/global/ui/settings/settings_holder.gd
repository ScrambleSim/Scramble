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

# Persistant node in the scene. Creates and destroys the settings UI on demand.

extends Node

const SETTINGS_SCENE_PATH = "res://assets/global/ui/settings/settings.tscn"
const SETTINGS_NODE_NAME = "Settings"

onready var settings_scene = preload(SETTINGS_SCENE_PATH)

func _ready():
# warning-ignore:return_value_discarded
    PropertyManager.connect("show_settings_changed", self, "_show_settings")


func on_settings_hidden():
    get_node(SETTINGS_NODE_NAME).queue_free()


func _show_settings(new_val):
    if !has_node(SETTINGS_NODE_NAME):
        self.create_settings_node()
# warning-ignore:return_value_discarded
        get_node(SETTINGS_NODE_NAME).connect("settings_hidden", self, "on_settings_hidden")
    
    if new_val == 0.0:
        get_node(SETTINGS_NODE_NAME).hide_settings()
    else:
        get_node(SETTINGS_NODE_NAME).show_settings()


func create_settings_node():
    var instance = settings_scene.instance()
    add_child(instance)
