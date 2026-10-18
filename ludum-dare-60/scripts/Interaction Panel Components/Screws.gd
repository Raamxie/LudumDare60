extends Node

@export var GROUP_NODE: Node3D
@export var REQUIRED_OBJECT: Node3D

var is_selected: bool = false


var screws: Dictionary[Node3D, bool]

func _ready() -> void:
	for screw in GROUP_NODE.get_children():
		screws.set(screw, false)

func _input(event: InputEvent) -> void:
		if not is_selected:
			return
	
func screws_left() -> int:
	var remaining = 0
	for ready in screws.values():
		if not ready:
			remaining += 1
	return remaining

func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self.get_parent():
		is_selected = true
