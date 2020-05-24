extends MeshInstance

const SEARCH_RADAR_ROTATION_SPEED = -7.0     # in radians per second

func _process(delta):
    self.rotate_y(SEARCH_RADAR_ROTATION_SPEED * delta)
