extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")
const BASE_SURVIVE_TIME = 10.0
const BASE_BALL_SPEED = 700.0
const PADDLE_HEIGHT = 100.0
const PADDLE_WIDTH = 15.0
const BALL_SIZE = 16.0
const PADDLE_X = 30.0

var time_left: float
var finished := false
var ball_pos := Vector2.ZERO
var ball_vel := Vector2.ZERO
var paddle_y := 0.0
var screen_rect: Rect2
var hue := 0.0
var ball_speed := BASE_BALL_SPEED

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	hud_label.add_theme_font_override("font", WARIOWARE_FONT)
	hud_label.add_theme_constant_override("outline_size", 4)
	screen_rect = get_viewport_rect()
	var sm = Global.get_speed_mult()
	time_left = BASE_SURVIVE_TIME / sm
	ball_speed = BASE_BALL_SPEED * sm
	ball_pos = screen_rect.size * 0.5
	var angle = randf_range(-0.5, 0.5)
	ball_vel = Vector2(cos(angle), sin(angle)).normalized() * ball_speed
	paddle_y = screen_rect.size.y * 0.5

	update_hud()
	show_instruction()

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0:
		finished = true
		Transition.change_scene("res://level.tscn")
		return

	update_hud()

	hue += delta * 3.0

	paddle_y = get_viewport().get_mouse_position().y
	paddle_y = clamp(paddle_y, PADDLE_HEIGHT * 0.5, screen_rect.size.y - PADDLE_HEIGHT * 0.5)
	ball_pos += ball_vel * delta

	if ball_pos.y < BALL_SIZE * 0.5 or ball_pos.y > screen_rect.size.y - BALL_SIZE * 0.5:
		ball_vel.y = -ball_vel.y
		ball_pos.y = clamp(ball_pos.y, BALL_SIZE * 0.5, screen_rect.size.y - BALL_SIZE * 0.5)

	if ball_pos.x > screen_rect.size.x - BALL_SIZE * 0.5:
		ball_vel.x = -ball_vel.x
		ball_pos.x = screen_rect.size.x - BALL_SIZE * 0.5

	if ball_pos.x - BALL_SIZE * 0.5 < PADDLE_X + PADDLE_WIDTH:
		if abs(ball_pos.y - paddle_y) < (BALL_SIZE + PADDLE_HEIGHT) * 0.5:
			ball_vel.x = -ball_vel.x
			ball_vel.y += (ball_pos.y - paddle_y) * 2.0
			ball_vel = ball_vel.normalized() * ball_speed
			ball_pos.x = PADDLE_X + PADDLE_WIDTH + BALL_SIZE * 0.5
		elif ball_pos.x < -BALL_SIZE:
			finished = true
			Global.lives -= 1
			if Global.lives <= 0:
				Transition.change_scene("res://lose_screen.tscn")
			else:
				Transition.change_scene("res://level.tscn")
			return

	queue_redraw()

func _draw() -> void:
	var ball_color = Color.from_hsv(fmod(hue, 1.0), 1.0, 1.0)
	var paddle_color = Color.from_hsv(fmod(hue + 0.5, 1.0), 1.0, 1.0)
	draw_rect(Rect2(ball_pos - Vector2(BALL_SIZE, BALL_SIZE) * 0.5, Vector2(BALL_SIZE, BALL_SIZE)), ball_color)
	draw_rect(Rect2(Vector2(PADDLE_X, paddle_y - PADDLE_HEIGHT * 0.5), Vector2(PADDLE_WIDTH, PADDLE_HEIGHT)), paddle_color)

func show_instruction() -> void:
	var label = Label.new()
	label.text = "Move mouse to block!"
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
