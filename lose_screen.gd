extends Control

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")

func _ready() -> void:
	$Label.add_theme_font_override("font", WARIOWARE_FONT)
	$Label.add_theme_constant_override("outline_size", 8)
	$Retry.add_theme_font_override("font", WARIOWARE_FONT)
	$Retry.add_theme_constant_override("outline_size", 2)
	$MainMenu.add_theme_font_override("font", WARIOWARE_FONT)
	$MainMenu.add_theme_constant_override("outline_size", 2)

func _on_retry_pressed() -> void:
	Global.reset()
	Transition.change_scene("res://level.tscn")

func _on_main_menu_pressed() -> void:
	Transition.change_scene("res://texture_rect.tscn")
