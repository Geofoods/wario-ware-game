extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")
const GARLIC_TARGET = 1
const TIME_LIMIT = 10.0
const PLATFORM_W = 350.0
const PLATFORM_H = 30.0
const BOUNCE_VEL = -850.0
const LAVA_RISE = 80.0
const GRAVITY = 1200.0
const MOVE_SPEED = 500.0
const PLATFORM_GAP = 220.0
const SCROLL_Y = 200.0

var garlic_collected := 0
var time_left: float
var finished := false
var started := false
var mouse_was_down := false
var platforms: Array = []
var player_node: CharacterBody2D
var screen: Rect2
var highest_y := 0.0
var lava_top := 0.0
var lava_node: ColorRect
var instruction_label: Label
var instruction_canvas: CanvasLayer

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	hud_label.add_theme_font_override("font", WARIOWARE_FONT)
	hud_label.add_theme_constant_override("outline_size", 4)
	time_left = TIME_LIMIT / Global.get_speed_mult()
	update_hud()

	screen = get_viewport_rect()

	player_node = $player
	player_node.script = null
	player_node.position = Vector2(screen.size.x * 0.5, screen.size.y - 180 - 115)
	player_node.velocity = Vector2.ZERO
	lava_top = screen.size.y
	lava_node = ColorRect.new()
	lava_node.color = Color(1, 0.15, 0, 0.85)
	lava_node.size = Vector2(screen.size.x, 200)
	lava_node.position = Vector2(0, lava_top)
	add_child(lava_node)

	for i in 10:
		var y = screen.size.y - 180 - i * PLATFORM_GAP
		var x: float
		if i == 0:
			x = player_node.position.x - PLATFORM_W * 0.5
		else:
			x = randf_range(40, screen.size.x - 40 - PLATFORM_W)
		spawn_platform_at(x, y)
		highest_y = y

	spawn_garlic()
	show_instruction()

func _physics_process(delta: float) -> void:
	if finished:
		return

	if not started:
		var mouse_click := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_was_down
		mouse_was_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		if Input.is_action_just_pressed("ui_accept") or mouse_click:
			started = true
			if instruction_canvas:
				var tween = create_tween()
				tween.tween_property(instruction_label, "modulate:a", 0.0, 0.3)
				tween.tween_callback(instruction_canvas.queue_free)
		return

	time_left -= delta
	if time_left <= 0:
		finish(false)
		return

	var mouse_x = get_viewport().get_mouse_position().x
	var diff = mouse_x - player_node.position.x
	if abs(diff) > 5:
		player_node.position.x += sign(diff) * MOVE_SPEED * delta
	player_node.position.x = clamp(player_node.position.x, 20, screen.size.x - 20)

	player_node.velocity.y += GRAVITY * delta
	player_node.move_and_slide()

	if player_node.is_on_floor():
		player_node.velocity.y = BOUNCE_VEL

	if player_node.position.y < SCROLL_Y:
		var offset = SCROLL_Y - player_node.position.y
		player_node.position.y += offset
		for p in platforms:
			p.position.y += offset
		highest_y += offset
		lava_top += offset
		player_node.position.y = SCROLL_Y

	lava_top -= LAVA_RISE * delta
	lava_node.position.y = lava_top

	if player_node.position.y > screen.size.y or player_node.position.y > lava_top - 115:
		finish(false)
		return

	while highest_y > -200:
		highest_y -= PLATFORM_GAP
		var x = randf_range(40, screen.size.x - 40 - PLATFORM_W)
		spawn_platform_at(x, highest_y)

	platforms = platforms.filter(func(p):
		if not is_instance_valid(p):
			return false
		if p.position.y > screen.size.y + 100:
			p.queue_free()
			return false
		return true
	)

	update_hud()

func spawn_platform_at(x: float, y: float) -> void:
	var body = StaticBody2D.new()
	body.position = Vector2(x + PLATFORM_W * 0.5, y + PLATFORM_H * 0.5)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(PLATFORM_W, PLATFORM_H)
	shape.shape = rect
	body.add_child(shape)

	var visual = ColorRect.new()
	visual.color = Color(0.2, 0.7, 0.2)
	visual.size = Vector2(PLATFORM_W, PLATFORM_H)
	visual.position = Vector2(-PLATFORM_W * 0.5, -PLATFORM_H * 0.5)
	body.add_child(visual)

	add_child(body)
	platforms.append(body)

func spawn_garlic() -> void:
	var garlic_y = highest_y - PLATFORM_GAP * 4
	var garlic_x = randf_range(40, screen.size.x - 40 - PLATFORM_W)
	var area = Area2D.new()
	area.position = Vector2(garlic_x + PLATFORM_W * 0.5, garlic_y - 20)
	area.body_entered.connect(_on_garlic_collected)
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://images__1_-removebg-preview.png")
	sprite.scale = Vector2(0.15, 0.15)
	area.add_child(sprite)
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 30
	shape.shape = circle
	area.add_child(shape)
	add_child(area)

func _on_garlic_collected(body: Node2D) -> void:
	if finished:
		return
	if body == player_node:
		garlic_collected += 1
		finish(true)

func finish(won: bool) -> void:
	if finished:
		return
	finished = true
	if won:
		Transition.change_scene("res://level.tscn")
	else:
		Global.lives -= 1
		if Global.lives <= 0:
			Transition.change_scene("res://lose_screen.tscn")
		else:
			Transition.change_scene("res://level.tscn")

func show_instruction() -> void:
	instruction_label = Label.new()
	instruction_label.text = "Click to start!"
	instruction_label.add_theme_font_override("font", WARIOWARE_FONT)
	instruction_label.add_theme_constant_override("outline_size", 6)
	instruction_label.add_theme_font_size_override("font_size", 80)
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	instruction_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	instruction_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	instruction_canvas = CanvasLayer.new()
	instruction_canvas.add_child(instruction_label)
	add_child(instruction_canvas)

func update_hud() -> void:
	hud_label.text = "Garlic: %d/%d\nTime: %.1f" % [garlic_collected, GARLIC_TARGET, time_left]
