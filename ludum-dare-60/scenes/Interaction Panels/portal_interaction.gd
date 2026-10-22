extends StaticBody3D


@onready var teleporter: Node3D = $"../.."


func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("control_interaction"):
		teleporter.on_interacted()
