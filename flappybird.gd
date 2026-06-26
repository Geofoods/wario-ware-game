extends Node2D

const TIME_LIMIT = 10.0
const PIPE_SPEED = 200.0
const PIPE_MIN_Y = 600
const PIPE_MAX_Y = 950

var time_left := TIME_LIMIT
var finished := false

@onready var hud_label: Label = $CanvasLayer/HUDLabel
@onready var pipes: Array[Node] = []

func _ready() -> void:
	update_hud()

	var template = $NicePngPipesPng388476
	for i in 3:
		var pipe = template.duplicate()
		pipe.position.x = 1200 + i * 400
		pipe.position.y = randf_range(PIPE_MIN_Y, PIPE_MAX_Y)
		add_child(pipe)
		pipes.append(pipe)

	template.queue_free()

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0:
		time_left = 0
		finished = true
		get_tree().change_scene_to_file("res://level.tscn")
		return

	update_hud()

	for pipe in pipes:
		pipe.position.x -= PIPE_SPEED * delta
		if pipe.position.x < -200:
			pipe.position.x = 1200
			pipe.position.y = randf_range(PIPE_MIN_Y, PIPE_MAX_Y)

func update_hud() -> void:
	hud_label.text = "Survive: %.1f" % time_left
