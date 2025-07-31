extends Node3D

const MAX_ANGLE_DIFF := 70.0 # degrees
const MAX_DISTANCE := 0.2    # meters
const MAX_HEIGHT_DIFF := 0.5 # meters
@onready var base_position: Vector3 = global_transform.origin

@export var tracked_ring: Ring = null
var successful_throw := false

func _ready() -> void:
	GlobalSignals.new_ring.connect(func(ring): tracked_ring = ring)

func _physics_process(_delta: float) -> void:
	if tracked_ring == null or successful_throw:
		return
	
	# Compute ring alignment
	var ring_up: Vector3 = tracked_ring.global_transform.basis.y.normalized()
	var angle_deg: float = rad_to_deg(ring_up.angle_to(Vector3.UP))

	# Compute horizontal (XZ) distance from ring to stick base
	var ring_pos := tracked_ring.global_transform.origin
	var dist_xz := Vector2(ring_pos.x, ring_pos.z).distance_to(Vector2(base_position.x, base_position.z))
	
	var diff_y = abs(ring_pos.y - base_position.y)

	# Check if it meets criteria
	if angle_deg <= MAX_ANGLE_DIFF and dist_xz <= MAX_DISTANCE and diff_y <= MAX_HEIGHT_DIFF:
		successful_throw = true
		print("🎯 Ring landed successfully on the stick!")
		GlobalSignals.successful_throw.emit(tracked_ring)

func _exit_tree() -> void:
	GlobalSignals.new_ring.disconnect(func(ring): tracked_ring = ring)
