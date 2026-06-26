extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")

enum State { PLAYING, WON, LOST }

@onready var level_label: Label = $CanvasLayer/Label2
@onready var timer_label: Label = $CanvasLayer/Label

var time_left: float = 2.0
var state: State = State.PLAYING

func _ready() -> void:
	level_label.add_theme_font_override("font", WARIOWARE_FONT)
	level_label.add_theme_constant_override("outline_size", 10)
	timer_label.add_theme_font_override("font", WARIOWARE_FONT)
	timer_label.add_theme_constant_override("outline_size", 10)
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
			Transition.change_scene("res://platformerlevel.tscn")
		2:
			Transition.change_scene("res://clickergame.tscn")
		3:
			Transition.change_scene("res://flappybird.tscn")
		4:
			Transition.change_scene("res://findluigi.tscn")
		5:
			Transition.change_scene("res://pong.tscn")
		6:
			Transition.change_scene("res://spaceinvaders.tscn")
		_:
			Transition.change_scene("res://platformerlevel.tscn")

func _on_win() -> void:
	Transition.change_scene("res://win_screen.tscn")

func _on_lost() -> void:
	Transition.change_scene("res://lose_screen.tscn")
