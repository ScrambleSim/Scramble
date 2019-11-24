extends DirectionalLight

var rotate_sun = false
var rotation_speed = 0.01

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2:
			self.rotate_sun = event.pressed

	if rotate_sun:
		if event is InputEventMouseMotion:
			var y_axis = Vector3(0, 1, 0)
			self.rotate(y_axis, event.relative.x * rotation_speed)
			
			var x_axis = Vector3(1, 0, 0)
			self.rotate_object_local(x_axis, event.relative.y * rotation_speed)
