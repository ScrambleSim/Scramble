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

var GAME_VERSION = "local"

func _ready():
    self.set_version()
    self.set_process_name()
    self.print_client_info()


func set_version():
    var file = File.new()
    file.open("res://meta/version.txt", file.READ)
    var content = file.get_as_text()
    file.close()

    # Only change default value if in exported mode
    if content:
        self.GAME_VERSION = content


func set_process_name():
# warning-ignore:return_value_discarded
    OS.set_thread_name("Scramble %s client" % GAME_VERSION)


func print_client_info():
    var local_time = OS.get_time(false)
    var utc_time = OS.get_time(true)

    print("================================================================================")
    print()
    print(" ✈️  Scramble client ️✈️ ")
    print()
    print(" Version:    \t%s" % GAME_VERSION)
    print(" Platform:   \t%s" % OS.get_name())
    print(" Locale:     \t%s" % OS.get_locale())
    print(" Process id: \t%s" % OS.get_process_id())
    print(" Local time: \t%s" % self.format_time(local_time))
    print(" UTC time:   \t%s" % self.format_time(utc_time))
    print(" Exec path:  \t%s" % OS.get_executable_path())
    print(" User path:  \t%s" % OS.get_user_data_dir())
    print(" Debug build:\t%s" % OS.is_debug_build())
    print()
    print("================================================================================")
    print()


# Prints text with an UTC time prefix
func log(text):
    var utc_time = OS.get_time(true)
    print(" %s\t%s" % [self.format_time(utc_time), text])


func format_time(time):
    return "%s:%s:%s" % [
        str(time.hour).pad_zeros(2),
        str(time.minute).pad_zeros(2),
        str(time.second).pad_zeros(2)
    ]
