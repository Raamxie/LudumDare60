class_name Player
extends CharacterBody3D


@export_category("Movement")
@export var WALK_SPEED = 5.0
@export var SPRINT_SPEED = 10.0
@export var JUMP_VELOCITY = 5.0
@export var AIR_CONTROL = 3.0
@export var FRICTION = 7.0

@export_category("Camera Control")
@export var SENSITIVITY = 0.005
@export var CAMERA_X_ANGLE_MIN = -60
@export var CAMERA_X_ANGLE_MAX = 60
@export var HEAD_BOB_FREQUENCY = 2.0
@export var HEAD_BOB_AMPLITUDE = 0.08
@export var FOV_BASE = 75
@export var FOV_MULTIPLIER = 1.5


@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interact_ray: RayCast3D = %InteractRay


@onready var hand_right: Marker3D = $Head/Camera3D/HandRight
@onready var hand_left: Marker3D = $Head/Camera3D/HandLeft

var held: Pickable
var tool: Pickable
var key_items: Array[StringName]

var head_bob_time: float = 0.0
var speed: float = 0.0
var direction: Vector3

var focused_object: InteractionComponent


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(CAMERA_X_ANGLE_MIN),
			deg_to_rad(CAMERA_X_ANGLE_MAX)
			)
	
	if Input.is_action_just_pressed("drop"):
		drop_held()
		
	if tool and Input.is_action_just_pressed("use_tool"):
		tool.use()
		
		
func _physics_process(delta: float) -> void:
	_handle_interaction()
			
	var input_direction := Input.get_vector("left", "right", "forward", "backward")
	direction = (head.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()	

	if not input_direction:
		speed = 0
		velocity.x = lerp(velocity.x, direction.x * speed, delta * FRICTION)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * FRICTION)
	elif Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		speed = WALK_SPEED
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		velocity += get_gravity() * delta
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIR_CONTROL)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIR_CONTROL)
	
	if velocity.y < 0 or not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIR_CONTROL)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIR_CONTROL)
		
	_calculate_headbob(delta)
	_calculate_fov(delta)
	move_and_slide()


func _calculate_headbob(delta: float) -> void:
	if is_on_floor():
		head_bob_time += delta * velocity.length()
		
	var head_position = Vector3.ZERO
	head_position.y = HEAD_BOB_AMPLITUDE * sin(head_bob_time * HEAD_BOB_FREQUENCY)
	head_position.x = HEAD_BOB_AMPLITUDE * cos(head_bob_time * HEAD_BOB_FREQUENCY / 2)

	camera.transform.origin = head_position
	

func _calculate_fov(delta: float) -> void:
	var clamped_velocity = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = FOV_BASE + FOV_MULTIPLIER * clamped_velocity
	camera.fov = lerp(camera.fov, target_fov, delta * 8)


func _handle_interaction() -> void:
	if not interact_ray.is_colliding():
		if focused_object:
			focused_object.unfocus()
			focused_object = null
		return
	
	var new_object: InteractionComponent = interact_ray.get_collider()
	
	if focused_object and focused_object != new_object:
		focused_object.unfocus()
	
	focused_object = new_object
	focused_object.focus()
	#if focused_object == null:
		#return	
	if Input.is_action_just_pressed("interact"):
		focused_object.interact(self)
		

func pick_up(item: Pickable) -> void:
	match item.data.slot:
		ItemData.Slot.KEY:
			key_items.append(item.data.id)
			item.queue_free()
		ItemData.Slot.TOOL:
			if tool: _drop(tool, 1.0)
			tool = item
			_attach(item, hand_left)
		ItemData.Slot.HAND:
			if held: _drop(held, 1.0)
			held = item
			_attach(item, hand_right)


func _attach(item: Pickable, hand: Marker3D) -> void:
	item.on_picked_up()
	item.reparent(hand, false)
	item.transform = item.data.hold_transform


func _drop(item: Pickable, strength: float) -> void:
	item.reparent(get_tree().current_scene)
	item.on_dropped(-camera.global_basis.z * strength)


func drop_held() -> void:
	if held:
		_drop(held, 3.0)
		held = null


func consume_held() -> void:
	if held:
		held.queue_free()
		held = null
