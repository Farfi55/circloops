class_name Ring
extends RigidBody3D

func begin_drag():
	freeze = true # Stop simulation
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func end_drag(throw_velocity: Vector3):
	freeze = false
	linear_velocity = throw_velocity
