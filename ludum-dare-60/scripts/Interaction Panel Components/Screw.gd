extends StaticBody3D

@onready var scene_manager: Node3D = $"../../../.."
@onready var player: Player = get_tree().get_nodes_in_group("Player")[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not event.is_action_pressed("control_interaction"):
		return
	if not player.has_screwdriver:
		return
	scene_manager.unscrewed(self.get_parent().get_parent())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
 
