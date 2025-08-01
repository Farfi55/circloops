extends Node3D

const MAX_ANGLE_DIFF := 70.0 # degrees
const MAX_DISTANCE := 0.2    # meters
const MAX_HEIGHT_DIFF := 0.5 # meters

var tracked_ring: Ring = null
var successful_throw := false

@export var rotation_speed := 90.0
@export var movement_curve_x: Curve;
var _progress_curve_x := 0.0;
@export var movement_curve_z: Curve;
var _progress_curve_z := 0.0;

func _ready() -> void:
	GlobalSignals.new_ring.connect(_on_new_ring)
	print(name + " 	loaded")

func _on_new_ring(ring: Ring):
	tracked_ring = ring

func _physics_process(_delta: float) -> void:
	$parts/stick.global_rotate(Vector3.UP, deg_to_rad(rotation_speed * _delta))

	if movement_curve_x:
		_progress_curve_x += _delta
		if _progress_curve_x >= movement_curve_x.max_domain:
			_progress_curve_x = _progress_curve_x - movement_curve_x.max_domain
		$parts.position.x = movement_curve_x.sample(_progress_curve_x)
	if movement_curve_z:
		_progress_curve_z += _delta
		if _progress_curve_z >= movement_curve_z.max_domain:
			_progress_curve_z = _progress_curve_z - movement_curve_z.max_domain
		$parts.position.z = movement_curve_z.sample(_progress_curve_z)


	if tracked_ring == null or successful_throw:
		return


	var base_position: Vector3 = $parts.global_position
	# Compute ring alignment
	var ring_up: Vector3 = tracked_ring.global_transform.basis.y.normalized()
	var angle_deg: float = rad_to_deg(min(ring_up.angle_to(Vector3.UP), ring_up.angle_to(Vector3.DOWN)))

	# Compute horizontal (XZ) distance from ring to stick base
	var ring_pos := tracked_ring.global_transform.origin
	var dist_xz := Vector2(ring_pos.x, ring_pos.z).distance_to(Vector2(base_position.x, base_position.z))

	var diff_y = abs(ring_pos.y - base_position.y)

	# Check if it meets criteria
	if angle_deg <= MAX_ANGLE_DIFF and dist_xz <= MAX_DISTANCE and diff_y <= MAX_HEIGHT_DIFF:
		successful_throw = true
		print("🎯 Ring landed successfully on the stick!")
		tracked_ring.play_random_scored_sound()
		GlobalSignals.successful_throw.emit(tracked_ring)

func _exit_tree() -> void:
	GlobalSignals.new_ring.disconnect(_on_new_ring)
