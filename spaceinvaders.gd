extends Node2D

const TIME_LIMIT = 10.0
const PLAYER_WIDTH = 18.0
const PLAYER_HEIGHT = 40.0
const PLAYER_X = 40.0
const BULLET_SIZE = 6.0
const BULLET_SPEED = 700.0
const ENEMY_SIZE = 26.0
const ENEMY_DRIFT = 40.0
const ENEMY_BOB_AMPLITUDE = 60.0
const ENEMY_BOB_SPEED = 3.0
const ROWS = 3
const COLS = 5

var time_left := TIME_LIMIT
var finished := false
var player_y := 0.0
var bullets: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var screen_rect: Rect2
var shoot_cooldown := 0.0
var elapsed := 0.0
var mouse_was_down := false

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	screen_rect = get_viewport_rect()
	player_y = screen_rect.size.y * 0.5

	var start_x = screen_rect.size.x * 0.55
	var start_y = screen_rect.size.y * 0.15
	var spacing_x = screen_rect.size.x * 0.07
	var spacing_y = ENEMY_SIZE * 2.8

	for row in ROWS:
		for col in COLS:
			enemies.append({
				pos_x = start_x + col * spacing_x,
				base_y = start_y + row * spacing_y,
				alive = true,
				phase = randf_range(0, TAU)
			})

	update_hud()

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	elapsed += delta
	if time_left <= 0:
		finished = true
		get_tree().change_scene_to_file("res://texture_rect.tscn")
		return

	update_hud()

	player_y = get_viewport().get_mouse_position().y
	player_y = clamp(player_y, PLAYER_HEIGHT * 0.5, screen_rect.size.y - PLAYER_HEIGHT * 0.5)

	shoot_cooldown -= delta
	if shoot_cooldown <= 0:
		var shoot = Input.is_action_just_pressed("ui_accept")
		if not shoot and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_was_down:
			shoot = true
		if shoot:
			bullets.append({
				pos = Vector2(PLAYER_X + PLAYER_WIDTH, player_y),
				vel = Vector2(BULLET_SPEED, 0)
			})
			shoot_cooldown = 0.25
	mouse_was_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	for b in bullets:
		b.pos += b.vel * delta

	bullets = bullets.filter(func(b): return b.pos.x < screen_rect.size.x + BULLET_SIZE)

	for e in enemies:
		if e.alive:
			e.pos_x -= ENEMY_DRIFT * delta

	for e in enemies:
		if not e.alive:
			continue
		if e.pos_x < PLAYER_X + PLAYER_WIDTH + ENEMY_SIZE:
			finished = true
			get_tree().change_scene_to_file("res://texture_rect.tscn")
			return

	for b in bullets:
		var b_rect = Rect2(b.pos - Vector2(BULLET_SIZE, BULLET_SIZE) * 0.5, Vector2(BULLET_SIZE * 2, BULLET_SIZE))
		for e in enemies:
			if not e.alive:
				continue
			var ey = e.base_y + sin(elapsed * ENEMY_BOB_SPEED + e.phase) * ENEMY_BOB_AMPLITUDE
			var e_rect = Rect2(e.pos_x - ENEMY_SIZE * 0.5, ey - ENEMY_SIZE * 0.5, ENEMY_SIZE, ENEMY_SIZE)
			if b_rect.intersects(e_rect):
				e.alive = false
				b.pos.x = -9999
				break

	bullets = bullets.filter(func(b): return b.pos.x <= screen_rect.size.x)

	var all_dead = true
	for e in enemies:
		if e.alive:
			all_dead = false
			break

	if all_dead:
		finished = true
		get_tree().change_scene_to_file("res://level.tscn")
		return

	queue_redraw()

func _draw() -> void:
	var px = PLAYER_X
	var py = player_y
	var hw = PLAYER_WIDTH * 0.5
	var hh = PLAYER_HEIGHT * 0.5
	var ship = PackedVector2Array([
		Vector2(px + hw, py),
		Vector2(px - hw, py - hh),
		Vector2(px - hw * 0.5, py),
		Vector2(px - hw, py + hh)
	])
	draw_colored_polygon(ship, Color(0.2, 0.8, 1, 1))

	for b in bullets:
		draw_rect(Rect2(b.pos.x - BULLET_SIZE, b.pos.y - BULLET_SIZE * 0.5, BULLET_SIZE * 2, BULLET_SIZE), Color(1, 0.3, 0.1, 1))

	for e in enemies:
		if e.alive:
			var ey = e.base_y + sin(elapsed * ENEMY_BOB_SPEED + e.phase) * ENEMY_BOB_AMPLITUDE
			var es = ENEMY_SIZE
			var enemy_shape = PackedVector2Array([
				Vector2(e.pos_x - es * 0.5, ey + es * 0.5),
				Vector2(e.pos_x, ey - es * 0.5),
				Vector2(e.pos_x + es * 0.5, ey + es * 0.5)
			])
			draw_colored_polygon(enemy_shape, Color(0, 1, 0.3, 1))

func update_hud() -> void:
	var alive = 0
	for e in enemies:
		if e.alive:
			alive += 1
	hud_label.text = "Enemies: %d  Time: %.1f" % [alive, time_left]
