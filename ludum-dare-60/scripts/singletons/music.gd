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
	
	stream = _music
	playback_type = AudioServer.PLAYBACK_TYPE_STREAM


func set_music(track: Track) -> void:
	if not playing:
		_music.initial_clip = track
		play()
	else:
		(get_stream_playback() as AudioStreamPlaybackInteractive).switch_to_clip(track)


# Test keys 1/2/3 to play song normal, tense and supertense respectively
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.physical_keycode in [KEY_1, KEY_2, KEY_3]:
		set_music((e.physical_keycode - KEY_1) as Track)
