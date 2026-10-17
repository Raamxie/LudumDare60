extends Control


@export var dot_radius: float = 2.0
@export var dot_color: Color = Color.WHITE


func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var center = get_viewport_rect().size / 2.0
	draw_circle(center, dot_radius, dot_color)
