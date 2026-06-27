extends Control

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")

@onready var title: Label = $Title
@onready var character: Sprite2D = $Sprite2D
@onready var volume_label: Label = $VolumeLabel
@onready var volume_slider: HSlider = $VolumeSlider
@onready var fullscreen_label: Label = $FullscreenLabel
@onready var fullscreen_check: CheckButton = $FullscreenCheck
@onready var back_btn: Button = $Back

func _ready() -> void:
	Global.start_menu_music()
	for node in [title, volume_label, fullscreen_label]:
		node.add_theme_font_override("font", WARIOWARE_FONT)
		node.add_theme_constant_override("outline_size", 6)

	for node in [back_btn, fullscreen_check]:
		node.add_theme_font_override("font", WARIOWARE_FONT)
		node.add_theme_constant_override("outline_size", 2)

	volume_slider.value = Global.settings.master_volume * 100.0
	fullscreen_check.button_pressed = Global.settings.fullscreen

	elements_enter()
	title.z_index = 1
	animate_title()
	animate_character()

func elements_enter() -> void:
	for el in [title, volume_label, volume_slider, fullscreen_label, fullscreen_check, back_btn]:
		el.position += Vector2(0, 80)
		el.modulate.a = 0.0
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.2)
	for el in [title, volume_label, volume_slider, fullscreen_label, fullscreen_check, back_btn]:
		tween.tween_property(el, "position:y", el.position.y - 80, 0.4)
		tween.tween_property(el, "modulate:a", 1.0, 0.25)
		tween.tween_interval(0.1)

func animate_title() -> void:
	var base_y = title.position.y
	var tween = create_tween().set_loops()
	tween.tween_property(title, "position:y", base_y - 8, 1.2)
	tween.tween_interval(1.2)
	tween.tween_property(title, "position:y", base_y, 1.2)
	tween.tween_interval(1.2)

func animate_character() -> void:
	var char_tween = create_tween().set_loops()
	char_tween.tween_property(character, "rotation", deg_to_rad(3), 1.5)
	char_tween.tween_interval(1.5)
	char_tween.tween_property(character, "rotation", deg_to_rad(-3), 1.5)
	char_tween.tween_interval(1.5)

func _on_volume_slider_value_changed(value: float) -> void:
	Global.settings.master_volume = value / 100.0
	Global.apply_settings()
	Global.save_data()

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	Global.play_click_sound()
	Global.settings.fullscreen = toggled_on
	Global.apply_settings()
	Global.save_data()

func _on_back_pressed() -> void:
	Global.play_click_sound()
	Transition.change_scene("res://texture_rect.tscn")
