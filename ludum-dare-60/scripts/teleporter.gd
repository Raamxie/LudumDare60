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

var is_complete := false
var _repaired: Dictionary[Game.Part, bool] = {}
var _intensity := 0.0
var _fx_tween: Tween


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

	else:
		_tween_intensity(lerpf(intensity_start, 0.8, get_progress()), 1.5)
	
	return true


func is_part_repaired(id: Game.Part) -> bool:
	return _repaired.has(id)


func get_progress() -> float:
	return float(_repaired.size()) / maxf(required_parts.size(), 1)


func _tween_intensity(target: float, time: float) -> void:
	if _fx_tween:
		_fx_tween.kill()
		
	_fx_tween = create_tween()
	_fx_tween.tween_method(_set_intensity, _intensity, target, time).set_trans(Tween.TRANS_SINE)


func _set_intensity(v: float) -> void:
	_intensity = v
	if ambient_vfx:
		ambient_vfx.amount_ratio = clampf(v, 0.05, 1.0)
		ambient_vfx.speed_scale = lerpf(0.5, 1.5, v)
	if glow_light:
		glow_light.light_energy = v * light_energy_max


func _complete() -> void:
	is_complete = true
	
	_tween_intensity(1.0, 2.0)
	
	if completion_vfx:
		completion_vfx.restart()
		completion_vfx.emitting = true

	completed.emit()


func _on_interacted(interactor: Node) -> void:
	if not is_complete:
		return
		
	Messenger.escaped.emit()
