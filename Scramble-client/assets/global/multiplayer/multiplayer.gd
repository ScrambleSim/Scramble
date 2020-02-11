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

const ENTITIES_PATH = "/root/Scramble/World/Entities"

# spawns an entity with scene_path according to spawn_info passed to it
remote func spawn_entity(spawn_info):
    Global.log("Recieved command to spawn entity from %s" % spawn_info.recipe_path)
    var SpawnClass = load(spawn_info.recipe_path)
    SpawnClass = SpawnClass.new()
    var parent_node = get_node(ENTITIES_PATH)
    SpawnClass.spawn(spawn_info, parent_node)
    SpawnClass.queue_free()
    


func _ready():
    get_tree().connect("network_peer_connected", self, "_client_connected")
    get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
    get_tree().connect("connected_to_server", self, "_connected_ok")
    get_tree().connect("connection_failed", self, "_connected_fail")
    get_tree().connect("server_disconnected", self, "_server_disconnected")

    var peer = NetworkedMultiplayerENet.new()
    peer.create_client("127.0.0.1", 5000)
    get_tree().set_network_peer(peer)


func _client_connected(id):
    if id == 1:
        return  # ignore connect event for self


func _client_disconnected(id):
    Global.log("Other Player (id: %s) disconnected from server" % str(id))


# Called when connecting worked (called after network_peer_connected arrives for self)
func _connected_ok():
    Global.log("Successfully connected to server!")
    Global.log("Unique ID of this client: %s" % str(get_tree().get_network_unique_id()))


func _connected_fail():
    Global.log("Connect to server failed!")


func _server_disconnected():
    Global.log("Server disconnected. Closing client")
    get_tree().quit()
