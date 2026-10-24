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
@export var hide_warning_lead := 5.0

@onready var teleporter: Teleporter = $"../Map/Objects/Portal/Model/Teleporter"


var state := State.IDLE
var _exposed := 0.0
var _timer := Timer.new()
var _player_left_closet := false


func _ready() -> void:
	set_process(false)

	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer)
	_timer.start(idle_interval)
	Music.set_music(chill_track)

	Messenger.teleporter_part_finished.connect(_on_teleporter_part_finished)
	teleporter.completed.connect(disable)
	closet.player_left_closet.connect(func(): _player_left_closet = true if state == State.IN_ROOM else false)


func _process(delta: float) -> void:
	if closet.player_inside:
		_exposed = 0.0
		return
		
	_exposed += delta
	
	if _exposed >= exposed_coyote_time or _player_left_closet:
		_catch()
		

func _on_teleporter_part_finished(_part: Game.Part) -> void:
	await get_tree().create_timer(5, false).timeout

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


func _emit_hide_warning() -> void:
	if state == State.ANTICIPATION:
		Messenger.monster_hide.emit()
		

func _start_anticipation() -> void:
	state = State.ANTICIPATION
	Music.set_music(tense_track)
	anticipation_started.emit()
	Messenger.monster_lurking.emit()
	
	get_tree().create_timer(maxf(tense_time - hide_warning_lead, 0.0), false).timeout.connect(_emit_hide_warning)
	_timer.start(tense_time)


func _enter_room() -> void:
	state = State.IN_ROOM
	Music.set_music(supertense_track)
	entered_room.emit()

	set_process(true)

	_exposed = 0.0
	get_tree().create_timer(exposed_coyote_time - 1, false).timeout.connect(_play_presence)
	
	_timer.start(randf_range(super_tense_time.x, super_tense_time.y))


func _play_presence() -> void:
	if state == State.IN_ROOM and presence_sfx:
		presence_sfx.play()


func _leave() -> void:
	state = State.IDLE
	left_room.emit()
	set_process(false)
	_player_left_closet = false
	
	if presence_sfx:
		presence_sfx.stop()
	
	await get_tree().create_timer(1, false).timeout
	Music.set_music(chill_track)
	_timer.start(idle_interval)
		

func _catch() -> void:
	set_process(false)
	_timer.stop()
	state = State.DISABLED

	var tween := create_tween()
	
	tween.tween_property(Music, "volume_db", -80.0, 0.3)
	await  tween.finished
	
	if presence_sfx:
		presence_sfx.stop()
	
	#if catch_sfx:
		#catch_sfx.play()
		
	caught_player.emit()


func disable() -> void:
	_timer.stop()
	set_process(false)
	state = State.DISABLED

	if presence_sfx:
		presence_sfx.stop()


func _track_length(t: Music.Track) -> float:
	return 55
