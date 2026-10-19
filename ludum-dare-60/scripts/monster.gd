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
@export var tense_loops := 1

@export_group("Timing")
@export var idle_interval := 180.0
@export var in_room_time := Vector2(12.0, 18.0)
@export var exposed_grace := 5.0

var state := State.IDLE
var _exposed := 0.0
var _pending := false
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
	Game.completed.connect(disable)
	closet.player_left_closet.connect(func(): _player_left_closet = true if state == State.IN_ROOM else false)


func _process(delta: float) -> void:
	if closet.player_inside:
		_exposed = 0.0
		return
		
	_exposed += delta
	
	if _exposed >= exposed_grace or _player_left_closet:
		_catch()
		

func _on_teleporter_part_finished(_part: Game.Part) -> void:
	match state:
		State.IDLE:
			_start_anticipation()
		#State.ANTICIPATION, State.IN_ROOM:
			#_pending = false
			

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
	anticipation_started.emit()
	
	_timer.start(_track_length(tense_track) * tense_loops)


func _enter_room() -> void:
	state = State.IN_ROOM
	Music.set_music(supertense_track)
	entered_room.emit()

	set_process(true)

	_exposed = 0.0
	
	if presence_sfx:
		presence_sfx.play()
		
	_timer.start(randf_range(in_room_time.x, in_room_time.y))


func _leave() -> void:
	state = State.IDLE
	left_room.emit()
	Music.set_music(chill_track)
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
