extends Control

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")

@onready var title: Label = $Label
@onready var character: Sprite2D = $Sprite2D
@onready var score_label: Label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var retry_btn: Button = $Retry
@onready var settings_btn: Button = $Settings
@onready var main_menu_btn: Button = $MainMenu

func _ready() -> void:
	Global.start_menu_music()
	for node in [title, score_label, high_score_label]:
		node.add_theme_font_override("font", WARIOWARE_FONT)
		node.add_theme_constant_override("outline_size", 8 if node == title else 4)
	for node in [retry_btn, main_menu_btn, settings_btn]:
		node.add_theme_font_override("font", WARIOWARE_FONT)
		node.add_theme_constant_override("outline_size", 2)

	Global.score = Global.round
	if Global.score > Global.high_score:
		Global.high_score = Global.score
		Global.save_data()

	score_label.text = "Score: %d" % Global.score
	high_score_label.text = "Best: %d" % Global.high_score

	elements_enter()
	animate_title()
	animate_character()

func elements_enter() -> void:
	for el in [title, score_label, high_score_label, retry_btn, settings_btn, main_menu_btn]:
		el.position += Vector2(0, 80)
		el.modulate.a = 0.0
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.2)
	for el in [title, score_label, high_score_label, retry_btn, settings_btn, main_menu_btn]:
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

func _on_retry_pressed() -> void:
	Global.play_click_sound()
	Global.reset()
	Transition.change_scene("res://level.tscn")

func _on_main_menu_pressed() -> void:
	Global.play_click_sound()
	Transition.change_scene("res://texture_rect.tscn")

func _on_settings_pressed() -> void:
	Global.play_click_sound()
	Transition.change_scene("res://settings.tscn")
