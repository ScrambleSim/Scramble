extends RigidBody

const IMPULSE = 0.001


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = self.translation
	var dir = self.to_global(Vector3(0, 1, 0)) - self.translation
	

	self.apply_impulse(Vector3(1, 0, 0), dir * IMPULSE)
	plz.DrawRay(self.to_global(Vector3(1, 0, 0)), Vector3(0, 1, 0), Color(1, 0, 0))

