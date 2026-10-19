class_name InteractionComponent
extends StaticBody3D


signal interacted(interactor: Node)
signal focused
signal unfocused

var is_focusable: bool = true

@export var meshes: Array[MeshInstance3D]
const OBJECT_HIGHLIGHT = preload("uid://c57ilwxn5ebss")


func interact(interactor: Node = null) -> void:
	interacted.emit(interactor)
	
	
func focus() -> void:
	if not is_focusable:
		return
		
	focused.emit()
	for mesh in meshes:
		mesh.material_overlay = OBJECT_HIGHLIGHT
		
	if get_parent().has_method("show_message"):
		get_parent().show_message()
	
	
func unfocus() -> void:
	unfocused.emit()
	for mesh in meshes:
		mesh.material_overlay = null
		
	if get_parent().has_method("clear_message"):
			get_parent().clear_message()
			
