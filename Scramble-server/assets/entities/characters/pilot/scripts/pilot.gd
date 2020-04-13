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

extends Spatial

var last_update = OS.get_unix_time()

remote func _update_position(new_transform):
    var sender_id = get_tree().get_rpc_sender_id()

    self.transform = new_transform

    # Send all other clients the updates of this player too
    for id in Global.player_ids:
        # Don't send to self again
        if id == sender_id:
            continue

        rpc_id(id, "_update_position", new_transform)

    self.last_update = OS.get_unix_time()


func _process(_delta):
    if (OS.get_unix_time() - self.last_update) > 3.0:
        # TODO fade player because outdated
        pass
