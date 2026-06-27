extends Node2D

const WARIOWARE_FONT = preload("res://Wariowareinc-BWWdn.ttf")
const GARLIC_TARGET = 5
const TIME_LIMIT = 10.0

var garlic_clicked := 0
var time_left: float
var finished := false

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	hud_label.add_theme_font_override("font", WARIOWARE_FONT)
	hud_label.add_theme_constant_override("outline_size", 4)
	time_left = TIME_LIMIT / Global.get_speed_mult()
	update_hud()

	var screen = get_viewport_rect()
	for child in get_children():
		if child is TextureButton:
			var bw = child.size.x * child.scale.x
			var bh = child.size.y * child.scale.y
			child.position = Vector2(
				randf_range(0, screen.size.x - bw),
				randf_range(0, screen.size.y - bh)
			)
			child.pressed.connect(_on_garlic_clicked.bind(child))
	show_instruction()

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0:
		time_left = 0
		finished = true
		Global.lives -= 1
		if Global.lives <= 0:
			Transition.change_scene("res://lose_screen.tscn")
		else:
			Transition.change_scene("res://level.tscn")
		return

	update_hud()

func _on_garlic_clicked(button: TextureButton) -> void:
	if finished or not button.visible:
		return

	button.visible = false
	button.disabled = true

	garlic_clicked += 1
	update_hud()

	if garlic_clicked >= GARLIC_TARGET:
		finished = true
		Transition.change_scene("res://level.tscn")

func show_instruction() -> void:
	var label = Label.new()
	label.text = "Click all the garlics!"
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
	hud_label.text = "Garlic: %d/%d\nTime: %.1f" % [garlic_clicked, GARLIC_TARGET, time_left]
