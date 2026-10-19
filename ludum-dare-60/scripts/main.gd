extends Node3D


const LEVEL := preload("res://assets/models/Room/Room_blockout.fbx")

@onready var monster: Monster = %Monster
@onready var screens: CanvasLayer = %Screens

var chill_track := Music.Track.Normal
var level: Node
var _ended := false


func _ready() -> void:
	monster.caught_player.connect(_on_caught)
	Messenger.escaped.connect(_on_escaped)
	
	#screens.play_pressed.connect(start_game)
	screens.play_pressed.connect(_on_play)
	
	screens.restart_pressed.connect(start_game)
	screens.resume_pressed.connect(_resume)
	screens.menu_pressed.connect(to_menu)
	screens.pause_toggled.connect(_on_pause_toggled)
	
	#await screens.logo.play()
	to_menu()
	
	
func _unload_level() -> void:
	if not level:
		return
		
	var l := level
	level = null
	l.queue_free()
	await l.tree_exited
		

func _on_play() -> void:
	await screens.play_intro()
	start_game()
	
	
func start_game() -> void:
	get_tree().paused = false
	screens.hide_all()
	screens.fade(Color.BLACK, 0.0)
	await _unload_level()
	
	Game.reset()
	Music.set_music(chill_track)
	level = LEVEL.instantiate()
	add_child(level)
	_ended = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	await screens.fade(Color(0, 0, 0, 0), 0.8)


func to_menu() -> void:
	_ended = true
	get_tree().paused = false
	await _unload_level()
	
	Game.reset()
	Music.set_music(chill_track)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	screens.show_main_menu()
	
	
func _on_pause_toggled() -> void:
	if level == null or _ended:
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
	if _ended: return
	_ended = true
	
	await get_tree().create_timer(2).timeout
	await screens.fade(Color.BLACK, 0.5)
	
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	screens.show_lose()


func _on_escaped() -> void:
	if _ended: return
	_ended = true
	await screens.fade(Color.WHITE, 2.0)
	get_tree().paused = true
	
	await screens.play_outro()
	to_menu()
