extends Node3D


@onready var screens: Screens = %Screens
@onready var player: Player
@onready var radio_song: AudioStreamPlayer = $RadioSong

const LEVEL = preload("uid://b38bd1edlw1af")

var _next_level
var monster: Monster
var chill_track := Music.Track.Normal
var level: Node
var _ended := false
var _busy := false


func _ready() -> void:
	Messenger.escaped.connect(_on_escaped)
	
	screens.play_pressed.connect(_on_play)
	screens.restart_pressed.connect(start_game)
	screens.resume_pressed.connect(_resume)
	screens.menu_pressed.connect(to_menu)
	screens.pause_toggled.connect(_on_pause_toggled)
	
	#await screens.logo.play()
	to_menu()
	

func _unload_level() -> void:
	if not is_instance_valid(level):
		level = null
		return
		
	var l := level
	level = null
	monster = null
	l.queue_free()
	await l.tree_exited
		

func _on_play() -> void:
	screens.play_intro()
	#await get_tree().process_frame
	#await get_tree().process_frame
	#_preload_level()
	await screens.intro.finished
	start_game()
	
	
#func _on_play() -> void:
	#screens.hide_all()
	#await get_tree().process_frame
	#await get_tree().process_frame
	#_preload_level()
	#await _prewarm(_next_level)
	#await screens.play_intro()
	#start_game()
#
#
#func _prewarm(l: Node) -> void:
	#var emitting_before := {}
	#for p: GPUParticles3D in l.find_children("*", "GPUParticles3D", true, false):
		#emitting_before[p] = p.emitting
		#p.emitting = true
	#var turned_on: Array[Light3D] = []
	#for light: Light3D in l.find_children("*", "Light3D", true, false):
		#if not light.visible:
			#light.visible = true
			#turned_on.append(light)
	#for i in 3:
		#await get_tree().process_frame
	#for p: GPUParticles3D in emitting_before:
		#p.emitting = emitting_before[p]
	#for light in turned_on:
		#light.visible = false
		
	
func _preload_level() -> void:
	if _next_level:
		return
		
	_next_level = LEVEL.instantiate()
	_next_level.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_next_level)
	
	
func start_game() -> void:
	if _busy:
		return
	_busy = true
	
	radio_song.stop()
	
	get_tree().paused = false
	screens.hide_all()
	screens.fade(Color.BLACK, 0.0)
	await _unload_level()
	
	Game.reset()
	Music.set_music(Music.Track.Normal)

	if _next_level:
		level = _next_level
		_next_level = null
		level.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		level = LEVEL.instantiate()
		add_child(level)

	player = level.get_node("Player")
	monster = level.get_node("%Monster")
	monster.caught_player.connect(_on_caught)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	_ended = false
	_busy = false	
	
	await screens.fade(Color(0, 0, 0, 0), 0.8)


func to_menu() -> void:
	_ended = true
	get_tree().paused = false
	screens.fade(Color.BLACK, 0.0)
	await _unload_level()
	
	Game.reset()
	if not radio_song.playing:
		radio_song.play()
		
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	screens.show_main_menu()
	
	
func _on_pause_toggled() -> void:
	if _ended:
		return
		
	if get_tree().paused:
		_resume()
		screens.hide_all()
	else:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		screens.show_pause()


func _resume() -> void:
	screens.hide_all()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _on_caught() -> void:
	if _ended:
		return
	_ended = true
	
	Game.play_at(Game.GAMEOVER, monster.global_position)
	
	#await get_tree().create_timer(2).timeout
	await screens.fade(Color.BLACK, 0.5)
	
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	screens.show_lose()


func _on_escaped() -> void:
	if _ended:
		return
		
	_ended = true
	Game.play_at(Game.ESCAPE_PORTAL, player.global_position)
	await screens.fade(Color.WHITE, 2.0)
	
	get_tree().paused = true	
	await screens.play_outro()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	to_menu()
