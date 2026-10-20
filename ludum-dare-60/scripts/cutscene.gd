class_name Cutscene
extends Control


signal finished
signal _next

@export_multiline var pages: Array[String]
@export var allow_skip := true
@export var fade_time := 0.8
@onready var story_text: Label = $StoryText
@onready var hint: Label = $MarginContainer/Hint

var _skipped := false
var _playing := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func play() -> void:
	_skipped = false
	_playing = true
	show()
	
	if hint:
		hint.text = "[LMB] Continue" + ("\n[Q] Skip" if allow_skip else "")
	
	for page in pages:
		story_text.text = page
		story_text.modulate.a = 0.0
		
		var tween := create_tween()
		tween.tween_property(story_text, "modulate:a", 1.0, fade_time)
		await _next
		
		tween.kill()
		
		if _skipped:
			break
			
		tween = create_tween()
		tween.tween_property(story_text, "modulate:a", 0.0, 0.4)
		await tween.finished
		
	_playing = false
	hide()
	finished.emit()


func _input(event: InputEvent) -> void:
	if not _playing or not (event is InputEventMouseButton and event.pressed):
		return
		
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			_next.emit()
	
	get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void:
		if Input.is_action_pressed("return_interact"):
			if allow_skip:
				_skipped = true
				_next.emit()
