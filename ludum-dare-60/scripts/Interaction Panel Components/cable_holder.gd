extends StaticBody3D


@export var SIDE: String
@export var ROW: int
@export var CABLE_MANAGER: Node3D


func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if Input.is_action_just_pressed("control_interaction1"):
		CABLE_MANAGER.pressed(SIDE, ROW, self, "control_interaction")
		print(SIDE, ROW, "control_interaction")
	elif Input.is_action_just_pressed("control_interaction2"):
		CABLE_MANAGER.pressed(SIDE, ROW, self, "control_interaction2")
		print(SIDE, ROW, "control_interaction2")
		
