extends Node

@export var MAXIMUM_ROTATION: float = 360.0
@export var STARTING_POSITION: float = 0.0
@export var GOAL_ROTATION: float = 360.0
@export var ROTATION_SPEED: float
@export var SMOOTHING_SPEED: float = 10.0
@export var MESH: MeshInstance3D
@export var PIVOT_POINT: Node3D
@export var ROTATION_AXIS: Vector3 = Vector3(0, 1, 0)
@export var SEGMENTS_COUNT: int = 100
@export var VALUE_EXPORT:Label3D
@export var INTERACTION_INPUT: StringName

@export var MIN_DEADZONE_RADIUS: float = 15.0
@export var MAX_INTERACTION_RADIUS: float = 200.0
@onready var interactable_object: Node3D = $"../../.."

signal finished_interacting

var is_selected: bool = false
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
	
	if is_zero_approx(ROTATION_SPEED):
		ROTATION_SPEED = absf(MAXIMUM_ROTATION) / float(SEGMENTS_COUNT)
	else:
		ROTATION_SPEED = absf(ROTATION_SPEED)
	
	initial_basis = MESH.basis
	_apply_pivot_rotation(dial_position)
	
	VALUE_EXPORT.text = str(roundi(dial_position))
	
	interactable_object.connect("interacting_with", _on_interactable_object_interacting_with)
	interactable_object.connect("stopped_interacting_with", _on_interactable_object_stopped_interacting_with)
	

func _process(delta: float) -> void:
	if not is_selected:
		return
		
	if not is_equal_approx(dial_position, target_dial_position):
		dial_position = lerpf(dial_position, target_dial_position, 1.0 - exp(-SMOOTHING_SPEED * delta))
		_apply_pivot_rotation(dial_position)
		VALUE_EXPORT.text = str(deg_to_value(dial_position))

func _apply_pivot_rotation(angle_deg: float) -> void:
	var angle_rad: float = deg_to_rad(-angle_deg)
	
	MESH.basis = initial_basis.rotated(ROTATION_AXIS.normalized(), angle_rad)

func _input(event: InputEvent) -> void:
	if not is_selected:
		return

	if Input.is_action_just_pressed(INTERACTION_INPUT):
		is_interacting = true
		pre_interact()
	elif Input.is_action_just_released(INTERACTION_INPUT):
		is_interacting = false
		finished_interacting.emit()
		
	if is_interacting and event is InputEventMouseMotion:
		current_mouse_position = event.position
		
		var angle_delta_deg: float = get_angle_delta_degrees()

		target_dial_position = clampf(target_dial_position + angle_delta_deg, 0.0, MAXIMUM_ROTATION)
				
		previous_mouse_position = current_mouse_position

func pre_interact() -> void:
	previous_mouse_position = get_viewport().get_mouse_position()
	
func deg_to_value(degrees: float) -> int:
	return roundi(degrees/ MAXIMUM_ROTATION * 100)

func get_angle_delta_degrees() -> float:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var pivot_point_2D: Vector2 = cam.unproject_position(PIVOT_POINT.global_position)
	
	var vector_to_previous: Vector2 = previous_mouse_position - pivot_point_2D
	var vector_to_current: Vector2 = current_mouse_position - pivot_point_2D
	
	var dist: float = vector_to_current.length()
	
	if dist < MIN_DEADZONE_RADIUS or dist > MAX_INTERACTION_RADIUS:
		return 0.0
	if vector_to_previous.length() < MIN_DEADZONE_RADIUS:
		return 0.0
	
	return rad_to_deg(vector_to_previous.angle_to(vector_to_current))
	
func check_correct_angle() -> bool:
	return GOAL_ROTATION == deg_to_value(dial_position)
	
func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self.get_parent():
		is_selected = true


func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self.get_parent():
		is_selected = false
