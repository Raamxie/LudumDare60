extends RichTextLabel



var tape_subtitles: Array[Dictionary] = [
	{"text": "Short line.", "hold_time": 1.5},
	{"text": "This is a much longer line that will naturally take more time to type out.", "hold_time": 2.5}
]

var subtitle_atlas: Subtitle_Atlas = preload("res://resources/Subtitle_Atlas.tres")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Locks the final layout position of every letter before typing starts
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	

func play_tape(id: int) -> void:
	var tape:Subtitles = subtitle_atlas.contents[id - 1]
	
		
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	for line in tape.contents:
		var char_count: int = line["text"].length()
		var type_duration: float = char_count / line.typespeed
		
		tween.tween_callback(func():
			text = line["text"]
			visible_characters = 0
		)
		
		tween.tween_property(self, "visible_characters", char_count, type_duration)
		tween.tween_interval(line["hold_time"])
		
	tween.tween_callback(func(): text = "")
