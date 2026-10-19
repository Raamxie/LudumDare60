extends Node3D

@export var CABLES: Node3D
@export var CABLE_HOLDERS: Node3D
@onready var interactable_object: Node3D = $"../../.."
@onready var interaction_with: Node3D = $".."
@export var GOAL_CONNECTIONS: Array
# 1, 4
# 2, 2
# 3, 1
# 4, 5
# 5, 3

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
		4: cable_children[3],
		-1: cable_children[4],
		-2: cable_children[5],
		-3: cable_children[6],
		-4: cable_children[7],
		0: cable_children[8]
	}
	
	interactable_object.connect("interacting_with", _on_interactable_object_interacting_with)
	interactable_object.connect("stopped_interacting_with", _on_interactable_object_stopped_interacting_with)
	

func pressed(side: String, row: int, holder: Node3D, interaction: String) -> void:
	if not is_selected:
		return
		
	if interaction == "control_interaction":
		if side == "L":
			current_connection["L"] = [holder, row]
		elif side == "R":
			current_connection["R"] = [holder, row]
			
		if _check_possible_connection():
			var diff = (current_connection["L"][1] - current_connection["R"][1])
			_create_connection(current_connection["L"][0], current_connection["R"][0], diff)
			
			
			
	elif interaction == "control_interaction2":
		if side == "L":
			current_connection["L"] = []
		elif side == "R":
			current_connection["R"] = []
		for connection in active_connections:
			if connection[0] == holder or connection[1] == holder:
				connection[2].queue_free()
				active_connections.erase(connection)
				return

func _check_possible_connection() -> bool:
	if current_connection["L"].is_empty() or current_connection["R"].is_empty():
		return false
		
	var left: Node3D = current_connection["L"][0]
	var right: Node3D = current_connection["R"][0]
		
	for connection in active_connections:
		if connection[0] == left or connection[1] == left:
			return false
		elif connection[0] == right or connection[1] == right:
			return false
	return true #CHECK IF EVERYTHING

func _create_connection(left:Node3D, right:Node3D, diff: int):
	var cable: Node3D = cable_connections[diff].duplicate()
	CABLES.add_child(cable)
	cable.global_position = left.global_position
	cable.visible = true
	
	active_connections.append([left,right, cable])
	current_connection["L"] = []
	current_connection["R"] = []
	_check_correct()
	
	
	
func _check_correct() -> bool:
	if active_connections.size() != 5:
		return false
		
	for pair in GOAL_CONNECTIONS:
		var found = false
		var goal_left: Node3D = get_node(pair[0])
		var goal_right: Node3D = get_node(pair[1])
		for connection in active_connections:
			if connection[0] == goal_left and connection[1] == goal_right:
				found = true
				break
		if not found:
			print("Invalid Combination")
			return false
	print("Valid Combination")
	Messenger
	return true
			
		
		
		
func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == interaction_with:
		is_selected = true


func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == interaction_with:
		is_selected = false
