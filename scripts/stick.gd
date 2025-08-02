class_name Stick
extends Node3D

const MAX_ANGLE_DIFF := 70.0 # degrees
const MAX_DISTANCE := 0.2    # meters
const MAX_HEIGHT_DIFF := 0.5 # meters

@export var roating_part: Node3D
@export var moving_target: Node3D

@export var rotation_speed := 90.0

@export var movement_curve_x: Curve;
var _progress_curve_x := 0.0;

@export var movement_curve_y: Curve;
var _progress_curve_y := 0.0;

@export var movement_curve_z: Curve;
var _progress_curve_z := 0.0;

var completed = false
signal on_completed

@export var particles: GPUParticles3D

func _ready() -> void:
	add_to_group("sticks")

func _physics_process(_delta: float) -> void:
	if rotation_speed != 0 and roating_part:
		roating_part.global_rotate(Vector3.UP, deg_to_rad(rotation_speed * _delta))

	if movement_curve_x:
		_progress_curve_x += _delta
		if _progress_curve_x >= movement_curve_x.max_domain:
			_progress_curve_x = _progress_curve_x - movement_curve_x.max_domain
		moving_target.position.x = movement_curve_x.sample(_progress_curve_x)
		
	if movement_curve_y:
		_progress_curve_y += _delta
		if _progress_curve_y >= movement_curve_y.max_domain:
			_progress_curve_y = _progress_curve_y - movement_curve_y.max_domain
		moving_target.position.y = movement_curve_y.sample(_progress_curve_y)
		
	if movement_curve_z:
		_progress_curve_z += _delta
		if _progress_curve_z >= movement_curve_z.max_domain:
			_progress_curve_z = _progress_curve_z - movement_curve_z.max_domain
		moving_target.position.z = movement_curve_z.sample(_progress_curve_z)
		

func complete(ring: Ring):
	if completed:
		return
	completed = true
	on_completed.emit()
