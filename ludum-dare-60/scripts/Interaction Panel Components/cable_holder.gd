extends StaticBody3D


@export var SIDE: String
@export var ROW: int
@export var CABLE_MANAGER: Node3D
@onready var pressure_panel: Node3D = $"../../.."


func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not pressure_panel.door_unlocked():
		return
	if Input.is_action_just_pressed("control_interaction"):
		CABLE_MANAGER.pressed(SIDE, ROW, self, "control_interaction")
	elif Input.is_action_just_pressed("control_interaction2"):
		CABLE_MANAGER.pressed(SIDE, ROW, self, "control_interaction2")
		
