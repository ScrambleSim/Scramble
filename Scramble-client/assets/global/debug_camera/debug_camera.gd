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

const CAMERA_SCENE_PATH = "res://assets/global/debug_camera/camera.tscn"

var debugging = false

# Where debug camera was last before being turned off
var prev_debug_cam_transform

# Children
var camera = null
var ui = null

func _input(event):
    # TODO replace with Scramble's input handling/remapping
    if event is InputEventKey:
        if event.scancode == KEY_F12:
            if event.pressed:
                self.debugging = !self.debugging

                if debugging:
                    self.add_debug_camera()
                else:
                    self.remove_debug_camera()


func add_debug_camera():
    self.add_camera()
    self.add_ui()


func remove_debug_camera():
    self.prev_debug_cam_transform = camera.transform
    camera.queue_free()
    ui.queue_free()


func add_camera():
    var camera_scene = load(CAMERA_SCENE_PATH)
    camera = camera_scene.instance()

    if self.prev_debug_cam_transform:
        camera.transform = self.prev_debug_cam_transform
    else:
        var active_cameras_transform = self.get_viewport() \
                                        .get_camera() \
                                        .get_camera_transform()

        camera.transform = active_cameras_transform

    self.add_child(camera)


func add_ui():
    var ui_scene = load("res://assets/global/debug_camera/ui.tscn")
    ui = ui_scene.instance()
    self.add_child(ui)

