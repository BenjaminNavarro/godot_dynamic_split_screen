extends KinematicBody
class_name Player1

"""
Moves the player with WASD keys
"""

export var walk_speed := 20

# warning-ignore:unused_argument
func _physics_process(delta) -> void:
	var velocity := Vector3()
	if Input.is_key_pressed(KEY_W):
		velocity.z -= walk_speed
	if Input.is_key_pressed(KEY_S):
		velocity.z += walk_speed
	if Input.is_key_pressed(KEY_A):
		velocity.x -= walk_speed
	if Input.is_key_pressed(KEY_D):
		velocity.x += walk_speed
		
	move_and_slide(velocity)