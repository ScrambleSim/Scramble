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

extends Node2D

class Line:
    var start
    var end
    var line_color
    var time
    
    func _init(a_start, a_end, a_line_color, a_time):
        self.start = a_start
        self.end = a_end
        self.line_color = a_line_color
        self.time = a_time

var lines = []
var removed_line = false

func _process(delta):
    for i in range(len(lines)):
        lines[i].time -= delta
    
    if(len(lines) > 0 || removed_line):
        update() # Calls _draw
        removed_line = false

func _draw():
    var cam = get_viewport().get_camera()
    for i in range(len(lines)):
        var screen_point_start = cam.unproject_position(lines[i].start)
        var screen_point_end = cam.unproject_position(lines[i].end)
        
        # Dont draw line if either start or end is considered behind the camera
        # this causes the line to not be drawn sometimes but avoids a bug where the
        # line is drawn incorrectly
        if(cam.is_position_behind(lines[i].start) ||
            cam.is_position_behind(lines[i].end)):
            continue
        
        draw_debug_line(screen_point_start, screen_point_end, lines[i].line_color)
    
    # Remove lines that have timed out
    var i = lines.size() - 1
    while (i >= 0):
        if(lines[i].time < 0.0):
            lines.remove(i)
            removed_line = true
        i -= 1

func draw_debug_line(start, end, line_color, time = 0.0):
    lines.append(Line.new(start, end, line_color, time))

func draw_debug_ray(start, ray, line_color, time = 0.0):
    lines.append(Line.new(start, start + ray, line_color, time))

func draw_cube(center, half_extents, line_color, time = 0.0):
    # Start at the 'top left'
    var line_point_start = center
    line_point_start.x -= half_extents
    line_point_start.y += half_extents
    line_point_start.z -= half_extents
    
    # Draw top square
    var line_point_end = line_point_start + Vector3(0, 0, half_extents * 2.0)
    draw_debug_line(line_point_start, line_point_end, line_color, time);
    line_point_start = line_point_end
    line_point_end = line_point_start + Vector3(half_extents * 2.0, 0, 0)
    draw_debug_line(line_point_start, line_point_end, line_color, time);
    line_point_start = line_point_end
    line_point_end = line_point_start + Vector3(0, 0, -half_extents * 2.0)
    draw_debug_line(line_point_start, line_point_end, line_color, time);
    line_point_start = line_point_end
    line_point_end = line_point_start + Vector3(-half_extents * 2.0, 0, 0)
    draw_debug_line(line_point_start, line_point_end, line_color, time);
    
    # Draw bottom square
    line_point_start = line_point_end + Vector3(0, -half_extents * 2.0, 0)
    line_point_end = line_point_start + Vector3(0, 0, half_extents * 2.0)
    draw_debug_line(line_point_start, line_point_end, line_color, time);
    line_point_start = line_point_end
    line_point_end = line_point_start + Vector3(half_extents * 2.0, 0, 0)
    draw_debug_line(line_point_start, line_point_end, line_color, time);
    line_point_start = line_point_end
    line_point_end = line_point_start + Vector3(0, 0, -half_extents * 2.0)
    draw_debug_line(line_point_start, line_point_end, line_color, time);
    line_point_start = line_point_end
    line_point_end = line_point_start + Vector3(-half_extents * 2.0, 0, 0)
    draw_debug_line(line_point_start, line_point_end, line_color, time);
    
    # Draw vertical lines
    line_point_start = line_point_end
    draw_debug_ray(line_point_start, Vector3(0, half_extents * 2.0, 0), line_color, time)
    line_point_start += Vector3(0, 0, half_extents * 2.0)
    draw_debug_ray(line_point_start, Vector3(0, half_extents * 2.0, 0), line_color, time)
    line_point_start += Vector3(half_extents * 2.0, 0, 0)
    draw_debug_ray(line_point_start, Vector3(0, half_extents * 2.0, 0), line_color, time)
    line_point_start += Vector3(0, 0, -half_extents * 2.0)
    draw_debug_ray(line_point_start, Vector3(0, half_extents * 2.0, 0), line_color, time)
