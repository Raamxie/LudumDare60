extends Pickable


@onready var label_3d: Label3D = $Label3D



#func _on_interacted(by: Node) -> void:
	#if by.key_items.get(&"screwdriver", false): unscrew()
	
func _ready() -> void:
	label_3d.text = str(data.id)
