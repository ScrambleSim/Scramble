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

# Semantic versioning
const MAJOR_VERSION = 0
const MINOR_VERSION = 0
const PATCH_VERSION = 1
const GAME_VERSION = "v%s.%s.%s" % [MAJOR_VERSION, MINOR_VERSION, PATCH_VERSION]

# Holds all ids of players currently on the server
var player_ids = []


func _init():
    self.set_process_name()
    self.print_server_info()


func set_process_name():
    OS.set_thread_name("Scramble %s server" % GAME_VERSION)


func print_server_info():
    var local_time = OS.get_time(false)
    var utc_time = OS.get_time(true)

    print("================================================================================")
    print()
    print(" ✈️  Scramble server ️✈️ ")
    print()
    print(" Version:    \t%s" % GAME_VERSION)
    print(" Platform:   \t%s" % OS.get_name())
    print(" Locale:     \t%s" % OS.get_locale())
    print(" Process id: \t%s" % OS.get_process_id())
    self.print_ips()
    print(" Local time: \t%s" % self.format_time(local_time))
    print(" UTC time:   \t%s" % self.format_time(utc_time))
    print(" Exec path:  \t%s" % OS.get_executable_path())
    print(" User path:  \t%s" % OS.get_user_data_dir())
    print(" Debug build:\t%s" % OS.is_debug_build())
    print()
    print("================================================================================")
    print()


# Prints all IPs the server has, both ipv4 and ipv6
func print_ips():
    var offset = "              \t"
    var ips = IP.get_local_addresses()
    for i in range(ips.size()):
        if i == 0:
            print(" IPs:      \t%s" % ips[i])
        else:
            print("%s%s" % [offset, str(ips[i])])


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
