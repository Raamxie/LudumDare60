extends Node3D

@export var TRANSITION_TIME: float = 0.3

@onready var interaction_camera: Camera3D = $InteractionCamera
@onready var interaction_component: InteractionComponent = $InteractionComponent
@onready var player = get_tree().get_nodes_in_group("Player")[0]
var interaction_camera_transform
var main_camera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	interaction_camera_transform = interaction_camera.global_transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




	
func _unhandled_input(event: InputEvent) -> void:
	if interaction_camera.current and (Input.is_action_pressed("return_interact")):
		_on_return_interacted_object()

func _on_interacted_object(interactor: Node) -> void:
	print("on_interacted called")    
	main_camera = get_viewport().get_camera_3d()
	_set_player_active(false) # Keeps physics space intact
	
	interaction_camera.global_transform = main_camera.global_transform
	interaction_camera.force_update_transform()
	interaction_camera.reset_physics_interpolation()
	if TransitionTween:
		TransitionTween.kill()
	TransitionTween = create_tween()
	TransitionTween.tween_property(interaction_camera, "global_transform", interaction_camera_transform, TRANSITION_TIME).set_trans(Tween.TRANS_SINE)
	interaction_camera.make_current()
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	interaction_component.unfocus()
	interaction_component.is_focusable = false

func _on_return_interacted_object() -> void:
	if TransitionTween:
		TransitionTween.kill()
	TransitionTween = create_tween()
	TransitionTween.tween_property(interaction_camera, "global_transform", main_camera.global_transform, TRANSITION_TIME).set_trans(Tween.TRANS_SINE)
	await TransitionTween.finished
	
	main_camera.make_current()
	interaction_camera.global_transform = interaction_camera_transform
	
	# Re-enable player AFTER the camera finishes returning
	_set_player_active(true)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interaction_component.focus()
	interaction_component.is_focusable = true
	print("Returned")
	
	
var TransitionTween: Tween



func _set_player_active(active: bool) -> void:
	player.set_process(active)
	player.set_physics_process(active)
	player.set_process_input(active)
	player.set_process_unhandled_input(active)
