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

const PILOT_SCENE_PATH = "res://assets/entities/characters/pilot/pilot.tscn"
const ENTITIES_PATH = "/root/Scramble/World/Entities"


remote func spawn_player(id, position):
    _create_pilot(id, position, true)


remote func spawn_slave(id, position):
    _create_pilot(id, position, false)


remote func spawn_plane(id, position):
    _create_plane(id, position)


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
        return	# ignore connect event for self


func _client_disconnected(id):
    Global.log("Other Player (id: " + str(id) + ") disconnected from server")

    get_node(ENTITIES_PATH).get_node(str(id)).queue_free()


# Called when connecting worked (called after network_peer_connected arrives for self)
func _connected_ok():
    Global.log("Successfully connected to server!")
    Global.log("Unique ID of this client: " + str(get_tree().get_network_unique_id()))


func _connected_fail():
    Global.log("Connect to server failed!")


func _server_disconnected():
    Global.log("Server disconnected")


func _create_pilot(id, position, posessed):
    var newPilot = load(PILOT_SCENE_PATH).instance()
    newPilot.is_posessed = posessed
    newPilot.set_name(str(id))	# spawn players with their respective names
    newPilot.transform.origin = position
    get_node(ENTITIES_PATH).add_child(newPilot)


func _create_plane(id, position):
    # TODO create plane
    Global.log("TODO create plane")
    pass
