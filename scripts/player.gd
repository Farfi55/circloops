class_name Player
extends Node3D

@export var ring_scene: PackedScene
@export var spawn_point_path: NodePath
@export var ring_container_path: NodePath
@export var drag_plane_mesh_path: NodePath
@export var ring_respawn_delay: float = 2.0

@onready var camera: Camera3D = $Camera3D
@onready var debug_plane_mesh: MeshInstance3D = get_node(drag_plane_mesh_path)
@onready var spawn_point: Node3D = get_node(spawn_point_path)
@onready var ring_container: Node3D = get_node(ring_container_path)

var current_ring: Ring
var dragging: bool = false
var drag_plane: Plane
var recent_positions: Array[Dictionary] = []
const MAX_HISTORY: int = 7
var can_spawn_next_ring: bool = true


func _ready():
	# Setup drag plane from debug mesh once
	var normal: Vector3 = debug_plane_mesh.global_transform.basis.y.normalized()
	var origin: Vector3 = debug_plane_mesh.global_transform.origin
	drag_plane = Plane(normal, origin)

	print("Plane normal (camera forward): ", normal)
	print("Plane origin (from mesh): ", origin)


	_spawn_new_ring()

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			_release_drag()

func _physics_process(_delta: float) -> void:
	if dragging and current_ring:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 100.0

		var intersection = drag_plane.intersects_ray(from, to)
		if intersection:
			current_ring.global_position = intersection

			# Track movement history
			recent_positions.append({
				"pos": intersection,
				"time": Time.get_ticks_msec() / 1000.0
			})
			if recent_positions.size() > MAX_HISTORY:
				recent_positions.pop_front()

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
	current_ring.end_drag(avg_velocity)
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

func _spawn_new_ring():
	if not can_spawn_next_ring or not ring_scene:
		return

	var new_ring = ring_scene.instantiate() as Ring
	ring_container.add_child(new_ring)
	current_ring = new_ring
	GlobalSignals.new_ring.emit(new_ring)
	
	_start_drag()
