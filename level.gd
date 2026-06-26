extends Node2D

enum State { PLAYING, WON, LOST }

@onready var level_label: Label = $Label2
@onready var timer_label: Label = $Label

var time_left: float = 2.0
var state: State = State.PLAYING

func _ready() -> void:
	Global.current_level += 1
	level_label.text = "Level %d" % Global.current_level
	timer_label.text = "%.1f" % time_left

func _process(delta: float) -> void:
	match state:
		State.PLAYING:
			time_left -= delta
			timer_label.text = "%.1f" % time_left
			if time_left <= 0:
				state = State.WON
				_on_timer_done()
		State.WON:
			pass
		State.LOST:
			pass

func _on_timer_done() -> void:
	match Global.current_level:
		1:
			get_tree().change_scene_to_file("res://platformerlevel.tscn")
		2:
			get_tree().change_scene_to_file("res://clickergame.tscn")
		3:
			get_tree().change_scene_to_file("res://flappybird.tscn")
		4:
			get_tree().change_scene_to_file("res://findluigi.tscn")
		5:
			get_tree().change_scene_to_file("res://pong.tscn")
		6:
			get_tree().change_scene_to_file("res://spaceinvaders.tscn")
		_:
			get_tree().change_scene_to_file("res://platformerlevel.tscn")

func _on_win() -> void:
	get_tree().change_scene_to_file("res://win_screen.tscn")

func _on_lost() -> void:
	get_tree().change_scene_to_file("res://lose_screen.tscn")
