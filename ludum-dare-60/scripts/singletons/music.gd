#extends AudioStreamPlayer
#
#
#enum Track { Normal, Tense, SuperTense }
#
#const NORMAL = preload("uid://ckrvvb3g0cg1n")
#const TENSE = preload("uid://vshw7ape07tl")
#const SUPERTENSE = preload("uid://ih1g0c36k5nh")
#
#var tracks: Array[AudioStream]
#
#
#func _ready() -> void:
	#process_mode = PROCESS_MODE_ALWAYS
	#bus = &"Music"
	#
	#tracks = [NORMAL, TENSE, SUPERTENSE]
#
#
#func set_music(track: Track) -> void:
	#stop()
	#stream = tracks[track]
	#play()

extends AudioStreamPlayer

enum Track { Normal, Tense, SuperTense }  # each value loads res://music/<value in lowercase>.ogg

const BPM := 70.0
const WAIT_BEATS := 2
const FADE_BEATS := 5.0

var _music := AudioStreamInteractive.new()


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_music.clip_count = Track.size()
	
	for t in Track.size():
		var clip: AudioStreamOggVorbis = load("res://assets/audio/%s.ogg" % Track.keys()[t].to_lower())
		clip.bpm = BPM
		clip.loop = true
		
		if WAIT_BEATS > 1:
			clip.bar_beats = WAIT_BEATS
			
		_music.set_clip_stream(t, clip)
	
	var from := AudioStreamInteractive.TRANSITION_FROM_TIME_NEXT_BEAT if WAIT_BEATS <= 1 else AudioStreamInteractive.TRANSITION_FROM_TIME_NEXT_BAR
	
	_music.add_transition(
		AudioStreamInteractive.CLIP_ANY,
		AudioStreamInteractive.CLIP_ANY,
		from,
		AudioStreamInteractive.TRANSITION_TO_TIME_START,
		AudioStreamInteractive.FADE_OUT,
		FADE_BEATS
	)
	
	bus = &"Music"
	stream = _music


func set_music(track: Track) -> void:
	if not playing:
		_music.initial_clip = track
		play()
	else:
		(get_stream_playback() as AudioStreamPlaybackInteractive).switch_to_clip(track)
