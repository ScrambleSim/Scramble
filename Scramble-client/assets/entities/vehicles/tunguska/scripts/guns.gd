extends MeshInstance


func _process(delta):
    var target_pos = get_node_or_null("/root/Scramble/World/Entities/fa18f")
    if not target_pos:
        return
    target_pos = target_pos.translation

    var current_rotation = self.rotation
    self.look_at(target_pos, Vector3.UP)
    var final_rotation = self.rotation

    self.rotation = current_rotation.linear_interpolate(final_rotation, delta * 2)
    self.rotation.y = 0
    self.rotation.z = 0
