extends MeshInstance


func _process(delta):
    var target_pos = get_node("/root/tunguska/debug_intercept").translation

    var current_rotation = self.rotation
    self.look_at(target_pos, Vector3.UP)
    var final_rotation = self.rotation

    self.rotation = current_rotation.linear_interpolate(final_rotation, delta * 2)
    self.rotation.y = 0
    self.rotation.z = 0
