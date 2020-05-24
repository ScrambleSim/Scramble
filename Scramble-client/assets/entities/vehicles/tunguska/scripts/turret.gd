extends MeshInstance

func _process(delta):
    var target_pos = get_node("/root/tunguska/debug_intercept").translation

    self.look_at(target_pos, Vector3.UP)
    self.rotation = Vector3(0, self.rotation.y, self.rotation.z)

