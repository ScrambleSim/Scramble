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

# Gets input events from godot, executes mappings
# Delegates the events to the property manager according to mappings
# set in a conifg file

extends Node

var property_manager			# sends changed signals
var input_mappings			# from file
var pressed_events = []		# already sent "pressed" events for keyboard

# How should a mapping act on a target value
enum InputType {
	TMP_INCREASE,
	TMP_DECREASE,
	PERMA_INCREASE,
	PERMA_DECREASE,
	TOGGLE,
	SET_VALUE
}


enum ReactionType {
	PRESSED,
	RELEASED,
}


func _ready():
	self.property_manager = $"/root/PropertyManager"
	self.input_mappings = $"/root/InputMappings".mappings


func _input(event):
	if (event is InputEventJoypadButton) or (event is InputEventKey):
		# Unify key and joy button events to behave the same
		var event_unified

		if event is InputEventJoypadButton:
			event_unified = event
		elif event is InputEventKey:
			event_unified = {
				device = -1,
				button_index = event.scancode,
				pressed = event.pressed,
			}

			if _already_sent_event(event_unified):
				return

		_apply_button_mappings(event_unified)

	elif event is InputEventJoypadMotion:
		_apply_joystick_mappings(event)


# Prevent already pressed key from repeating a "pressed" event
func _already_sent_event(event):
	if event.pressed:
		if self.pressed_events.has(event.button_index):
			return true
		else:
			self.pressed_events.append(event.button_index)
	else:
		self.pressed_events.erase(event.button_index)

	return false


# Iterate over all button mappings, execute if one applies
func _apply_button_mappings(event):
	for target in self.input_mappings.mappings:
		for mapping in self.input_mappings.mappings[target].button_mappings:
			if mapping.device_id == event.device:
				if mapping.button_id == event.button_index:
					# Convert event.pressed to enum
					var event_reaction_type = ReactionType.PRESSED if event.pressed else ReactionType.RELEASED
					if mapping.react_to == event_reaction_type:
						_execute_button_mapping(target, mapping)


func _execute_button_mapping(target, mapping):
	# Pass event to input manager
	if mapping.type == InputType.TMP_INCREASE:
		self.property_manager.tmp_increase(target, mapping.delta_value)
	elif mapping.type == InputType.TMP_DECREASE:
		self.property_manager.tmp_decrease(target, mapping.delta_value)
	elif mapping.type == InputType.PERMA_INCREASE:
		self.property_manager.perma_increase(target, mapping.delta_value)
	elif mapping.type == InputType.PERMA_DECREASE:
		self.property_manager.perma_decrease(target, mapping.delta_value)
	elif mapping.type == InputType.TOGGLE:
		self.property_manager.toggle(target)
	elif mapping.type == InputType.SET_VALUE:
		self.property_manager.set_value(target, mapping.value_to_set)


# Iterate over all joystick mappings, execute if one applies
func _apply_joystick_mappings(event):
	for target in self.input_mappings.mappings:
		for joystick_mapping in self.input_mappings.mappings[target].axis_mappings:
			if joystick_mapping.device_id == event.device:
				if joystick_mapping.axis_id == event.axis:
					_execute_joystick_mapping(target, event)


func _execute_joystick_mapping(target, event):
	self.property_manager.set_value(target, event.axis_value)
