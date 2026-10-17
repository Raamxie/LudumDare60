extends Node

@export var MAXIMUM_ROTATION: float = 60
@export var STARTING_POSITION: float = 0.0
@export var GOAL_ROTATION: float = 45
@export var ROTATION_SPEED: float = 2.0
@export var SMOOTHING_SPEED: float = 10.0
@export var ROTATION_AXIS: Vector3 = Vector3(1, 0, 0)

var is_interacting: bool = false
var shaft_position: float = 0.0
var target_shaft_position: float = 0.0
var current_mouse_position: Vector2
var previous_mouse_position: Vector2
var initial_offset: Vector3
var initial_mesh_basis: Basis

@onready var pivot_point: Node3D = $PivotPoint

func _ready() -> void:
	shaft_position = STARTING_POSITION
	target_shaft_position = STARTING_POSITION
	
	# Save the starting offset between the Mesh and the PivotPoint
	initial_offset = $Mesh.position - pivot_point.position
	initial_mesh_basis = $Mesh.transform.basis
	_apply_pivot_rotation(shaft_position)

func _process(delta: float) -> void:
	if not is_equal_approx(shaft_position, target_shaft_position):
		shaft_position = lerpf(shaft_position, target_shaft_position, 1.0 - exp(-SMOOTHING_SPEED * delta))
		_apply_pivot_rotation(shaft_position)
		$Label3D.text = str(snapped(shaft_position, 0.1))

func _apply_pivot_rotation(angle_deg: float) -> void:
	var angle_rad: float = deg_to_rad(angle_deg)
	var axis: Vector3 = ROTATION_AXIS.normalized()
	
	$Mesh.position = pivot_point.position + initial_offset.rotated(axis, angle_rad)
	$Mesh.transform.basis = initial_mesh_basis.rotated(axis, angle_rad)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("control_interaction"):
		is_interacting = true
		pre_interact()
	elif Input.is_action_just_released("control_interaction"):
		is_interacting = false
		
	if is_interacting and event is InputEventMouseMotion:
		current_mouse_position = event.position
		var direction: float = current_mouse_position.y - previous_mouse_position.y
		
		if direction > 0:
			target_shaft_position = minf(target_shaft_position + ROTATION_SPEED, MAXIMUM_ROTATION)
		elif direction < 0:
			target_shaft_position = maxf(target_shaft_position - ROTATION_SPEED, -MAXIMUM_ROTATION)
				
		previous_mouse_position = current_mouse_position

func pre_interact() -> void:
	previous_mouse_position = get_viewport().get_mouse_position()
