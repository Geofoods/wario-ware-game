extends Control

func _on_play_again_pressed() -> void:
	Transition.change_scene("res://level.tscn")

func _on_main_menu_pressed() -> void:
	Transition.change_scene("res://texture_rect.tscn")
