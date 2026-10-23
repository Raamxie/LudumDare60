extends Node3D


signal completed

@export var required_parts: Array
@export var music_player: AudioStreamPlayer3D
@export var ambient_vfx: GPUParticles3D
@export var completion_vfx: GPUParticles3D
@export var glow_light: OmniLight3D
@export var complete_sfx: AudioStreamPlayer3D
@onready var interactable_object: Node3D = $"../.."
@onready var interaction_with: Node3D = $"."


@export_group("Effect intensity")
@export_range(0.0, 1.0) var intensity_start := 0.1
@export var light_energy_max := 6.0

@onready var portal_vfx: MeshInstance3D = $PortalVfx

var is_complete := false
var is_selected := false
var _repaired: Dictionary[Game.Part, bool] = {}
var _intensity := 0.0


func _ready() -> void:
	required_parts = Game.Part.keys()
	Messenger.teleporter_part_finished.connect(repair_part)
	
	if completion_vfx:
		completion_vfx.emitting = false
		
	if music_player:
		music_player.finished.connect(music_player.play)
		music_player.play()
		
	_set_intensity(intensity_start)
	interactable_object.connect("interacting_with", _on_interactable_object_interacting_with)
	interactable_object.connect("stopped_interacting_with", _on_interactable_object_stopped_interacting_with)
		
		
func repair_part(id: Game.Part) -> bool:
	if is_complete or not required_parts.has(Game.Part.find_key(id)) or is_part_repaired(id):
		return false
	
	print("Repaired")
	_repaired[id] = true
	print(_repaired)
	print(required_parts)
	print(_repaired.size()," ", required_parts.size())
	
	if complete_sfx:
		complete_sfx.play()
		
	if _repaired.size() >= required_parts.size():
		_complete()
		print("Teleporter finished!!!")
	
	return true


func is_part_repaired(id: Game.Part) -> bool:
	return _repaired.has(id)


func get_progress() -> float:
	return float(_repaired.size()) / maxf(required_parts.size(), 1)


func _set_intensity(v: float) -> void:
	_intensity = v
	if ambient_vfx:
		ambient_vfx.amount_ratio = clampf(v, 0.05, 1.0)
		ambient_vfx.speed_scale = lerpf(0.5, 1.5, v)
	if glow_light:
		glow_light.light_energy = v * light_energy_max


func _complete() -> void:
	is_complete = true
	portal_vfx.visible = true
	
	if completion_vfx:
		completion_vfx.restart()
		completion_vfx.emitting = true

	completed.emit()


func on_interacted() -> void:
	if not is_complete:
		return
		
	Messenger.escaped.emit()


func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("control_interaction"):
		print("clicked on portal")
		if not is_selected:
			return
		print("clicked on portal")
		if completed:
			print("WIN")
		
func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == interaction_with:
		is_selected = true


func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == interaction_with:
		is_selected = false
