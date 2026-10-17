extends Pickable


#func _on_interacted(by: Node) -> void:
	#if by.held and by.held.data.id.begins_with("tape"):
		#insert_tape(by.held.data.id)
		#by.consume_held()
