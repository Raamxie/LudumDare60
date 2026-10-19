extends VBoxContainer


static var _loaded := false
const PATH := Game.SETTINGS_PATH

@onready var main_volume: HSlider = $MainVolume


func _ready() -> void:
	if not _loaded:
		_loaded = true
		var cfg := ConfigFile.new()
		if cfg.load(PATH) == OK:
			_apply(cfg.get_value("audio", "master", 1.0))
	visibility_changed.connect(_sync)
	main_volume.value_changed.connect(_on_changed)
	_sync()


func _sync() -> void:   # keeps both instances in agreement
	main_volume.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(0)))


func _on_changed(v: float) -> void:
	main_volume.value = v
	_apply(v)
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", v)
	cfg.save(PATH)


func _apply(v: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(v))
	AudioServer.set_bus_mute(0, v <= 0.001)
