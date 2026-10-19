extends Node

@export var scene_manager: Node3D

var direction: Vector3 = Vector3(0, 1, 0)
var is_interacting = false
var current_mouse_position
var previous_mouse_position



func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var unlocked = true
	
	if scene_manager != null:
		unlocked = scene_manager.door_unlocked()
		if not unlocked:
			return
	
	if event.is_action_pressed("control_interaction"):
		is_interacting = true
		
	elif Input.is_action_just_released("control_interaction"):
		is_interacting = false
	
	if is_interacting and event is InputEventMouseMotion:
		current_mouse_position = event_position
		
	
func pre_interact() -> void:
	previous_mouse_position = get_viewport().get_mouse_position()
