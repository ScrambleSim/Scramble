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

const PORT = 5000
const MAX_PLAYER_COUNT = 200


func _ready():
    Global.log("Starting server")

    # Event setup
    get_tree().connect("network_peer_connected", self, "_client_connected")
    get_tree().connect("network_peer_disconnected", self, "_client_disconnected")

    # Start server
    var peer = NetworkedMultiplayerENet.new()
    peer.create_server(PORT, MAX_PLAYER_COUNT)
    get_tree().set_network_peer(peer)

    Global.log("Server started, listening on port %s" % PORT)

    self._replicate_world('1234')


func _client_connected(new_id):
    Global.log('Client ' + str(new_id) + ' connected to Server')
    Global.player_ids.append(new_id)

    Global.log('Spawning pilot')
    self._add_pilot(new_id)

    Global.log('Replicating world on client')
    self._replicate_world(new_id)


# Called if a player closes a game gracefully
# Clients also time out if not gracefully disconnecting
func _client_disconnected(id):
    Global.log('Client ' + str(id) + ' disconnected from Server')

    Global.player_ids.erase(id)

    get_node(ENTITIES_PATH + ('/%s' % str(id))).queue_free()


# Spawn player representation on server
func _add_pilot(client_id):
    var newPlayer = load(PILOT_SCENE_PATH).instance()
    newPlayer.set_name(str(client_id))  # spawn players with their respective names
    get_node(ENTITIES_PATH).add_child(newPlayer)


# Replicates the server's world on a passed client
func _replicate_world(client_id):
    get_tree().call_group("Replicated", "replicate", client_id)


# spawn an entity at a client based on a given path to its scene
# spawn_info contains information about how spawning should happen
func spawn_entity_remote(spawn_info):
    Global.log(
        'Sending client %s a command to spawn an entity at path: %s' % [
            str(spawn_info.client_id),
            str(spawn_info.scene_path)
        ]
    )
    rpc_id(spawn_info.client_id, "spawn_entity", spawn_info)
