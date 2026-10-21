extends RichTextLabel



var subtitle_atlas: Subtitle_Atlas = preload("res://resources/Subtitle_Atlas.tres")
var tween: Tween
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Locks the final layout position of every letter before typing starts
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	

func play_tape(id: int) -> void:
	if id == 0:
		return
	print("PLAYING: ", id)
	var tape:Subtitles = subtitle_atlas.contents[id - 1]
	

	
	if tween and tween.is_running():
		tween.kill()
		tween = create_tween()
	else:
		tween = create_tween()
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
