extends Control

@onready var title: Sprite2D = $"246908"
@onready var character: Sprite2D = $Sprite2D
@onready var start_btn: Button = $Button
@onready var settings_btn: Button = $Button3
@onready var quit_btn: Button = $Button2

func _ready() -> void:
	Global.start_menu_music()
	buttons_enter()
	animate_title()
	animate_character()
	await get_tree().process_frame
	Transition.fade_in()

func buttons_enter() -> void:
	for btn in [start_btn, settings_btn, quit_btn]:
		btn.position += Vector2(0, 100)
		btn.modulate.a = 0.0
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.3)
	tween.tween_property(start_btn, "position:y", start_btn.position.y - 100, 0.5)
	tween.tween_property(start_btn, "modulate:a", 1.0, 0.3)
	tween.tween_interval(0.15)
	tween.tween_property(settings_btn, "position:y", settings_btn.position.y - 100, 0.5)
	tween.tween_property(settings_btn, "modulate:a", 1.0, 0.3)
	tween.tween_interval(0.15)
	tween.tween_property(quit_btn, "position:y", quit_btn.position.y - 100, 0.5)
	tween.tween_property(quit_btn, "modulate:a", 1.0, 0.3)

func animate_title() -> void:
	var base_y = title.position.y
	var base_scale = title.scale
	var tween = create_tween().set_loops()
	tween.tween_property(title, "position:y", base_y - 12, 1.0)
	tween.parallel().tween_property(title, "scale", base_scale * 1.03, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(title, "position:y", base_y, 1.0)
	tween.parallel().tween_property(title, "scale", base_scale, 1.0)
	tween.tween_interval(1.0)

func animate_character() -> void:
	var char_tween = create_tween().set_loops()
	char_tween.tween_property(character, "rotation", deg_to_rad(3), 1.5)
	char_tween.tween_interval(1.5)
	char_tween.tween_property(character, "rotation", deg_to_rad(-3), 1.5)
	char_tween.tween_interval(1.5)

func _on_button_pressed() -> void:
	Global.play_click_sound()
	Global.stop_menu_music()
	Global.reset()
	Transition.change_scene("res://level.tscn")

func _on_button_3_pressed() -> void:
	Global.play_click_sound()
	Transition.change_scene("res://settings.tscn")

func _on_button_2_pressed() -> void:
	Global.play_click_sound()
	get_tree().quit()
