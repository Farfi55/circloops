class_name Player
extends Node3D

@export var ring_scene: PackedScene
@export var ring_container_path: NodePath
@export var drag_plane_mesh_path: NodePath
@export var ring_respawn_delay: float = 2.0

@onready var camera: Camera3D = $Camera3D
@onready var debug_plane_mesh: MeshInstance3D = get_node(drag_plane_mesh_path)
@onready var ring_container: Node3D = get_node(ring_container_path)

var current_ring: Ring
var dragging: bool = false
var drag_plane: Plane
var recent_positions: Array[Dictionary] = []
const MAX_HISTORY: int = 6
var can_spawn_next_ring: bool = true

@export var throw_speed_multiplier: float = 0.5
@export var speed_cap: float = 7.0

@export_range(0.0, 1.0, 0.01)
var vertical_lift_falloff: float = 0.5

@export var wobble_sensitivity: float = 1.0


func _ready():
	# Setup drag plane from debug mesh once
	var normal: Vector3 = debug_plane_mesh.global_transform.basis.y.normalized()
	var origin: Vector3 = debug_plane_mesh.global_transform.origin
	drag_plane = Plane(normal, origin)

	print("Plane normal (camera forward): ", normal)
	print("Plane origin (from mesh): ", origin)

	GlobalSignals.level_won.connect(func(): can_spawn_next_ring = false)
	GlobalSignals.level_opened.connect(_on_new_level)
	GlobalSignals.level_closed.connect(_on_level_closed)
	

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			_release_drag()

func _physics_process(_delta: float) -> void:
	if dragging and current_ring and Engine.time_scale > 0.0:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 100.0

		var intersection = drag_plane.intersects_ray(from, to)
		if intersection:
			var viewport_size = get_viewport().get_visible_rect().size
			var screen_y = get_viewport().get_mouse_position().y
			var vertical_ratio = clamp(screen_y / viewport_size.y, 0.0, 1.0)

			# Invert it: 0 at bottom of screen, 1 at top
			var top_factor = 1.0 - vertical_ratio

			# Falloff amount: 1 = no compression, 0 = flat
			var lift_factor = lerp(1.0, vertical_lift_falloff, top_factor)

			# Apply falloff to Y
			intersection.y = debug_plane_mesh.global_transform.origin.y + (intersection.y - debug_plane_mesh.global_transform.origin.y) * lift_factor

			current_ring.global_position = intersection
			var mouse_pos_normal = mouse_pos / viewport_size
			
			# Track movement history
			recent_positions.append({
				"pos": intersection,
				"screen_pos": mouse_pos,
				"screen_pos_normal": mouse_pos_normal,
				"time": Time.get_ticks_msec() / 1000.0
			})
			if recent_positions.size() > MAX_HISTORY:
				recent_positions.pop_front()
				
			# Calculate wobble based on movement
			wobble()
			
func wobble():
	if recent_positions.size() < 2:
		return

	var a := recent_positions[recent_positions.size() - 2]
	var b := recent_positions[recent_positions.size() - 1]

	var screen_delta: Vector2 = b["screen_pos_normal"] - a["screen_pos_normal"]

	# Convert screen delta into a fake "3D plane" motion for cross product
	# This keeps the axis resolution-independent and more intuitive
	var drag_vec_3d = Vector3(screen_delta.x, 0.0, -screen_delta.y) # Y movement becomes Z motion

	var wobble_axis: Vector3 = drag_vec_3d.cross(Vector3.UP).normalized()
	var wobble_strength: float = clamp(screen_delta.length() * wobble_sensitivity, 0.0, 1.0)
	var wobble_rotation: Quaternion

	if not wobble_axis.is_zero_approx():
		wobble_rotation = Quaternion(wobble_axis, deg_to_rad(wobble_strength * 70.0))
	else:
		wobble_rotation = Quaternion.IDENTITY

	# Resting upright rotation (align with floor)
	var upright_rotation := Quaternion(Vector3.UP, 0.0) # identity

	# Blend wobble with upright
	var target_rotation := upright_rotation.slerp(wobble_rotation * upright_rotation, wobble_strength)

	# Smooth transition
	var current_rotation := current_ring.global_transform.basis.get_rotation_quaternion()
	var smoothed := current_rotation.slerp(target_rotation, 0.1)

	current_ring.global_transform.basis = Basis(smoothed)

func _start_drag() -> void:
	if current_ring == null:
		return

	dragging = true
	current_ring.begin_drag()
	recent_positions.clear()

func _release_drag() -> void:
	if not dragging or current_ring == null:
		return

	dragging = false
	var avg_velocity := _compute_average_velocity()
	var spin_axis := _compute_gesture_spin_axis()
	var spin_strength := avg_velocity.length() * 1.0
	
	var raw_speed = avg_velocity.length()
	var capped_speed = clamp(raw_speed, 0.0, speed_cap)
	var adjusted_velocity = avg_velocity.normalized() * capped_speed * throw_speed_multiplier

	current_ring.end_drag(adjusted_velocity, spin_axis * spin_strength)

	recent_positions.clear()
	await get_tree().create_timer(ring_respawn_delay).timeout
	_spawn_new_ring()

func _compute_average_velocity() -> Vector3:
	var total_velocity: Vector3 = Vector3.ZERO
	var count := 0
	

	for i in range(recent_positions.size() - 1):
		var a = recent_positions[i]
		var b = recent_positions[i + 1]
		var dt = b["time"] - a["time"]
		if dt > 0.0:
			var velocity = (b["pos"] - a["pos"]) / dt
			total_velocity += velocity
			count += 1

	return total_velocity / count if count > 0 else Vector3.ZERO

func _compute_gesture_spin_axis() -> Vector3:
	if recent_positions.size() < 3:
		return Vector3.UP # default spin axis

	var curve_sum := Vector3.ZERO

	for i in range(recent_positions.size() - 2):
		var a = recent_positions[i]["pos"]
		var b = recent_positions[i + 1]["pos"]
		var c = recent_positions[i + 2]["pos"]

		var ab = (b - a).normalized()
		var bc = (c - b).normalized()

		# Cross product gives axis of curvature
		var axis = ab.cross(bc)
		if axis.length_squared() > 0.0001:
			curve_sum += axis.normalized()

	if curve_sum.length_squared() == 0.0:
		return Vector3.UP

	return curve_sum.normalized()


func _spawn_new_ring():
	await get_tree().create_timer(0.1).timeout
	
	if not can_spawn_next_ring or not ring_scene:
		return

	var new_ring = ring_scene.instantiate() as Ring
	ring_container.add_child(new_ring)
	current_ring = new_ring
	GlobalSignals.new_ring.emit(new_ring)
	
	_start_drag()

func _on_level_closed() -> void:
	can_spawn_next_ring = false

func _on_new_level() -> void:
	can_spawn_next_ring = true
	await get_tree().create_timer(0.1).timeout
	_spawn_new_ring()

func _exit_tree() -> void:
	GlobalSignals.level_closed.disconnect(_spawn_new_ring)
