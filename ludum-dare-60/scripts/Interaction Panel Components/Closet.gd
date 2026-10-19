class_name Closet
extends Area3D


signal player_left_closet
var player_inside := false


func _ready() -> void:
	body_entered.connect(
		func(body: Node3D) -> void:
			if body.is_in_group("Player"):
				player_inside = true
				print("in closet", player_inside)
	)
		
	body_exited.connect(
		func(body: Node3D) -> void:
			if body.is_in_group("Player"):
				player_inside = false
				player_left_closet.emit()
				print("out closet", player_inside)
	)
