extends Node2D

const GARLIC_TARGET = 1
const TIME_LIMIT = 10.0

var garlic_collected := 0
var time_left := TIME_LIMIT
var finished := false

@onready var hud_label: Label = $CanvasLayer/HUDLabel

func _ready() -> void:
	update_hud()

	var area: Area2D = $garlic.get_node("Area2D")
	area.body_entered.connect(_on_garlic_collected.bind($garlic))

func _process(delta: float) -> void:
	if finished:
		return

	time_left -= delta
	if time_left <= 0:
		time_left = 0
		finished = true
		get_tree().change_scene_to_file("res://level.tscn")
		return

	update_hud()

func _on_garlic_collected(body: Node2D, garlic: Node) -> void:
	if finished or not garlic.visible:
		return
	if body.name != "player":
		return

	garlic.visible = false
	var area: Area2D = garlic.get_node("Area2D")
	area.set_deferred("monitoring", false)

	garlic_collected += 1
	update_hud()

	if garlic_collected >= GARLIC_TARGET:
		finished = true
		get_tree().change_scene_to_file("res://level.tscn")

func update_hud() -> void:
	hud_label.text = "Garlic: %d/%d\nTime: %.1f" % [garlic_collected, GARLIC_TARGET, time_left]
