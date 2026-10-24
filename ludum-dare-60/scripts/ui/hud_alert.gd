extends Control


@onready var label: Label = $Label

@export var font_size := 64
@export var lurk_color := Color(0.78, 0.607, 0.133, 1.0)
@export var hide_color := Color(0.65, 0.182, 0.182, 1.0)
@export var shake_strength := 5.0
@export var shake_rotation := 0.06

var _tween: Tween
var _intensity := 0.0
var _base_pos := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("outline_size", 16)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.modulate.a = 0.0
	set_process(false)
	
	Messenger.monster_lurking.connect(_on_lurking)
	Messenger.monster_hide.connect(_on_hide)


func _process(_delta: float) -> void:
	label.position = _base_pos + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength * _intensity
	label.rotation = randf_range(-1.0, 1.0) * shake_rotation * _intensity


func _on_lurking() -> void:
	_alert("SOMETHING IS LURKING...", lurk_color, 0.3)


func _on_hide() -> void:
	_alert("HIDE NOW!!!", hide_color, 1.0)


func _alert(text: String, color: Color, intensity: float) -> void:
	if _tween:
		_tween.kill()
	label.text = text
	label.add_theme_color_override("font_color", color)
	_base_pos = Vector2.ZERO
	label.pivot_offset = label.size / 2.0
	_intensity = intensity
	set_process(true)
	
	label.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(label, "modulate:a", 1.0, 0.25)
	_tween.parallel().tween_property(label, "scale", Vector2.ONE, 0.25).from(Vector2.ONE * 1.5)
	_tween.tween_interval(2)
	_tween.tween_property(label, "modulate:a", 0.0, 0.5)
	_tween.tween_callback(_stop)


func _stop() -> void:
	set_process(false)
	label.position = _base_pos
	label.rotation = 0.0
