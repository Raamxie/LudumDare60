extends Node


#Battery planned, not implemented
enum Part {CABLES, DIALS, LEVER, CABLES_DOOR, VALVE}

const SETTINGS_PATH := "user://settings.cfg"

const DOOR_PANEL_CLOSE = preload("uid://j5nlem8n7p3y")
const DOOR_PANEL_OPEN = preload("uid://bkfl4bg8i2gn6")
const FX_COMPLETE_TELEPORTER = preload("uid://dd18u7ddiepbt")
const GAMEOVER = preload("uid://c1qv4arqycxy7")
const MONSTER_BREATH = preload("uid://8012igmnhxml")
const UNSCREW = preload("uid://dibfkbscukejh")
const WHEEL = preload("uid://bvsv6sqmbtqpe")
const ESCAPE_PORTAL = preload("uid://c87eebnyvtst3")
	
	
func reset() -> void:
	Music.stop()
	Music.volume_db = 0
	

func play_at(stream: AudioStream, pos: Vector3) -> void:
	var p := AudioStreamPlayer3D.new()
	p.stream = stream
	p.bus = &"SFX"
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(p)
	p.global_position = pos
	p.play()
	p.finished.connect(p.queue_free)
