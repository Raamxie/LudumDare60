extends Node

@export var MAXIMUM_ROTATION: float = 360.0
@export var STARTING_POSITION: float = 0.0
@export var GOAL_ROTATION: float = 360.0
@export var ROTATION_SPEED: float = 1
@export var SMOOTHING_SPEED: float = 10.0
@export var MESH: MeshInstance3D
@export var PIVOT_POINT: Node3D
@export var ROTATION_AXIS: Vector3 = Vector3(0, 1, 0)
@export var SEGMENTS_COUNT: int = 100
@export var VALUE_EXPORT:Label3D

var is_interacting: bool = false
var dial_position: float = 0.0
var target_dial_position: float = 0.0
var current_mouse_position: Vector2
var previous_mouse_position: Vector2
var initial_offset: float
var initial_basis: Basis

func _ready() -> void:
	dial_position = STARTING_POSITION
	target_dial_position = STARTING_POSITION
	
	# Save the starting offset between the Mesh and the PivotPoint
	initial_basis = MESH.basis
	_apply_pivot_rotation(dial_position)

func _process(delta: float) -> void:
	if not is_equal_approx(dial_position, target_dial_position):
		dial_position = lerpf(dial_position, target_dial_position, 1.0 - exp(-SMOOTHING_SPEED * delta))
		_apply_pivot_rotation(dial_position)
		VALUE_EXPORT.text = str(int(dial_position))

func _apply_pivot_rotation(angle_deg: float) -> void:
	var angle_rad: float = deg_to_rad(angle_deg)
	
	MESH.basis = initial_basis.rotated(ROTATION_AXIS.normalized(), angle_rad)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("control_interaction"):
		is_interacting = true
		pre_interact()
	elif Input.is_action_just_released("control_interaction"):
		is_interacting = false
		
	if is_interacting and event is InputEventMouseMotion:
		current_mouse_position = event.position
		var cross: float = get_cross_product()
		
		if cross < 0:
			target_dial_position = minf(target_dial_position + ROTATION_SPEED, MAXIMUM_ROTATION)
		elif cross > 0:
			target_dial_position = maxf(target_dial_position - ROTATION_SPEED, -MAXIMUM_ROTATION)
				
		previous_mouse_position = current_mouse_position

func pre_interact() -> void:
	previous_mouse_position = get_viewport().get_mouse_position()

func get_cross_product() -> float:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var pivot_point_2D: Vector2 = cam.unproject_position(PIVOT_POINT.global_position)
	
	var vector_to_previous_position: Vector2 = previous_mouse_position - pivot_point_2D
	var vector_to_current_position: Vector2 = current_mouse_position - pivot_point_2D
	
	return vector_to_previous_position.cross(vector_to_current_position)
