extends Control

func _ready() -> void:
	await get_tree().process_frame
	Transition.fade_in()

func _on_button_pressed() -> void:
	Global.reset()
	Transition.change_scene("res://level.tscn")

func _on_button_2_pressed() -> void:
	get_tree().quit()
