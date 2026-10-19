class_name Monster
extends Node3D


signal anticipation_started
signal entered_room
signal left_room
signal caught_player

enum State { IDLE, ANTICIPATION, IN_ROOM, DISABLED }

@export var closet: Closet
@export var presence_sfx: AudioStreamPlayer3D
@export var catch_sfx: AudioStreamPlayer3D

@export_group("Music")
@export var chill_track: Music.Track
@export var tense_track: Music.Track
@export var supertense_track: Music.Track
@export_range(0.01, 4.0, 0.01) var tense_pitch := 1.11
@export_range(0.01, 4.0, 0.01) var super_tense_pitch := 1.26


@export_group("Timing")
@export var idle_interval := 180
@export var tense_time := 55
@export var super_tense_time := Vector2(30, 55)
@export var exposed_coyote_time := 5.0

var state := State.IDLE
var _exposed := 0.0
var _timer := Timer.new()
var _player_left_closet := false
var _music_tween: Tween


func _ready() -> void:
	set_process(false)

	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer)
	_timer.start(idle_interval)
	Music.set_music(chill_track)

	Messenger.teleporter_part_finished.connect(_on_teleporter_part_finished)
	Game.completed.connect(disable)
	closet.player_left_closet.connect(func(): _player_left_closet = true if state == State.IN_ROOM else false)


func _process(delta: float) -> void:
	if closet.player_inside:
		_exposed = 0.0
		return
		
	_exposed += delta
	
	if _exposed >= exposed_coyote_time or _player_left_closet:
		_catch()
		

func _on_teleporter_part_finished(_part: Game.Part) -> void:
	match state:
		State.IDLE:
			_start_anticipation()
			

func _on_timer() -> void:
	match state:
		State.IDLE:
			_start_anticipation()
		State.ANTICIPATION:
			_enter_room()
		State.IN_ROOM:
			_leave()


func _start_anticipation() -> void:
	state = State.ANTICIPATION
	Music.set_music(tense_track)
	_update_music(Music.Track.Tense)
	anticipation_started.emit()
	
	_timer.start(tense_time)


func _enter_room() -> void:
	state = State.IN_ROOM
	Music.set_music(supertense_track)
	_update_music(Music.Track.SuperTense)
	entered_room.emit()

	set_process(true)

	_exposed = 0.0
	
	if presence_sfx:
		presence_sfx.play()
		
	_timer.start(randf_range(super_tense_time.x, super_tense_time.y))


func _leave() -> void:
	state = State.IDLE
	left_room.emit()
	Music.set_music(chill_track)
	_update_music(Music.Track.Normal)
	set_process(false)
	_player_left_closet = false
	
	if presence_sfx:
		presence_sfx.stop()

	#if _pending:
		#_pending = false
		#_start_anticipation()
		#return
	
	_timer.start(idle_interval)


func _catch() -> void:
	print("CAUGHT!!!")
	_timer.stop()
	set_process(false)
	state = State.DISABLED
	
	if presence_sfx:
		presence_sfx.stop()
	if catch_sfx:
		catch_sfx.play()
		
	caught_player.emit()


func disable() -> void:
	_timer.stop()
	set_process(false)
	state = State.DISABLED

	if presence_sfx:
		presence_sfx.stop()
		

func _track_length(t: Music.Track) -> float:
	return 55


func _update_music(track: Music.Track) -> void:
	if _music_tween:
		_music_tween.kill()
	
	_music_tween = create_tween()
	
	if track == Music.Track.Normal:
		_music_tween.tween_property(
			Music,
			"pitch_scale",
			lerpf(Music.pitch_scale, 1.0, 1),
			2
		)
		
	if track == Music.Track.Tense:
		_music_tween.tween_property(
			Music,
			"pitch_scale",
			lerpf(Music.pitch_scale, tense_pitch, 1),
			2
		)
		
	elif track == Music.Track.SuperTense:
		_music_tween.tween_property(
			Music,
			"pitch_scale",
			lerpf(Music.pitch_scale, super_tense_pitch, 1),
			2
		)
