extends Label3D

@onready var dial_right: MeshInstance3D = $"../Dial_Right"
@onready var dial_left: MeshInstance3D = $"../Dial_Left"

signal pressure_complete

var check_tween: Tween

func _on_dial_right_finished_interacting() -> void:
	completion_check()

func _on_dial_left_finished_interacting() -> void:
	completion_check()

func completion_check() -> void:
	if check_tween and check_tween.is_running():
		check_tween.kill()
	
	check_tween = create_tween()	
	self.text = ""
	check_tween.tween_interval(0.5)
	check_tween.tween_callback(func(): self.text = "Calibrating...")
	check_tween.tween_interval(3.0)
	check_tween.tween_callback(func():
		if check_dials():
			pressure_complete.emit()
			self.text = "Teleported field is ONLINE"
			print("Pressure complete")
		else:
			self.text = "ERROR: Unsatisfactory settings"
			
			check_tween = create_tween()
			check_tween.tween_interval(3.0)
			check_tween.tween_callback(func(): self.text = "")
			check_tween.tween_interval(0.5)
			check_tween.tween_callback(func(): self.text = "Teleporter field is OFFLINE")
	)

func check_dials() -> bool:
	return dial_left.check_correct_angle() and dial_right.check_correct_angle()
