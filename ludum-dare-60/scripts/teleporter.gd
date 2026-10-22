extends Node3D


signal completed

@export var required_parts: Array
@export var music_player: AudioStreamPlayer3D
@export var ambient_vfx: GPUParticles3D
@export var completion_vfx: GPUParticles3D
@export var glow_light: OmniLight3D
@export var complete_sfx: AudioStreamPlayer3D

@export_group("Effect intensity")
@export_range(0.0, 1.0) var intensity_start := 0.1
@export var light_energy_max := 6.0

@onready var portal_vfx: MeshInstance3D = $PortalVfx

var is_complete := false
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
		
		
func repair_part(id: Game.Part) -> bool:
	if is_complete or not required_parts.has(Game.Part.find_key(id)) or is_part_repaired(id):
		return false
	
	print("Repaired")
	_repaired[id] = true
	print(id)
	
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
