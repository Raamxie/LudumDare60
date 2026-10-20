class_name Screens
extends CanvasLayer


signal play_pressed
signal resume_pressed
signal restart_pressed
signal menu_pressed
signal pause_toggled

@onready var fade_rect: ColorRect = $Control/Fade

@onready var lose_panel: Control = $Control/Lose
@onready var restart_button: Button = $Control/Lose/VBoxContainer/Restart
@onready var menu_button: Button = $Control/Lose/VBoxContainer/Menu

@onready var pause_panel: Control = $Control/Pause
@onready var resume_button: Button = $Control/Pause/VBoxContainer/Resume
@onready var settings_button: Button = $Control/Pause/VBoxContainer/Settings
@onready var menu_button_pause: Button = $Control/Pause/VBoxContainer/Menu

@onready var main_menu_panel: Control = $Control/MainMenu
@onready var quit_button: Button = $Control/MainMenu/VBoxContainer/Quit
@onready var play_button: Button = $Control/MainMenu/VBoxContainer/Play
@onready var settings_button_menu: Button = $Control/MainMenu/VBoxContainer/Settings

@onready var settings_menu: MarginContainer = $Control/MarginContainer

@onready var intro: Cutscene = $Intro
@onready var outro: Cutscene = $Outro


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(restart_pressed.emit)
	menu_button.pressed.connect(menu_pressed.emit)
	hide_all()
	
	play_button.pressed.connect(play_pressed.emit)
	resume_button.pressed.connect(resume_pressed.emit)
	menu_button_pause.pressed.connect(menu_pressed.emit)
	
	settings_button.pressed.connect(show_settings)
	settings_button_menu.pressed.connect(show_settings)

	if OS.has_feature("web"):
		#quit_button.hide()
		JavaScriptBridge.eval("window.close()")
	else:
		quit_button.pressed.connect(get_tree().quit)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_toggled.emit()
		get_viewport().set_input_as_handled()
		

func fade(new_color: Color, time: float) -> void:
	if time <= 0.0:
		fade_rect.color = new_color
		return
		
	var tween := create_tween()
	tween.tween_property(fade_rect, "color", new_color, time)
	await tween.finished


func hide_all() -> void:
	lose_panel.hide()
	pause_panel.hide()
	main_menu_panel.hide()
	settings_menu.hide()
	intro.hide()
	outro.hide()
	
	
func show_lose() -> void:
	hide_all()
	fade_rect.color = Color.BLACK
	lose_panel.show()


func show_pause() -> void:
	pause_panel.show()


func show_main_menu() -> void:
	hide_all()
	fade_rect.color = Color.BLACK
	main_menu_panel.show()


func show_settings() -> void:
	settings_menu.visible = not settings_menu.visible


func play_intro() -> void:
	hide_all()
	await intro.play()


func play_outro() -> void:
	hide_all()
	await outro.play()
	
