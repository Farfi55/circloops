class_name Ring
extends RigidBody3D

func begin_drag():
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func end_drag(throw_velocity: Vector3, spin_velocity: Vector3 = Vector3.ZERO):
	freeze = false
	linear_velocity = throw_velocity
	angular_velocity = spin_velocity
