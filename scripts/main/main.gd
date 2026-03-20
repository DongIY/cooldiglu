extends Node

@onready var campus_map = $CampusMap
@onready var hud = $UI/HUD
@onready var dialogue_panel = $UI/DialoguePanel
@onready var cg_gallery = $UI/CGGallery
@onready var save_load_menu = $UI/SaveLoadMenu

func _ready() -> void:
	EventSystem.dialogue_requested.connect(dialogue_panel.present_event)
	dialogue_panel.choice_selected.connect(_on_choice_selected)
	EventSystem.notification.connect(_on_system_message)
	EventSystem.gallery_refresh_requested.connect(_on_gallery_refresh_requested)
	TimeSystem.time_changed.connect(_on_time_changed)
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.load_completed.connect(_on_load_completed)
	campus_map.request_interaction.connect(_on_request_interaction)
	campus_map.interaction_prompt_changed.connect(hud.set_interaction_prompt)
	campus_map.location_changed.connect(hud.set_location)
	save_load_menu.save_requested.connect(_on_save_requested)
	save_load_menu.load_requested.connect(_on_load_requested)
	hud.set_day_and_time(GameState.current_day, TimeSystem.get_current_slot_name())
	hud.set_location(GameState.current_location)
	hud.set_affection_summary(AffectionSystem.get_affection_summary())
	hud.push_status("欢迎来到校园。先四处走走吧。")
	cg_gallery.refresh_gallery()
	save_load_menu.set_status(_get_save_hint())
	campus_map.refresh_points()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			cg_gallery.toggle_visible()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F5:
			SaveManager.save_to_slot(1)
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F9:
			SaveManager.load_from_slot(1)
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("ui_cancel"):
		save_load_menu.toggle_visible()
		get_viewport().set_input_as_handled()

func _on_request_interaction(point_id: String) -> void:
	if dialogue_panel.is_open() or cg_gallery.visible or save_load_menu.visible:
		return
	EventSystem.trigger_point(point_id)

func _on_choice_selected(event_id: String, choice_index: int) -> void:
	EventSystem.apply_choice(event_id, choice_index)
	_refresh_after_state_change()

func _on_time_changed(day: int, _slot_id: String, slot_name: String) -> void:
	hud.set_day_and_time(day, slot_name)
	campus_map.refresh_points()

func _on_system_message(message: String) -> void:
	hud.push_status(message)
	hud.set_affection_summary(AffectionSystem.get_affection_summary())
	save_load_menu.set_status(_get_save_hint())

func _on_gallery_refresh_requested() -> void:
	cg_gallery.refresh_gallery()
	hud.set_affection_summary(AffectionSystem.get_affection_summary())

func _on_save_completed(_success: bool, message: String) -> void:
	hud.push_status(message)
	save_load_menu.set_status(message)

func _on_load_completed(success: bool, message: String) -> void:
	hud.push_status(message)
	save_load_menu.set_status(message)
	if success:
		_refresh_after_state_change()

func _on_save_requested(slot_id: int) -> void:
	SaveManager.save_to_slot(slot_id)

func _on_load_requested(slot_id: int) -> void:
	SaveManager.load_from_slot(slot_id)

func _refresh_after_state_change() -> void:
	hud.set_day_and_time(GameState.current_day, TimeSystem.get_current_slot_name())
	hud.set_location(GameState.current_location)
	hud.set_affection_summary(AffectionSystem.get_affection_summary())
	cg_gallery.refresh_gallery()
	campus_map.apply_loaded_state()
	save_load_menu.set_status(_get_save_hint())

func _get_save_hint() -> String:
	if SaveManager.has_slot_save(1):
		return "槽位1：已有存档（Esc 打开面板）"
	return "槽位1：暂无存档（F5 可快速保存）"
