extends Node


func _ready():
    if full_game_running():
        self.queue_free()

# not just running a single scene
func full_game_running():
    return not (get_node("/root/Scramble") == null)
