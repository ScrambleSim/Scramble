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

extends Tabs


func _apply_settings():
    self._apply_fullscreen()
    self._apply_resolution()
    self._apply_vsync()
    self._apply_fps_counter()
    self._apply_antistropic()
    self._apply_msaa()


func _apply_fullscreen():
    var fullscreen = self.find_node("Fullscreen").pressed
    OS.window_fullscreen = fullscreen


func _apply_resolution():
    var width = self.find_node("ResolutionWidth").text
    width = int(width)
    
    var height = self.find_node("ResolutionHeight").text
    height = int(height)

    OS.window_size = Vector2(width, height)


func _apply_vsync():
    OS.vsync_enabled = self.find_node("VSync").pressed


func _apply_fps_counter():
    Global.log("TODO enable fps counter")
    # TODO


func _apply_antistropic():
    var msaa_setting = find_node("MsaaSetting")
    get_viewport().msaa = msaa_setting.selected


func _apply_msaa():
    pass


var previous_width
var previous_height
func _on_Fullscreen_toggled(button_pressed):
    var resolution_width = find_node("ResolutionWidth")
    var resolution_height = find_node("ResolutionHeight")
    
    resolution_width.deselect()
    resolution_height.deselect()
    
    # Disable if fullscreen
    resolution_width.editable = !button_pressed
    resolution_height.editable = !button_pressed
    
    # Can't set resolution if fullscreen, so monitor's resolution is used
    if button_pressed:
        self.previous_width = resolution_width.text
        self.previous_height = resolution_height.text
        
        resolution_width.text = str(OS.get_screen_size().x)
        resolution_height.text = str(OS.get_screen_size().y)#
    else:
        resolution_width.text = self.previous_width
        resolution_height.text = self.previous_height
