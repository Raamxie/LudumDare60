extends Node3D

@export var CABLES: Node3D
@export var CABLE_HOLDERS: Node3D

var is_selected: bool = false
var current_connection: Dictionary = {"L": [], "R": []}
var active_connections: Array
var cable_connections: Dictionary

func _ready() -> void:
	var cable_children = CABLES.get_children()
	cable_connections = {
		1: cable_children[0],
		2: cable_children[1],
		3: cable_children[2],
		4: cable_connections[3],
		-1: cable_children[4],
		-2: cable_children[5],
		-3: cable_children[6],
		-4: cable_connections[7],
		0: cable_connections[8]
	}
	

func pressed(side: String, row: int, holder: Node3D, interaction: String) -> void:
	if not is_selected:
		return
		
	if interaction == "control_interaction":
		if side == "L":
			current_connection["L"] = [holder, row]
		elif side == "R":
			current_connection["R"] = [holder, row]
			
		if current_connection["L"] != null and current_connection["R"] != null:
			var diff = current_connection["L"][1] - current_connection["R"][1]
			_create_connection(current_connection["L"][0], current_connection["R"][0], diff)
			
			
			
	elif interaction == "control_interaction2":
		if side == "L":
			current_connection["L"] = []
		elif side == "R":
			current_connection["R"] = []
		for connection in active_connections:
			if connection[0] == holder or connection[1] == holder:
				connection[3].queue_free()
				active_connections.erase(connection)
				return


func _check_possible_connection() -> bool:
	var left: Node3D = current_connection["L"][0]
	var right: Node3D = current_connection["R"][1]
	if left == null or right == null:
		return false
		
	for connection in active_connections:
		if connection[0] == left or connection[1] == left:
			return false
		elif connection[0] == right or connection[1] == right:
			return false
	return true #CHECK IF EVERYTHING

func _create_connection(left:Node3D, Right:Node3D, diff: int):
	var cable: Node3D = cable_connections[diff].duplicate()
	cable.position = current_connection["L"][0].position
	cable.visible = true
	
	active_connections.append([current_connection["L"][0],current_connection["L"][1], cable])
	
	
func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self.get_parent().get_parent():
		is_selected = true


func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == self.get_parent().get_parent():
		is_selected = false
