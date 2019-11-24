extends Camera

var rotate = false

var yaw
var pitch
var zoom_speed = 0

const rotation_speed = 0.01
const translation_speed = 0.1

func _ready():
	self.yaw = self.get_node("../../")
	self.pitch = self.get_node("./../../Pitch")

func _process(delta):
	if Input.is_key_pressed(KEY_W):
		var dir = Vector3(0, 0, (-1) * self.zoom_speed * delta)
		self.translate_object_local(dir)
	if Input.is_key_pressed(KEY_S):
		var dir = Vector3(0, 0, self.zoom_speed * delta)
		self.translate_object_local(dir)
		
	if Input.is_key_pressed(KEY_A):
		var dir = Vector3((-1) * self.zoom_speed * delta, 0, 0)
		self.translate_object_local(dir)
	if Input.is_key_pressed(KEY_D):
		var dir = Vector3(self.zoom_speed * delta, 0, 0)
		self.translate_object_local(dir)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			self.rotate = event.pressed
	
	if self.rotate:
		if event is InputEventMouseMotion:
			var y_axis = Vector3(0, 1, 0)
			self.yaw.rotate(y_axis, event.relative.x * rotation_speed)
			
			var x_axis = Vector3(1, 0, 0)
			self.pitch.rotate_object_local(x_axis, event.relative.y * rotation_speed)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			self.zoom_speed += translation_speed
		elif event.button_index == BUTTON_WHEEL_DOWN:
			self.zoom_speed -= translation_speed
