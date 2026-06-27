extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")
const TIME_LIMIT = 10.0
const YOSHI_COUNT = 50
const YOSHI_TEXTURE = preload("res://yoshi.png")
const LUIGI_TEXTURE = preload("res://luigi.png")
const BASE_SPEED_MIN = 200.0
const BASE_SPEED_MAX = 450.0
const BOUNCE_MARGIN = 20

var screen_rect: Rect2
var finished := false
var time_left: float
var velocities: Dictionary = {}
var speed_min := BASE_SPEED_MIN
var speed_max := BASE_SPEED_MAX

@onready var hud_label: Label = $CanvasLayer/HUDLabel
@onready var music_player: AudioStreamPlayer = $MusicPlayer

func _ready() -> void:
	music_player.stream.loop = true
	music_player.play()
	hud_label.add_theme_font_override("font", WARIOWARE_FONT)
	hud_label.add_theme_constant_override("outline_size", 4)
	screen_rect = get_viewport_rect()
	var sm = Global.get_speed_mult()
	time_left = TIME_LIMIT / sm
	speed_min = BASE_SPEED_MIN * sm
	speed_max = BASE_SPEED_MAX * sm

	for i in YOSHI_COUNT:
		spawn_creature(YOSHI_TEXTURE, false)

	spawn_creature(LUIGI_TEXTURE, true)

	update_hud()
	show_instruction()

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0:
		finished = true
		Global.lives -= 1
		Global.play_fail_sound()
		if Global.lives <= 0:
			Transition.change_scene("res://lose_screen.tscn")
		else:
			Transition.change_scene("res://level.tscn")
		return

	update_hud()

	for child in get_children():
		if child is Area2D:
			var vel = velocities[child.get_instance_id()]
			child.position += vel * delta

			if child.position.x < BOUNCE_MARGIN:
				child.position.x = BOUNCE_MARGIN
				vel.x = abs(vel.x)
			elif child.position.x > screen_rect.size.x - BOUNCE_MARGIN:
				child.position.x = screen_rect.size.x - BOUNCE_MARGIN
				vel.x = -abs(vel.x)

			if child.position.y < BOUNCE_MARGIN:
				child.position.y = BOUNCE_MARGIN
				vel.y = abs(vel.y)
			elif child.position.y > screen_rect.size.y - BOUNCE_MARGIN:
				child.position.y = screen_rect.size.y - BOUNCE_MARGIN
				vel.y = -abs(vel.y)

			velocities[child.get_instance_id()] = vel

func spawn_creature(texture: Texture2D, is_luigi: bool) -> void:
	var area = Area2D.new()
	var pos = Vector2(
		randf_range(50, screen_rect.size.x - 50),
		randf_range(50, screen_rect.size.y - 50)
	)
	area.position = pos

	var vel = Vector2(
		randf_range(-1, 1) * randf_range(speed_min, speed_max),
		randf_range(-1, 1) * randf_range(speed_min, speed_max)
	)
	velocities[area.get_instance_id()] = vel

	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(0.3, 0.3) if not is_luigi else Vector2(0.5, 0.5)
	area.add_child(sprite)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	var tex_size = texture.get_size()
	rect.size = tex_size * sprite.scale
	shape.shape = rect
	area.add_child(shape)

	if is_luigi:
		area.input_event.connect(_on_luigi_clicked)
		area.z_index = 0
	else:
		area.z_index = randi() % 3

	add_child(area)

func show_instruction() -> void:
	var label = Label.new()
	label.text = "Find Luigi!"
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
	hud_label.text = "Find Luigi!  Time: %.1f" % time_left

func _on_luigi_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if finished:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		finished = true
		Global.play_success_sound()
		Transition.change_scene("res://level.tscn")
