extends CharacterBody2D

const GRAVITY = 1200.0
const FLAP_VELOCITY = -450.0

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = FLAP_VELOCITY

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is StaticBody2D:
			die()

	if global_position.y < -100 or global_position.y > 900:
		die()

func die() -> void:
	get_tree().change_scene_to_file("res://texture_rect.tscn")
