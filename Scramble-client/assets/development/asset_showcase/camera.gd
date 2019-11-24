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

extends Camera

var rotate = false

var yaw
var pitch
var zoom_speed = 0

const rotation_speed = 0.01
const translation_speed = 0.1

func _ready():
	self.yaw = self.get_node("../../")
	self.pitch = self.get_node("./../../Pitch")

func _process(delta):
	if Input.is_key_pressed(KEY_W):
		var dir = Vector3(0, 0, (-1) * self.zoom_speed * delta)
		self.translate_object_local(dir)
	if Input.is_key_pressed(KEY_S):
		var dir = Vector3(0, 0, self.zoom_speed * delta)
		self.translate_object_local(dir)
		
	if Input.is_key_pressed(KEY_A):
		var dir = Vector3((-1) * self.zoom_speed * delta, 0, 0)
		self.translate_object_local(dir)
	if Input.is_key_pressed(KEY_D):
		var dir = Vector3(self.zoom_speed * delta, 0, 0)
		self.translate_object_local(dir)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			self.rotate = event.pressed
	
	if self.rotate:
		if event is InputEventMouseMotion:
			var y_axis = Vector3(0, 1, 0)
			self.yaw.rotate(y_axis, event.relative.x * rotation_speed)
			
			var x_axis = Vector3(1, 0, 0)
			self.pitch.rotate_object_local(x_axis, event.relative.y * rotation_speed)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			self.zoom_speed += translation_speed
		elif event.button_index == BUTTON_WHEEL_DOWN:
			self.zoom_speed -= translation_speed
