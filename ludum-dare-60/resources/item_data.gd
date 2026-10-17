class_name ItemData
extends Resource

enum Slot { HAND, TOOL, KEY }

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var slot: Slot = Slot.HAND
@export var hold_transform := Transform3D.IDENTITY
