extends Node

@export var MAX_STEP_PER_EVENT: float = 0.0005
@export var MAX_POSITION: float
@export var START_POSITION: float = 0
@export var GOAL_POSITION: float
@export var GOAL_LEEWAY: float = 0.05
@export var MOUSE_SENSITIVITY: float = 0.001
@export var DIRECTION: Vector2 = Vector2(0, -1)
@export var SMOOTHING_SPEED: float = 6
@export var MESH: MeshInstance3D
@export var INTERACTABLE_OBJECT: Node3D
@export var SCENE_PARENT: Node3D

var is_selected: bool = false
var is_interacting: bool = false
var is_finished: bool = false
var current_mouse_position: Vector2 = Vector2.ZERO
var previous_mouse_position: Vector2 = Vector2.ZERO
var target_lever_position: float = 0.0
var current_lever_position: float = 0.0
var initial_offset: Vector3

func _ready() -> void:
	current_lever_position = START_POSITION
	target_lever_position = START_POSITION
	
	initial_offset = MESH.position
	
	INTERACTABLE_OBJECT.connect("interacting_with", _on_interactable_object_interacting_with)
	INTERACTABLE_OBJECT.connect("stopped_interacting_with", _on_interactable_object_stopped_interacting_with)
	_apply_position(target_lever_position)

func _input(event: InputEvent) -> void:
	if not is_selected:
		return
		
	if event.is_action_pressed("control_interaction"):
		is_interacting = true
		previous_mouse_position = get_viewport().get_mouse_position()
		
	elif event.is_action_released("control_interaction"):
		is_interacting = false
		return
	
	if is_interacting and event is InputEventMouseMotion:
		var change: float = event.relative.dot(DIRECTION.normalized()) * MOUSE_SENSITIVITY
		change = clampf(change, -MAX_STEP_PER_EVENT, MAX_STEP_PER_EVENT)
		
		target_lever_position = clampf(target_lever_position + change, 0.0, MAX_POSITION)

func _process(delta: float) -> void:
	if not is_selected:
		return
	if not is_equal_approx(current_lever_position, target_lever_position):
		current_lever_position = lerpf(current_lever_position, target_lever_position, 1.0 - exp(-SMOOTHING_SPEED * delta))
		_apply_position(current_lever_position)
	
func _apply_position(position: float) -> void:
	MESH.position.z = initial_offset.z - position
	if _check_correct() and not is_finished and Teleporter.is_part_repaired(Game.Part.DIALS):
		print("Lever complete")
		Messenger.teleporter_part_finished.emit(Game.Part.LEVER)
		is_finished = true
	
	
func _check_correct()-> bool:
	
	return abs(current_lever_position - GOAL_POSITION) < MAX_POSITION * GOAL_LEEWAY
	
func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == SCENE_PARENT:
		is_selected = true

func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == SCENE_PARENT:
		is_selected = false
		is_interacting = false
