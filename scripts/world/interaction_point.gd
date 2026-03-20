extends Node2D

@export var point_id := ""
@export var display_name := "点位"
@export var prompt_text := "调查"
@export var interaction_radius := 84.0

var active := true

func is_player_near(player_position: Vector2) -> bool:
	return position.distance_to(player_position) <= interaction_radius

func set_active(value: bool) -> void:
	active = value
	queue_redraw()

func _draw() -> void:
	var marker_color := Color("#ff91b4") if active else Color("#7b8092")
	draw_circle(Vector2.ZERO, 16.0, marker_color)
	draw_arc(Vector2.ZERO, interaction_radius, 0.0, TAU, 40, Color(1, 1, 1, 0.08), 2.0)
