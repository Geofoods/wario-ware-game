extends Node2D

const GARLIC_TARGET = 5
const TIME_LIMIT = 10.0

var garlic_clicked := 0
var time_left := TIME_LIMIT
var finished := false

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	update_hud()

	for child in get_children():
		if child is TextureButton:
			child.pressed.connect(_on_garlic_clicked.bind(child))

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0:
		time_left = 0
		finished = true
		get_tree().change_scene_to_file("res://texture_rect.tscn")
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
		get_tree().change_scene_to_file("res://level.tscn")

func update_hud() -> void:
	hud_label.text = "Garlic: %d/%d\nTime: %.1f" % [garlic_clicked, GARLIC_TARGET, time_left]
