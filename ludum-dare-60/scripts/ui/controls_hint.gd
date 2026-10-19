extends Label



func _ready() -> void:
	Messenger.show_control_message.connect(on_show_message)
	Messenger.clear_control_message.connect(on_clear_message)


func on_show_message(message: String):
	text = message
	
	
func on_clear_message():
	text = ""
	
