extends CanvasLayer

const FADE_DURATION = 0.3

var rect: ColorRect
var current_tween: Tween

func _ready() -> void:
	rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 1)
	rect.anchors_preset = Control.PRESET_FULL_RECT
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)

func fade_in(duration: float = FADE_DURATION) -> void:
	start_tween(0.0, duration)

func fade_out(duration: float = FADE_DURATION) -> void:
	start_tween(1.0, duration)

func start_tween(target_alpha: float, duration: float) -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(rect, "color:a", target_alpha, duration)

func change_scene(path: String) -> void:
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_out()
	await current_tween.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_in()
