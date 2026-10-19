extends Node3D

@export var GROUP_NODE: Node3D
@onready var interactable_object: Node3D = $"../.."

var is_selected: bool = false

var tween_fling_length: float = 1.25
var tween_initial_length: float = 0.5
var tween_initial_distance: float = 0.002
var tween_fling_distance: float = 1.5


var screw_statuses: Dictionary[Node3D, bool]

func _ready() -> void:
	for screw in GROUP_NODE.get_children():
		screw_statuses.set(screw, false)
		print(screw)
	interactable_object.connect("interacting_with", _on_interactable_object_interacting_with)
	interactable_object.connect("stopped_interacting_with", _on_interactable_object_stopped_interacting_with)
		
func unscrewed(screw: Node3D) -> void:
	
	screw.get_child(0).get_child(0).set_ray_pickable(false)
	var move_direction: Vector3 = screw.transform.basis.z.normalized()
	var step_offset: Vector3 = move_direction * tween_initial_distance
	
	var unscrewing_position_tween = create_tween()
	unscrewing_position_tween.set_loops(4)
	
	unscrewing_position_tween.tween_property(screw, "position", step_offset, tween_initial_length).as_relative()
	
	unscrewing_position_tween.parallel().tween_property(screw, "rotation_degrees", Vector3(0, 0, 180), tween_initial_length).as_relative()
	unscrewing_position_tween.tween_interval(tween_initial_length)
	
	await unscrewing_position_tween.finished
	
	var fling_tween = create_tween()
	var fling_offset: Vector3 = move_direction * tween_fling_distance
	
	fling_tween.tween_property(screw, "position", fling_offset, tween_fling_length).as_relative()
	fling_tween.parallel().tween_property(screw, "scale", Vector3(0.001, 0.001, 0.001), tween_fling_length).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await fling_tween.finished
	
	screw.queue_free()
	screw_statuses[screw] = true
	
func screws_left() -> int:
	var remaining = 0
	for ready in screw_statuses.values():
		if not ready:
			remaining += 1
	return remaining

func door_unlocked() -> bool:
	return screws_left() == 0

func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self.get_parent():
		is_selected = true


func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self.get_parent():
		is_selected = false
