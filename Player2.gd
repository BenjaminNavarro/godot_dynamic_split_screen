extends KinematicBody

export var WALK_SPEED := 20

# warning-ignore:unused_argument
func _physics_process(delta):
	var velocity := Vector3()
	if Input.is_key_pressed(KEY_I):
		velocity.z -= WALK_SPEED 
	if Input.is_key_pressed(KEY_K):
		velocity.z += WALK_SPEED
	if Input.is_key_pressed(KEY_J):
		velocity.x -= WALK_SPEED
	if Input.is_key_pressed(KEY_L):
		velocity.x += WALK_SPEED
		
	move_and_slide(velocity)