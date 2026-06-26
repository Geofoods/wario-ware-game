extends Control

func _ready() -> void:
	await get_tree().process_frame
	Transition.fade_in()

func _on_button_pressed() -> void:
	Transition.change_scene("res://level.tscn")
