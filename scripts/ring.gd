class_name Ring
extends RigidBody3D

@onready var hit_sfx: AudioStreamPlayer3D = $HitSFX

var hit_sounds: Array[AudioStream] = [
	preload("res://assets/sfx/impactMetal_heavy_000.ogg"),
	preload("res://assets/sfx/impactMetal_heavy_003.ogg"),
	preload("res://assets/sfx/impactMetal_heavy_004.ogg"),
]

var scored_sounds: Array[AudioStream] = [
	preload("res://assets/sfx/impactMetal_medium_000.ogg"),
	preload("res://assets/sfx/impactMetal_medium_001.ogg"),
	preload("res://assets/sfx/impactMetal_medium_002.ogg"),
	preload("res://assets/sfx/impactMetal_medium_003.ogg"),
	preload("res://assets/sfx/impactMetal_medium_004.ogg"),
]

var last_hit_time := 0.0
var hit_cooldown := 0.2 # Minimum time in seconds between sounds
var flown_at_time = 0.0;


var is_flying = false
var target_stick: Stick = null;

var in_stick = false;

@export var lateral_force: float = 10.0
var speed_cap = 8.0

func begin_drag():
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


func end_drag(throw_velocity: Vector3, spin_velocity: Vector3 = Vector3.ZERO):
	freeze = false
	linear_velocity = throw_velocity
	angular_velocity = spin_velocity
	flown_at_time = Time.get_ticks_msec() / 1000.0
	is_flying = true
	target_stick = _find_closest_stick()
	
	$DisableTimer.start()
	$DestructionTimer.start()
	$UpdateTargetTimer.start()
	
	GlobalVariables.rings_thrown_level += 1
	GlobalVariables.rings_thrown_total += 1
	GlobalSignals.ring_thrown.emit(self)


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
	return (value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA

func _find_closest_stick() -> Stick:
	var closest: Stick = null
	var closest_dist := INF
	for stick in get_tree().get_nodes_in_group("sticks"):
		if stick is Stick:
			if stick.completed:
				continue
			var dist := global_position.distance_to(stick.get_child(0).global_position)
			if dist < closest_dist:
				closest = stick
				closest_dist = dist
	return closest


func _physics_process(delta: float) -> void:
	if not target_stick:
		return
	
	if global_position.y > 0.4:
		var velocity = linear_velocity
		velocity.y = 0
		var clamped_velocity = clamp(velocity.length(), 0, speed_cap - 2.0) / (speed_cap - 2.0)
		var x_diff = target_stick.get_child(0).global_position.x - global_position.x
		var direction = sign(x_diff)
		print(lateral_force)
		var force_strength = clamp(abs(x_diff) * clamped_velocity * lateral_force, 0.0, 200.0) * delta
		apply_central_force(Vector3.RIGHT * direction * force_strength)

		# apply speed cap
		if linear_velocity.length() > speed_cap:
			linear_velocity = linear_velocity.normalized() * speed_cap
			
	
	if in_stick and abs(global_position.y - target_stick.global_position.y) < 0.5 and not target_stick.completed:
		play_random_scored_sound()
		print("target_stick.completed: " + str(target_stick.completed))
		print("🎯 Ring landed successfully on the stick!")
		target_stick.complete(self)
		GlobalSignals.successful_throw.emit(self)


func _on_body_entered(body: Node) -> void:
	is_flying = false
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_hit_time < hit_cooldown or current_time - flown_at_time > 6.0:
		return

	last_hit_time = current_time

	# Calculate relative velocity
	var other_velocity := Vector3.ZERO
	if body is RigidBody3D:
		other_velocity = body.linear_velocity

	var relative_velocity := linear_velocity - other_velocity
	var speed := relative_velocity.length()

	# Get collision normal (use last collision info)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + relative_velocity.normalized() * 0.5)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

	var angle_factor := 1.0
	if result:
		var hit_normal: Vector3 = result.normal.normalized()
		angle_factor = relative_velocity.normalized().dot(-hit_normal)
		angle_factor = clamp(angle_factor, 0.0, 1.0) # Only forward hits matter

	# Combine speed and angle factor
	var impact_strength = speed * angle_factor
	if impact_strength < 0.4:
		return
	# Map to decibel range
	var audio_volume = remap_range(impact_strength, 0.0, 5.0, -40.0, 5.0)
	hit_sfx.volume_db = clamp(audio_volume, -50.0, 5.0)

	play_random_hit_sound()


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("body entered " + body.name)
	if body.name == "stick":
		in_stick = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	print("body exited " + body.name)
	if body.name == "stick":
		in_stick = false


func _on_area_3d_area_entered(area: Area3D) -> void:
	print("area entered " + area.name)
	if area.name == "hanging_ring_target_area":
		var hanging_ring: Stick = area.get_parent().get_parent()
		if hanging_ring.completed:
			return
			
		hanging_ring.complete(self)
		play_random_scored_sound()
		GlobalSignals.successful_throw.emit(self)
		print("🎯 Ring successfully passed in the hanging ring!")


func _on_update_target_timer_timeout() -> void:
	target_stick = _find_closest_stick()


func _on_disable_timer_timeout() -> void:
	$UpdateTargetTimer.stop()
	disable_mode = CollisionObject3D.DISABLE_MODE_MAKE_STATIC
	$Area3D.monitoring = false
	$Area3D.monitorable = false
	in_stick = false
