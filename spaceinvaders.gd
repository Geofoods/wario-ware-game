extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")
const TIME_LIMIT = 20.0
const PLAYER_WIDTH = 30.0
const PLAYER_HEIGHT = 20.0
const BULLET_SIZE = 6.0
const BULLET_SPEED = 500.0
const BASE_ENEMY_SPEED = 80.0
const ENEMY_DESCENT = 30.0
const ROWS = 3
const COLS = 5
const ENEMY_SCALE = 0.08

const ALIEN_TEXTURE = preload("res://toppng.com-space-invaders-alien-space-invaders-alien-sprite-1057x769.png")

var time_left: float
var finished := false
var player_x := 0.0
var bullets: Array[Dictionary] = []
var enemies: Array[Node] = []
var screen_rect: Rect2
var shoot_cooldown := 0.0
var mouse_was_down := false
var enemy_direction := 1
var enemy_speed := BASE_ENEMY_SPEED
var dying_enemies := {}

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	hud_label.add_theme_font_override("font", WARIOWARE_FONT)
	hud_label.add_theme_constant_override("outline_size", 4)
	screen_rect = get_viewport_rect()
	player_x = screen_rect.size.x * 0.5
	var sm = Global.get_speed_mult()
	time_left = TIME_LIMIT / sm
	enemy_speed = BASE_ENEMY_SPEED * sm

	var start_x = screen_rect.size.x * 0.15
	var start_y = screen_rect.size.y * 0.1
	var spacing_x = screen_rect.size.x * 0.14
	var spacing_y = 60.0

	for row in ROWS:
		for col in COLS:
			var sprite = Sprite2D.new()
			sprite.texture = ALIEN_TEXTURE
			sprite.scale = Vector2(ENEMY_SCALE, ENEMY_SCALE)
			var pos_x = start_x + col * spacing_x
			var pos_y = start_y + row * spacing_y
			sprite.position = Vector2(pos_x, pos_y)
			add_child(sprite)
			enemies.append(sprite)

	update_hud()
	show_instruction()

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0:
		finished = true
		Global.lives -= 1
		if Global.lives <= 0:
			Transition.change_scene("res://lose_screen.tscn")
		else:
			Transition.change_scene("res://level.tscn")
		return

	update_hud()

	player_x = get_viewport().get_mouse_position().x
	player_x = clamp(player_x, PLAYER_WIDTH * 0.5, screen_rect.size.x - PLAYER_WIDTH * 0.5)

	shoot_cooldown -= delta
	if shoot_cooldown <= 0:
		var shoot = Input.is_action_just_pressed("ui_accept")
		if not shoot and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_was_down:
			shoot = true
		if shoot:
			bullets.append({
				pos = Vector2(player_x, screen_rect.size.y - PLAYER_HEIGHT - 10),
				vel = Vector2(0, -BULLET_SPEED)
			})
			shoot_cooldown = 0.0
	mouse_was_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	for b in bullets:
		b.pos += b.vel * delta

	bullets = bullets.filter(func(b): return b.pos.y > -BULLET_SIZE)

	var move_dir = Vector2(enemy_speed * enemy_direction * delta, 0)
	var edge_reached = false
	for e in enemies:
		if dying_enemies.has(e):
			continue
		e.position += move_dir
		if e.position.x < 50 or e.position.x > screen_rect.size.x - 50:
			edge_reached = true

	if edge_reached:
		enemy_direction *= -1
		for e in enemies:
			if dying_enemies.has(e):
				continue
			e.position.y += ENEMY_DESCENT
			e.position.x = clamp(e.position.x, 50, screen_rect.size.x - 50)

	for e in enemies:
		if dying_enemies.has(e):
			continue
		if e.position.y > screen_rect.size.y - 80:
			finished = true
			Global.lives -= 1
			if Global.lives <= 0:
				Transition.change_scene("res://lose_screen.tscn")
			else:
				Transition.change_scene("res://level.tscn")
			return

	for b in bullets:
		var b_rect = Rect2(b.pos.x - BULLET_SIZE * 0.5, b.pos.y - BULLET_SIZE * 0.5, BULLET_SIZE, BULLET_SIZE)
		for e in enemies:
			if not e.visible or dying_enemies.has(e):
				continue
			var tex = e.texture
			var tex_size = tex.get_size() * ENEMY_SCALE
			var e_rect = Rect2(e.position.x - tex_size.x * 0.5, e.position.y - tex_size.y * 0.5, tex_size.x, tex_size.y)
			if b_rect.intersects(e_rect):
				die(e)
				b.pos.y = -9999
				break

	bullets = bullets.filter(func(b): return b.pos.y >= 0)

	var all_dead = true
	for e in enemies:
		if e.visible and not dying_enemies.has(e):
			all_dead = false
			break

	if all_dead:
		finished = true
		Transition.change_scene("res://level.tscn")
		return

	queue_redraw()

func _draw() -> void:
	var px = player_x
	var py = screen_rect.size.y - PLAYER_HEIGHT - 10
	var hw = PLAYER_WIDTH * 0.5
	var hh = PLAYER_HEIGHT * 0.5
	var ship = PackedVector2Array([
		Vector2(px, py - hh),
		Vector2(px - hw, py + hh),
		Vector2(px + hw, py + hh)
	])
	draw_colored_polygon(ship, Color(0.2, 0.8, 1, 1))

	for b in bullets:
		draw_rect(Rect2(b.pos.x - BULLET_SIZE * 0.5, b.pos.y - BULLET_SIZE * 0.5, BULLET_SIZE, BULLET_SIZE), Color(1, 0.3, 0.1, 1))

func die(e: Node) -> void:
	dying_enemies[e] = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(e, "scale", e.scale * 1.5, 0.3)
	tween.tween_property(e, "modulate", Color(1, 0.3, 0.1, 0), 0.3)
	tween.tween_callback(func():
		e.visible = false
		dying_enemies.erase(e)
	)

func show_instruction() -> void:
	var label = Label.new()
	label.text = "Shoot all aliens!"
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
	var alive = 0
	for e in enemies:
		if e.visible:
			alive += 1
	hud_label.text = "Enemies: %d  Time: %.1f" % [alive, time_left]
