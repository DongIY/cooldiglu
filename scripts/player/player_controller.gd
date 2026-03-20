extends Node2D

signal interact_requested

@export var speed := 220.0
@export var move_bounds := Rect2(80.0, 90.0, 1120.0, 540.0)

func _process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += input_vector * speed * delta
	position.x = clamp(position.x, move_bounds.position.x, move_bounds.position.x + move_bounds.size.x)
	position.y = clamp(position.y, move_bounds.position.y, move_bounds.position.y + move_bounds.size.y)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact_requested.emit()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color("#ffe5a3"))
	draw_circle(Vector2(-6, -3), 2.0, Color("#23304d"))
	draw_circle(Vector2(6, -3), 2.0, Color("#23304d"))
	draw_arc(Vector2(0, 3), 7.0, 0.3, 2.8, 16, Color("#23304d"), 2.0)
