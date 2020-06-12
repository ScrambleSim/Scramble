extends MeshInstance

export(int, FLAGS, "X", "Y", "Z") var locked_axis = 0

func _process(delta):
    var target_pos = get_node_or_null("/root/Scramble/World/Entities/fa18f")
    if not target_pos:
        return
    target_pos = target_pos.translation

    var current_rotation = self.rotation
    self.look_at(target_pos, Vector3.UP)
    var final_rotation = self.rotation

    self.rotation = current_rotation.linear_interpolate(final_rotation, delta * 2)

    if is_bit_enabled(locked_axis, 0):
        self.rotation.x = 0
    if is_bit_enabled(locked_axis, 1):
        self.rotation.y = 0
    if is_bit_enabled(locked_axis, 2):
        self.rotation.z = 0
        

    # requirements
    # disable each axis individually
    # interpolate yes no
    # define target node
    # define interpolation speed

func is_bit_enabled(mask, index):
    return mask & (1 << index) != 0
