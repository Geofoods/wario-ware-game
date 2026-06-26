extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")
const TIME_LIMIT = 10.0
const PIPE_SPEED = 200.0
const PIPE_MIN_Y = 600
const PIPE_MAX_Y = 950

var time_left := TIME_LIMIT
var finished := false
var started := false
var mouse_was_down := false

@onready var hud_label: Label = $CanvasLayer/HUDLabel
@onready var pipes: Array[Node] = []

func _ready() -> void:
	hud_label.add_theme_font_override("font", WARIOWARE_FONT)
	hud_label.add_theme_constant_override("outline_size", 4)
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

	if not started:
		var mouse_click := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_was_down
		mouse_was_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		if Input.is_action_just_pressed("ui_accept") or mouse_click:
			started = true
		return

	time_left -= delta
	if time_left <= 0:
		time_left = 0
		finished = true
		Transition.change_scene("res://level.tscn")
		return

	update_hud()

	for pipe in pipes:
		pipe.position.x -= PIPE_SPEED * delta
		if pipe.position.x < -200:
			pipe.position.x = 1200
			pipe.position.y = randf_range(PIPE_MIN_Y, PIPE_MAX_Y)

func update_hud() -> void:
	hud_label.text = "Survive: %.1f" % time_left
