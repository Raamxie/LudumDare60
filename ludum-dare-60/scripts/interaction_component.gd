class_name InteractionComponent
extends StaticBody3D


signal interacted
signal focused
signal unfocused


@export var mesh: MeshInstance3D
const OBJECT_HIGHLIGHT = preload("uid://c57ilwxn5ebss")


func interact() -> void:
	interacted.emit()
	
	
func focus() -> void:
	focused.emit()
	mesh.material_overlay = OBJECT_HIGHLIGHT

	
func unfocus() -> void:
	unfocused.emit()
	mesh.material_overlay = null
