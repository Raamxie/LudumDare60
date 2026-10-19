extends Node


signal completed

enum Part { BATTERY, CABLES, DIALS, LEVER, CABLES_DOOR, VALVE}

const SETTINGS_PATH := "user://settings.cfg"


func reset() -> void:
	Music.stop()
