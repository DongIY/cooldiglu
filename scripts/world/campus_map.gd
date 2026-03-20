extends Node2D

signal interaction_prompt_changed(prompt_text: String)
signal request_interaction(point_id: String)
signal location_changed(location_name: String)

@onready var player = $Player

var focused_point: Node = null

func _ready() -> void:
	player.interact_requested.connect(_on_player_interact)
	refresh_points()
	_update_focus_point(true)

func _process(_delta: float) -> void:
	_update_focus_point()

func refresh_points() -> void:
	for point in _get_points():
		point.set_active(EventSystem.has_available_event(point.point_id))
	_update_focus_point(true)

func apply_loaded_state() -> void:
	refresh_points()

func _on_player_interact() -> void:
	if focused_point != null:
		request_interaction.emit(focused_point.point_id)

func _update_focus_point(force_emit: bool = false) -> void:
	var next_point: Node = _pick_best_point()
	if next_point == focused_point and not force_emit:
		return
	focused_point = next_point
	if focused_point == null:
		interaction_prompt_changed.emit("")
		GameState.set_location("校园主路")
		location_changed.emit("校园主路")
		return
	interaction_prompt_changed.emit("E 互动：%s" % focused_point.prompt_text)
	GameState.set_location(focused_point.display_name)
	location_changed.emit(focused_point.display_name)

func _pick_best_point() -> Node:
	var closest_active: Node = null
	var closest_active_distance := INF
	var closest_any: Node = null
	var closest_any_distance := INF
	for point in _get_points():
		if not point.is_player_near(player.position):
			continue
		var distance: float = point.position.distance_to(player.position)
		if distance < closest_any_distance:
			closest_any_distance = distance
			closest_any = point
		if point.active and distance < closest_active_distance:
			closest_active_distance = distance
			closest_active = point
	return closest_active if closest_active != null else closest_any

func _get_points() -> Array:
	var points: Array = []
	for child in get_children():
		if child.has_method("is_player_near"):
			points.append(child)
	return points

func _draw() -> void:
	draw_rect(Rect2(40, 60, 1200, 600), Color("#d5e7ff"), true)
	draw_rect(Rect2(70, 85, 1160, 120), Color("#f2f6ff"), true)
	draw_rect(Rect2(120, 250, 420, 260), Color("#b9d6ff"), true)
	draw_rect(Rect2(660, 240, 460, 290), Color("#c4ebc8"), true)
	draw_rect(Rect2(920, 95, 200, 90), Color("#d8d1ff"), true)
	draw_line(Vector2(120, 190), Vector2(1120, 190), Color("#ffffff"), 10.0)
	draw_line(Vector2(610, 190), Vector2(610, 560), Color("#ffffff"), 10.0)
