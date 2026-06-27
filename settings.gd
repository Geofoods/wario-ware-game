extends Control

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")

func _ready() -> void:
	for node in [$Title, $VolumeLabel, $FullscreenLabel]:
		node.add_theme_font_override("font", WARIOWARE_FONT)
		node.add_theme_constant_override("outline_size", 6)

	for node in [$Back, $FullscreenCheck]:
		node.add_theme_font_override("font", WARIOWARE_FONT)
		node.add_theme_constant_override("outline_size", 2)

	$VolumeSlider.value = Global.settings.master_volume * 100.0
	$FullscreenCheck.button_pressed = Global.settings.fullscreen

func _on_volume_slider_value_changed(value: float) -> void:
	Global.settings.master_volume = value / 100.0
	Global.apply_settings()
	Global.save_data()

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	Global.settings.fullscreen = toggled_on
	Global.apply_settings()
	Global.save_data()

func _on_back_pressed() -> void:
	Transition.change_scene("res://texture_rect.tscn")
