extends MeshInstance

const SEARCH_RADAR_ROTATION_SPEED = -6.0     # in radians per second

func _ready():
    pass # Replace with function body.


func _process(delta):
    self.rotate_y(SEARCH_RADAR_ROTATION_SPEED * delta)
