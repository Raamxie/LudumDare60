class_name Pickable
extends RigidBody3D


@export var data: ItemData

@onready var interaction: InteractionComponent = $InteractionComponent


func _on_interacted(interactor: Node) -> void:
	interactor.pick_up(self)


func on_picked_up() -> void:
	interaction.unfocus()
	interaction.is_focusable = false
	freeze = true
	collision_layer = 0
	collision_mask = 0


func on_dropped(impulse: Vector3) -> void:	
	interaction.is_focusable = true
	collision_layer = 1
	collision_mask = 1
	freeze = false
	apply_central_impulse(impulse)


func show_message():
	Messenger.show_message.emit(data.display_name + "\n[E] Pickup")


func clear_message():
	Messenger.clear_message.emit()
