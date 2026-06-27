extends Control

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")

func _ready() -> void:
	$Label.add_theme_font_override("font", WARIOWARE_FONT)
	$Label.add_theme_constant_override("outline_size", 8)
	$ScoreLabel.add_theme_font_override("font", WARIOWARE_FONT)
	$ScoreLabel.add_theme_constant_override("outline_size", 4)
	$HighScoreLabel.add_theme_font_override("font", WARIOWARE_FONT)
	$HighScoreLabel.add_theme_constant_override("outline_size", 4)
	$Retry.add_theme_font_override("font", WARIOWARE_FONT)
	$Retry.add_theme_constant_override("outline_size", 2)
	$MainMenu.add_theme_font_override("font", WARIOWARE_FONT)
	$MainMenu.add_theme_constant_override("outline_size", 2)
	$Settings.add_theme_font_override("font", WARIOWARE_FONT)
	$Settings.add_theme_constant_override("outline_size", 2)

	Global.score = Global.round
	if Global.score > Global.high_score:
		Global.high_score = Global.score
		Global.save_data()

	$ScoreLabel.text = "Score: %d" % Global.score
	$HighScoreLabel.text = "Best: %d" % Global.high_score

func _on_retry_pressed() -> void:
	Global.reset()
	Transition.change_scene("res://level.tscn")

func _on_main_menu_pressed() -> void:
	Transition.change_scene("res://texture_rect.tscn")

func _on_settings_pressed() -> void:
	Transition.change_scene("res://settings.tscn")
