extends MeshInstance


func _process(delta):
    var target_pos = get_node_or_null("/root/Scramble/World/Entities/fa18f")
    if not target_pos:
        return
    target_pos = target_pos.translation

    self.look_at(target_pos, Vector3.UP)
    self.rotation = Vector3(self.rotation.x, 0, 0)
