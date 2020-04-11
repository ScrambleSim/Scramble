extends RigidBody

const IMPULSE = 0.006


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.apply_impulse(Vector3(0, 0.1, 0), Vector3(0, IMPULSE, 0))
	
	plz.DrawRay(self.to_global(Vector3(0.1, 0.1, 0.1)), Vector3(0, 5, 0), Color(1, 0, 0)) 
