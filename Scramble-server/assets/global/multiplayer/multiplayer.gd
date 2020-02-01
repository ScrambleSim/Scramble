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
    
    # Creating the server fails if other server has already bound to it.
    if peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
        Global.log("Failed to bind to port %s. Maybe a server is already running on it?" % [
            PORT
        ])  
        Global.log("Shutting server down...")
        get_tree().quit()  
    else:
        Global.log("Server started, listening on port %s" % PORT)    


func _client_connected(new_id):
    Global.log("Client %s' connected to Server" % str(new_id))
    Global.player_ids.append(new_id)

    Global.log('Replicating world on client')
    self._replicate_world(new_id)

    Global.log('Spawning pilot on all clients')
    self._add_pilot(new_id)


# Called if a player closes a game gracefully
# Clients also time out if not gracefully disconnecting
func _client_disconnected(id):
    Global.log('Client %s disconnected from Server' % str(id))

    Global.player_ids.erase(id)

    get_node(ENTITIES_PATH + "/C172p" + ('/%s' % str(id))).queue_free()


# Spawn player representation on server
func _add_pilot(target_client):
    var newPlayer = load(PILOT_SCENE_PATH).instance()
    newPlayer.set_name(str(target_client))  # spawn players with their respective names
    get_node(ENTITIES_PATH).add_child(newPlayer)

    for client_id in Global.player_ids:
        newPlayer.get_node("Replication").replicate(client_id)


# Replicates the server's world on a passed client
func _replicate_world(target_client):
    get_tree().call_group("Replicated", "replicate", target_client)


# spawn an entity at a client based on a given path to its scene
# spawn_info contains information about how spawning should happen
func spawn_entity_remote(target_client, spawn_info):
    Global.log(
        'Sending client %s a command to spawn an entity from: %s' % [
            str(target_client),
            str(spawn_info.recipe_path)
        ]
    )
    rpc_id(target_client, "spawn_entity", spawn_info)


remote func reparent_entity(source_node_path, target_parent_node_path):
    var child_node = get_node(source_node_path)
    child_node.get_parent().remove_child(child_node)
    get_node(target_parent_node_path).add_child(child_node)
