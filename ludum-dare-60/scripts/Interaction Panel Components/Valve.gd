extends Node

@export var MAXIMUM_ROTATION: float = 360.0
@export var STARTING_POSITION: float = 0.0
@export var GOAL_ROTATION: float = 360.0
@export var ROTATION_LEEWAY: float = 22.5
@export var ROTATION_SPEED: float = 2.5    
@export var SMOOTHING_SPEED: float = 10.0
@export var MESH: MeshInstance3D
@export var PIVOT_POINT: Node3D
@onready var interactable_object: Node3D = $"../.."
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $"../../AudioStreamPlayer3D"
@onready var main: Node3D = $"../../../../../.."

var is_selected: bool = false
var is_interacting: bool = false
var in_correct: bool = false
var valve_position: float = 0.0
var target_valve_position: float = 0.0
var current_mouse_position: Vector2
var previous_mouse_position: Vector2
var initial_offset: Vector3
var initial_mesh_basis: Basis
var valve_sound = preload("res://assets/audio/fx/wheel.ogg")
var success_timer: Timer
var screwdriver: Pickable


func _ready() -> void:
	valve_position = STARTING_POSITION
	target_valve_position = STARTING_POSITION
	
	success_timer = Timer.new()
	success_timer.wait_time = 2
	success_timer.one_shot = true
	add_child(success_timer)
	success_timer.timeout.connect(_on_success_timer_timeout)
	
	# Save the starting offset between the Mesh and the PivotPoint
	initial_offset = MESH.position - PIVOT_POINT.position
	initial_mesh_basis = MESH.transform.basis
	_apply_pivot_rotation(valve_position)
	
	screwdriver = main.get_node("Level/%Screwdriver")
	
	interactable_object.connect("interacting_with", _on_interactable_object_interacting_with)
	interactable_object.connect("stopped_interacting_with", _on_interactable_object_stopped_interacting_with)

func _process(delta: float) -> void:
	if abs(valve_position - target_valve_position) <= 10:
		audio_stream_player_3d.stop()
	if not is_selected:
		return
	if not is_equal_approx(valve_position, target_valve_position):
		if not audio_stream_player_3d.playing:
			audio_stream_player_3d.stream = valve_sound
			audio_stream_player_3d.play()
		valve_position = lerpf(valve_position, target_valve_position, 1.0 - exp(-SMOOTHING_SPEED * delta))
		_apply_pivot_rotation(valve_position)
		if _check_correct() and not in_correct:
			print("In the zone")
			in_correct = true
			success_timer.start()
		elif not _check_correct() and in_correct:
			print("Out of zone")
			in_correct = false
			success_timer.stop()

func _apply_pivot_rotation(angle_deg: float) -> void:
	var angle_rad: float = deg_to_rad(angle_deg)
	var axis := Vector3(0, 0, -1)
	
	MESH.position = PIVOT_POINT.position + initial_offset.rotated(axis, angle_rad)
	MESH.transform.basis = initial_mesh_basis.rotated(axis, angle_rad)
	
	

func _input(event: InputEvent) -> void:
	if not is_selected:
		return
		
	if Input.is_action_just_pressed("control_interaction"):
		is_interacting = true
		pre_interact()
	elif Input.is_action_just_released("control_interaction"):
		is_interacting = false
		return
		
	if is_interacting and event is InputEventMouseMotion:
		current_mouse_position = event.position
		var cross: float = get_cross_product()
		
		if cross > 0:
			target_valve_position = minf(target_valve_position + ROTATION_SPEED, MAXIMUM_ROTATION)
		elif cross < 0:
			target_valve_position = maxf(target_valve_position - ROTATION_SPEED, -MAXIMUM_ROTATION)
		
		
		previous_mouse_position = current_mouse_position

func pre_interact() -> void:
	previous_mouse_position = get_viewport().get_mouse_position()
	
func _check_correct() -> bool:
	return abs(valve_position - GOAL_ROTATION) < ROTATION_LEEWAY

func get_cross_product() -> float:
	var cam: Camera3D = get_viewport().get_camera_3d()
	var pivot_point_2D: Vector2 = cam.unproject_position(PIVOT_POINT.global_position)
	
	var vector_to_previous_position: Vector2 = previous_mouse_position - pivot_point_2D
	var vector_to_current_position: Vector2 = current_mouse_position - pivot_point_2D
	
	return vector_to_previous_position.cross(vector_to_current_position)
	
func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self:
		is_selected = true


func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self:
		is_selected = false
		
func _on_success_timer_timeout() -> void:
	Messenger.teleporter_part_finished.emit(Game.Part.VALVE)
	print("Valve done")
	
	if screwdriver:
		screwdriver.apply_impulse(Vector3(0,0, -3), screwdriver.position)
		screwdriver = null
