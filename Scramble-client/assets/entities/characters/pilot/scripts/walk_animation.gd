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

# What animation to play -1=standing 0=walking 1=running
func set_animation(animation_index):
    $"WalkTween".interpolate_property(
        $"../Visuals/AnimationTree",
        "parameters/movement/blend_amount",
        $"../Visuals/AnimationTree".get("parameters/movement/blend_amount"),
        animation_index,
        0.2,
        Tween.TRANS_EXPO,
        Tween.EASE_OUT
    )
    $"WalkTween".start()
