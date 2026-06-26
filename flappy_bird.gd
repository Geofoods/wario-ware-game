extends CharacterBody2D

const GRAVITY = 1200.0
const FLAP_VELOCITY = -450.0
const DEATH_GRAVITY = 2000.0
const DEATH_ROTATION_SPEED = 12.0
const DEATH_DELAY = 1.0

var dead := false
var death_timer := 0.0
var started := false
var mouse_was_down := false
var screen_height := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	screen_height = get_viewport_rect().size.y

func _physics_process(delta: float) -> void:
	if dead:
		death_timer += delta
		velocity.y += DEATH_GRAVITY * delta
		sprite.rotation += DEATH_ROTATION_SPEED * delta
		move_and_slide()
		if death_timer >= DEATH_DELAY:
			Transition.change_scene("res://texture_rect.tscn")
		return

	var mouse_click := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_was_down
	mouse_was_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var flap = Input.is_action_just_pressed("ui_accept") or mouse_click

	if not started:
		if flap:
			started = true
			velocity.y = FLAP_VELOCITY
		return

	velocity.y += GRAVITY * delta

	if flap:
		velocity.y = FLAP_VELOCITY

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is StaticBody2D:
			die()

	if global_position.y < -100 or global_position.y > screen_height + 100:
		die()

func die() -> void:
	if dead:
		return
	dead = true
	collision_shape.disabled = true
	velocity = Vector2(0, -200)
