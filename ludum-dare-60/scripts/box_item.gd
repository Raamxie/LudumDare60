extends RigidBody3D


func _on_interacted(interactor: Node):
	translate(Vector3(0, 0, 1))
