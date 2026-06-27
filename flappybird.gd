extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")
const TIME_LIMIT = 10.0
const BASE_PIPE_SPEED = 200.0
const PIPE_MIN_Y = 600
const PIPE_MAX_Y = 900

var time_left: float
var finished := false
var started := false
var pipe_speed := BASE_PIPE_SPEED
var mouse_was_down := false

@onready var hud_label: Label = $CanvasLayer/HUDLabel
@onready var pipes: Array[Node] = []

func _ready() -> void:
	hud_label.add_theme_font_override("font", WARIOWARE_FONT)
	hud_label.add_theme_constant_override("outline_size", 4)
	var sm = Global.get_speed_mult()
	time_left = TIME_LIMIT / sm
	pipe_speed = BASE_PIPE_SPEED * sm
	update_hud()

	var template = $NicePngPipesPng388476
	for i in 3:
		var pipe = template.duplicate()
		pipe.position.x = 1200 + i * 400
		pipe.position.y = randf_range(PIPE_MIN_Y, PIPE_MAX_Y)
		add_child(pipe)
		pipes.append(pipe)

	template.queue_free()
	show_instruction()

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
		pipe.position.x -= pipe_speed * delta
		if pipe.position.x < -200:
			pipe.position.x = 1200
			pipe.position.y = randf_range(PIPE_MIN_Y, PIPE_MAX_Y)

func show_instruction() -> void:
	var label = Label.new()
	label.text = "Flap to survive!"
	label.add_theme_font_override("font", WARIOWARE_FONT)
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_font_size_override("font_size", 80)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var canvas = CanvasLayer.new()
	canvas.add_child(label)
	add_child(canvas)
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)

func update_hud() -> void:
	hud_label.text = "Survive: %.1f" % time_left
