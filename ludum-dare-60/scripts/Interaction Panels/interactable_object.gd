extends Node3D

@export var TRANSITION_TIME: float = 0.3
@onready var model: Node3D = $Model
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

@onready var interaction_camera: Camera3D = $InteractionCamera
@onready var interaction_component: InteractionComponent = $InteractionComponent
@onready var player = get_tree().get_nodes_in_group("Player")[0]
var interaction_camera_transform
var main_camera: Camera3D

var TransitionTween: Tween


signal interacting_with(interacted_object: Node3D)
signal stopped_interacting_with(interacted_object: Node3D)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	interaction_camera_transform = interaction_camera.global_transform

	
func _unhandled_input(event: InputEvent) -> void:
	if interaction_camera.current and (Input.is_action_pressed("return_interact")):
		_on_return_interacted_object()

func _on_interacted_object(interactor: Node) -> void:
	print("on_interacted called")
	main_camera = get_viewport().get_camera_3d()
	_set_player_active(false)
	
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
	interacting_with.emit(model.get_child(0))
	
	interaction_component.set_ray_pickable(false)
	omni_light_3d.visible = true
	show_control_message()
	
	
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
	stopped_interacting_with.emit(model.get_child(0))
	
	interaction_component.set_ray_pickable(true)
	omni_light_3d.visible = false
	clear_control_message()
	

func _set_player_active(active: bool) -> void:
	player.set_process(active)
	player.set_physics_process(active)
	player.set_process_input(active)
	player.set_process_unhandled_input(active)


func show_message():
	Messenger.show_message.emit("[E] Interact")


func clear_message():
	Messenger.clear_message.emit()
	
	
func show_control_message():
	Messenger.show_control_message.emit("[ESC] Quit")


func clear_control_message():
	Messenger.clear_control_message.emit()
	
