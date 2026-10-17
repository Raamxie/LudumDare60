extends Pickable

@onready var light: SpotLight3D = $SpotLight3D


func _ready() -> void:
	#super()
	light.visible = false


func use() -> void:
	light.visible = not light.visible
