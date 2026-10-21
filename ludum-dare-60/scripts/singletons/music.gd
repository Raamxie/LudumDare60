extends AudioStreamPlayer


enum Track { Normal, Tense, SuperTense }

const NORMAL = preload("uid://ckrvvb3g0cg1n")
const TENSE = preload("uid://vshw7ape07tl")
const SUPERTENSE = preload("uid://ih1g0c36k5nh")

var tracks: Array[AudioStream]


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	bus = &"Music"
	
	tracks = [NORMAL, TENSE, SUPERTENSE]


func set_music(track: Track) -> void:
	stop()
	stream = tracks[track]
	play()
