extends KinematicBody

export var WALK_SPEED := 20

# warning-ignore:unused_argument
func _physics_process(delta):
	var velocity := Vector3()
	if Input.is_key_pressed(KEY_W):
		velocity.z -= WALK_SPEED
	if Input.is_key_pressed(KEY_S):
		velocity.z += WALK_SPEED
	if Input.is_key_pressed(KEY_A):
		velocity.x -= WALK_SPEED
	if Input.is_key_pressed(KEY_D):
		velocity.x += WALK_SPEED
		
	move_and_slide(velocity)