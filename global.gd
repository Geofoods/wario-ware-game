extends Node

var lives := 5
var round := 0
const MAX_LIVES := 5

func reset() -> void:
	lives = MAX_LIVES
	round = 0

func get_speed_mult() -> float:
	return 1.0 + round * 0.15
