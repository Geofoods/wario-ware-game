extends Node2D

const YOSHI_COUNT = 50
const YOSHI_TEXTURE = preload("res://yoshi.png")
const LUIGI_TEXTURE = preload("res://luigi.png")
const SPEED_MIN = 200.0
const SPEED_MAX = 450.0
const BOUNCE_MARGIN = 20

var screen_rect: Rect2
var finished := false
var velocities: Dictionary = {}

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	screen_rect = get_viewport_rect()

	for i in YOSHI_COUNT:
		spawn_creature(YOSHI_TEXTURE, false)

	spawn_creature(LUIGI_TEXTURE, true)

	hud_label.text = "Find Luigi!"

func _process(delta: float) -> void:
	if finished:
		return

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
		randf_range(-1, 1) * randf_range(SPEED_MIN, SPEED_MAX),
		randf_range(-1, 1) * randf_range(SPEED_MIN, SPEED_MAX)
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

func _on_luigi_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if finished:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		finished = true
		get_tree().change_scene_to_file("res://level.tscn")
