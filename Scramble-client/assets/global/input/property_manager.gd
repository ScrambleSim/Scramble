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

# Contains properties to which game logic
# can subscribe to.
# The values can be modified through several
# predefined methods.

extends Node

signal player_move_LR_changed(new_value)
var player_move_LR = 0.0

signal player_move_FB_changed(new_value)
var player_move_FB = 0.0

signal look_vertical_changed(new_value)
var look_vertical = 0.0

signal look_horizontal_changed(new_value)
var look_horizontal = 0.0

# Settings
signal show_settings_changed(new_value)
var show_settings = 0.0

# Debug gamera
signal debug_cam_forward_back_changed(new_value)
var debug_cam_forward_back = 0.0

signal debug_cam_up_down_changed(new_value)
var debug_cam_up_down = 0.0

signal debug_cam_left_right_changed(new_value)
var debug_cam_left_right = 0.0

signal interact_with_changed(new_value)
var interact_with = 0.0


func tmp_increase(target, amount):
	# TODO handle tmp part
	var tmp = self.get(target)
	tmp += amount
	tmp = clamp(tmp, 0.0, 1.0)
	self.set(target, tmp)
	emit_signal("%s_changed" % target, tmp)


func tmp_derease(target, amount):
	# TODO handle tmp part
	var tmp = self.get(target)
	tmp -= amount
	tmp = clamp(tmp, 0.0, 1.0)
	self.set(target, tmp)
	emit_signal("%s_changed" % target, tmp)


func perma_increase(target, amount):
	var tmp = self.get(target)
	tmp += amount
	tmp = clamp(tmp, 0.0, 1.0)
	self.set(target, tmp)
	emit_signal("%s_changed" % target, tmp)


func perma_decrease(target, amount):
	var tmp = self.get(target)
	tmp -= amount
	tmp = clamp(tmp, 0.0, 1.0)
	self.set(target, tmp)
	emit_signal("%s_changed" % target, tmp)


func toggle(target):
	var tmp = self.get(target)
	tmp = 0.0 if tmp > 0.5 else 1.0
	self.set(target, tmp)
	emit_signal("%s_changed" % target, tmp)


func set_value(target, value):
	var tmp = self.get(target)
	tmp = value
	#tmp = clamp(tmp, 0.0, 1.0)
	self.set(target, tmp)
	emit_signal("%s_changed" % target, tmp)
