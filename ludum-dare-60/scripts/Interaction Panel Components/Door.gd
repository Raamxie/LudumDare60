extends Node

@export var MOVEMENT_SPEED: float = 0.01 # Lowered slightly since 2D pixel deltas are larger than 3D units
@export var MAX_ROTATION: float
@export var PIVOT_POINT: Node3D
@export var DIRECTION: Vector2 = Vector2(-1, 0)
@export var STARTING_ROTATION = 0
@export var SMOOTHING_SPEED: float = 10
@export var MESH: MeshInstance3D
@export var INTERACTABLE_OBJECT: Node3D
@export var SCENE_PARENT: Node3D
@export var SCENE_MANAGER: Node3D

var is_selected: bool = false
var is_interacting: bool = false
var current_mouse_position: Vector2 = Vector2.ZERO
var previous_mouse_position: Vector2 = Vector2.ZERO
var target_door_rotation: float = 0.0
var current_door_rotation: float = 0.0
var initial_offset: Vector3
var initial_mesh_basis: Basis

func _ready() -> void:
	current_door_rotation = STARTING_ROTATION
	target_door_rotation = STARTING_ROTATION
	
	initial_offset = MESH.position - PIVOT_POINT.position
	initial_mesh_basis = MESH.transform.basis
	_apply_pivot_rotation(current_door_rotation)
	
	INTERACTABLE_OBJECT.connect("interacting_with", _on_interactable_object_interacting_with)
	INTERACTABLE_OBJECT.connect("stopped_interacting_with", _on_interactable_object_stopped_interacting_with)

func _input(event: InputEvent) -> void:
	if not is_selected:
		return
		
	if event.is_action_pressed("control_interaction"):
		if SCENE_MANAGER != null:
			if not SCENE_MANAGER.door_unlocked():
				return
		is_interacting = true
		previous_mouse_position = get_viewport().get_mouse_position()
		
	elif event.is_action_released("control_interaction"):
		is_interacting = false
		return
	
	if is_interacting and event is InputEventMouseMotion:
		current_mouse_position = get_viewport().get_mouse_position()
		
		var change: float = (current_mouse_position - previous_mouse_position).dot(DIRECTION.normalized())
		print("Change: ", change)
		
		target_door_rotation = clampf(target_door_rotation + (change * MOVEMENT_SPEED), 0.0, MAX_ROTATION)
		
		previous_mouse_position = current_mouse_position

func _process(delta: float) -> void:
	if not is_selected:
		return
	if not is_equal_approx(current_door_rotation, target_door_rotation):
		current_door_rotation = lerpf(current_door_rotation, target_door_rotation, 1.0 - exp(-SMOOTHING_SPEED * delta))
		_apply_pivot_rotation(current_door_rotation)
	
func _apply_pivot_rotation(angle_deg: float) -> void:
	var angle_rad: float = deg_to_rad(angle_deg)
	var axis := Vector3(DIRECTION.y, DIRECTION.x, 0).normalized()
	
	MESH.transform.basis = initial_mesh_basis.rotated(axis, angle_rad)
	MESH.position = PIVOT_POINT.position + initial_offset.rotated(axis, angle_rad)
	
func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == SCENE_PARENT:
		is_selected = true

func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == SCENE_PARENT:
		is_selected = false
		is_interacting = false
