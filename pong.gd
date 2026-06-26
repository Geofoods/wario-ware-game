extends Node2D

const SURVIVE_TIME = 5.0
const BALL_SPEED = 300.0
const PADDLE_WIDTH = 120.0
const PADDLE_Y = 600.0

var time_left := SURVIVE_TIME
var finished := false
var ball_velocity := Vector2.ZERO
var screen_rect: Rect2

@onready var hud_label: Label = $CanvasLayer/HUDLabel
@onready var ball := $Ball as CharacterBody2D
@onready var paddle := $Paddle as CharacterBody2D

func _ready() -> void:
	screen_rect = get_viewport_rect()
	ball.position = screen_rect.size * 0.5
	var angle = randf_range(-0.5, 0.5)
	ball_velocity = Vector2(cos(angle), sin(angle)).normalized() * BALL_SPEED
	paddle.position = Vector2(screen_rect.size.x * 0.5, PADDLE_Y)

	hud_label.add_theme_color_override("font_color", Color.WHITE)
	update_hud()

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0:
		finished = true
		get_tree().change_scene_to_file("res://level.tscn")
		return

	update_hud()

	paddle.position.x = get_viewport().get_mouse_position().x
	paddle.position.x = clamp(paddle.position.x, PADDLE_WIDTH * 0.5, screen_rect.size.x - PADDLE_WIDTH * 0.5)

	ball.position += ball_velocity * delta

	if ball.position.x < 5 or ball.position.x > screen_rect.size.x - 5:
		ball_velocity.x = -ball_velocity.x
		ball.position.x = clamp(ball.position.x, 5, screen_rect.size.x - 5)

	if ball.position.y < 5:
		ball_velocity.y = -ball_velocity.y
		ball.position.y = 5

	if ball.position.y > screen_rect.size.y:
		finished = true
		get_tree().change_scene_to_file("res://texture_rect.tscn")
		return

	if ball.position.y > PADDLE_Y - 10 and ball.position.y < PADDLE_Y + 10:
		if abs(ball.position.x - paddle.position.x) < PADDLE_WIDTH * 0.5:
			ball_velocity.y = -ball_velocity.y
			ball_velocity.x += (ball.position.x - paddle.position.x) * 2.0
			ball_velocity = ball_velocity.normalized() * BALL_SPEED

func update_hud() -> void:
	hud_label.text = "Survive: %.1f" % time_left
