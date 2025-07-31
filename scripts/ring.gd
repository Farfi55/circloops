class_name Ring
extends RigidBody3D

@onready var hit_sfx: AudioStreamPlayer3D = $HitSFX
var hit_sounds: Array[AudioStream] = [
	preload("res://assets/sfx/impactMetal_medium_000.ogg"),
	preload("res://assets/sfx/impactMetal_medium_001.ogg"),
	preload("res://assets/sfx/impactMetal_medium_002.ogg"),
	preload("res://assets/sfx/impactMetal_medium_003.ogg"),
	preload("res://assets/sfx/impactMetal_medium_004.ogg"),
]

var scored_sounds: Array[AudioStream] = [
	preload("res://assets/sfx/impactMetal_heavy_000.ogg"),
	preload("res://assets/sfx/impactMetal_heavy_001.ogg"),
	preload("res://assets/sfx/impactMetal_heavy_002.ogg"),
	preload("res://assets/sfx/impactMetal_heavy_003.ogg"),
	preload("res://assets/sfx/impactMetal_heavy_004.ogg"),
]
var last_hit_time := 0.0
var hit_cooldown := 0.2  # Minimum time in seconds between sounds

func begin_drag():
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


func end_drag(throw_velocity: Vector3, spin_velocity: Vector3 = Vector3.ZERO):
	freeze = false
	linear_velocity = throw_velocity
	angular_velocity = spin_velocity
	$destructionTimer.start()


func _on_destruction_timer_timeout() -> void:
	queue_free()


func play_random_hit_sound():
	var sfx = hit_sounds.pick_random()
	hit_sfx.stream = sfx
	hit_sfx.play()

func play_random_scored_sound():
	var sfx = scored_sounds.pick_random()
	hit_sfx.stream = sfx
	hit_sfx.play()

func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA

func _on_body_entered(body: Node) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_hit_time < hit_cooldown:
		return  # Too soon, skip sound
		
	last_hit_time = current_time
	var forces
	if body == RigidBody3D:
		forces = self.linear_velocity.length() + body.linear_velocity.length()
	else:
		forces = self.linear_velocity.length()
	# Remap the forces variable to the appropriate volume range (this is a handy function I found online)
	var audio_volume = remap_range(forces, 0.5, 6, -30, 15)
	# Set the AudioStreamPlayer's volume accordingly
	hit_sfx.volume_db = clamp(audio_volume, -50, 5)
	play_random_hit_sound()
