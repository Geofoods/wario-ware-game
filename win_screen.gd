extends Control

func _on_play_again_pressed() -> void:
	Global.play_click_sound()
	Transition.change_scene("res://level.tscn")

func _on_main_menu_pressed() -> void:
	Global.play_click_sound()
	Transition.change_scene("res://texture_rect.tscn")
