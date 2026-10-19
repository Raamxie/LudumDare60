extends Node3D


@export var INTERACTABLE_OBJECT: Node3D
@export var SCENE_PARENT: Node3D
@export var NEXT: MeshInstance3D
@export var PREVIOUS: MeshInstance3D
@export var PLAY: MeshInstance3D
@export var TAPE_COUNT: int

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var subtitles: RichTextLabel = player.get_node("%RichTextLabel")
@onready var player_label: Label3D = $Label3D

var is_selected: bool = false
var collected_tapes: Dictionary
var latest_id: int = 0
var current_tape: int

signal play_tape_id(id: int)

func _ready() -> void:
	
	for index in range(TAPE_COUNT):
		collected_tapes[index] = false
	

func _input(event: InputEvent) -> void:
	if not is_selected:
		return
		
func button_pressed(button_type: String) -> void:
	if not is_selected:
		return
	print("button: ", button_type)
	match button_type:
		"play":
			play_tape_id.emit(current_tape)
			subtitles.play_tape()
		"previous":
			current_tape = max(current_tape - 1, 0)
			if latest_id != 0:
				player_label.text = str(current_tape)
		"next":
			current_tape = min(current_tape + 1, latest_id)
			if latest_id != 0:
				player_label.text = str(current_tape)

func insert_tapes() -> void:
	var sorted_items = player.key_items.duplicate()
	sorted_items.sort_custom(func(a, b): return a.data.id < b.data.id)
	
	for item in sorted_items:
		if item.data.display_name == "Cassette":
			if item.data.id == latest_id + 1:
				latest_id += 1
	
func _on_interactable_object_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == SCENE_PARENT:
		is_selected = true

func _on_interactable_object_stopped_interacting_with(interacted_object: Node3D) -> void:
	if interacted_object == SCENE_PARENT:
		is_selected = false
