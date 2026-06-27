extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")

enum State { PLAYING, WON, LOST }

@onready var level_label: Label = $CanvasLayer/Label2
@onready var timer_label: Label = $CanvasLayer/Label
@onready var garlics: Array[Node] = [$Garlic, $Garlic2, $Garlic3, $Garlic4, $Garlic5]
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var time_left: float = 2.0
var state: State = State.PLAYING

func _ready() -> void:
	level_label.add_theme_font_override("font", WARIOWARE_FONT)
	level_label.add_theme_constant_override("outline_size", 10)
	timer_label.add_theme_font_override("font", WARIOWARE_FONT)
	timer_label.add_theme_constant_override("outline_size", 10)

	for i in garlics.size():
		garlics[i].visible = i < Global.lives

	level_label.text = "Level %d" % Global.round
	timer_label.text = "%.1f" % time_left
	music_player.play()

func _process(delta: float) -> void:
	match state:
		State.PLAYING:
			time_left -= delta
			timer_label.text = "%.1f" % maxf(time_left, 0.0)
			if time_left <= 0:
				state = State.WON
				_on_timer_done()
		State.WON:
			pass
		State.LOST:
			pass

func _on_timer_done() -> void:
	Global.round += 1
	music_player.stop()
	var levels = [
		"res://platformerlevel.tscn",
		"res://clickergame.tscn",
		"res://flappybird.tscn",
		"res://findluigi.tscn",
		"res://pong.tscn",
		"res://spaceinvaders.tscn"
	]
	var next = levels[randi() % levels.size()]
	Transition.change_scene(next)
