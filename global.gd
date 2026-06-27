extends Node

var lives := 5
var round := 0
var score := 0
var high_score := 0
var settings := {
	master_volume = 1.0,
	fullscreen = true
}
const MAX_LIVES := 5
const SAVE_PATH := "user://save.cfg"

func _ready() -> void:
	load_data()
	apply_settings()

func reset() -> void:
	lives = MAX_LIVES
	round = 0

func get_speed_mult() -> float:
	return 1.0 + round * 0.15

func apply_settings() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings.master_volume))
	if settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("score", "high_score", high_score)
	config.set_value("settings", "master_volume", settings.master_volume)
	config.set_value("settings", "fullscreen", settings.fullscreen)
	config.save(SAVE_PATH)

func load_data() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	if config.has_section_key("score", "high_score"):
		high_score = config.get_value("score", "high_score", 0)
	if config.has_section_key("settings", "master_volume"):
		settings.master_volume = config.get_value("settings", "master_volume", 1.0)
	if config.has_section_key("settings", "fullscreen"):
		settings.fullscreen = config.get_value("settings", "fullscreen", true)
