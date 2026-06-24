extends Node2D

enum State { PLAYING, WON, LOST }

@onready var timer_label: Label = $Label
@onready var level_label: Label = $Label2

var level: int = 0
var time_left: float = 5.0
var state: State = State.PLAYING

func _ready() -> void:
	next_level()

func _process(delta: float) -> void:
	match state:
		State.PLAYING:
			time_left -= delta
			timer_label.text = str(snapped(time_left, 0.1))
			if time_left <= 0:
				time_left = 0
				state = State.LOST
				_on_lost()
		State.WON:
			if Input.is_action_just_pressed(&"ui_accept"):
				next_level()
		State.LOST:
			if Input.is_action_just_pressed(&"ui_accept"):
				get_tree().change_scene_to_file("res://texture_rect.tscn")

func next_level() -> void:
	level += 1
	time_left = 5.0
	state = State.PLAYING
	level_label.text = "Level %d" % level
	timer_label.text = str(snapped(time_left, 0.1))

func _on_win() -> void:
	state = State.WON
	timer_label.text = "WIN!"

func _on_lost() -> void:
	timer_label.text = "GAME OVER"
