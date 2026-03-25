extends Node

@onready var campus_map = $CampusMap
@onready var hud = $UI/HUD
@onready var dialogue_panel = $UI/DialoguePanel
@onready var cg_gallery = $UI/CGGallery
@onready var save_load_menu = $UI/SaveLoadMenu
@onready var title_screen = $UI/TitleScreen

## Ending system (instantiated at runtime, not Autoload).
var ending_system: Node = null
## Whether the game has started (past title screen).
var game_started := false

func _ready() -> void:
	# Initialize ending system
	var ending_script = load("res://scripts/systems/ending_system.gd")
	ending_system = Node.new()
	ending_system.set_script(ending_script)
	ending_system.name = "EndingSystem"
	add_child(ending_system)
	ending_system.ending_triggered.connect(_on_ending_triggered)

	# Connect all signals
	EventSystem.dialogue_requested.connect(dialogue_panel.present_event)
	dialogue_panel.choice_selected.connect(_on_choice_selected)
	dialogue_panel.dialogue_finished.connect(_on_dialogue_finished)
	EventSystem.notification.connect(_on_system_message)
	EventSystem.gallery_refresh_requested.connect(_on_gallery_refresh_requested)
	TimeSystem.time_changed.connect(_on_time_changed)
	TimeSystem.day_changed.connect(_on_day_changed)
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.load_completed.connect(_on_load_completed)
	campus_map.request_interaction.connect(_on_request_interaction)
	campus_map.interaction_prompt_changed.connect(hud.set_interaction_prompt)
	campus_map.location_changed.connect(hud.set_location)
	save_load_menu.save_requested.connect(_on_save_requested)
	save_load_menu.load_requested.connect(_on_load_requested)

	# Title screen signals
	title_screen.start_new_game.connect(_on_start_new_game)
	title_screen.continue_game.connect(_on_continue_game)
	title_screen.open_gallery.connect(_on_title_gallery)
	title_screen.quit_game.connect(_on_quit_game)

	# Start in title screen mode — hide gameplay elements
	_show_title_screen()

# ---------- Title Screen ----------

func _show_title_screen() -> void:
	game_started = false
	title_screen.show()
	campus_map.hide()
	hud.hide()
	dialogue_panel.hide()
	cg_gallery.hide()
	save_load_menu.hide()

func _enter_gameplay() -> void:
	game_started = true
	title_screen.hide()
	campus_map.show()
	hud.show()
	hud.set_day_and_time(GameState.current_day, TimeSystem.get_current_slot_name())
	hud.set_location(GameState.current_location)
	hud.set_affection_summary(AffectionSystem.get_affection_summary())
	hud.push_status("欢迎来到校园。先四处走走吧。")
	cg_gallery.refresh_gallery()
	save_load_menu.set_status(_get_save_hint())
	campus_map.refresh_points()

func _on_start_new_game() -> void:
	GameState.reset_state()
	AffectionSystem.reload_characters()
	EventSystem.reload_data()
	EventSystem.on_new_day()
	_enter_gameplay()

func _on_continue_game() -> void:
	SaveManager.load_from_slot(1)
	_enter_gameplay()

func _on_title_gallery() -> void:
	title_screen.hide()
	cg_gallery.show()
	cg_gallery.refresh_gallery()

func _on_quit_game() -> void:
	get_tree().quit()

# ---------- Input ----------

func _input(event: InputEvent) -> void:
	if not game_started:
		# Allow Esc from gallery back to title
		if event.is_action_pressed("ui_cancel") and cg_gallery.visible:
			cg_gallery.hide()
			title_screen.show()
			get_viewport().set_input_as_handled()
		return

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

# ---------- Gameplay callbacks ----------

func _on_request_interaction(point_id: String) -> void:
	if dialogue_panel.is_open() or cg_gallery.visible or save_load_menu.visible:
		return
	EventSystem.trigger_point(point_id)

func _on_choice_selected(event_id: String, choice_index: int) -> void:
	EventSystem.apply_choice(event_id, choice_index)
	_refresh_after_state_change()

## Called when a no-choice dialogue finishes (e.g. daily events, result-only events).
func _on_dialogue_finished(event_id: String) -> void:
	var event_payload := EventSystem._find_event_by_id(event_id)
	if not event_payload.is_empty():
		GameState.mark_event_visited(event_id)
		if bool(event_payload.get("advance_time_on_view", false)):
			TimeSystem.advance_time()
	_refresh_after_state_change()

func _on_time_changed(day: int, _slot_id: String, slot_name: String) -> void:
	hud.set_day_and_time(day, slot_name)
	campus_map.refresh_points()
	# Check for ending condition after each time advance
	if ending_system:
		ending_system.check_ending(day, GameState.time_slot)

func _on_day_changed(new_day: int) -> void:
	hud.push_status("新的一天开始了 — Day %d" % new_day)

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

## Called by EndingSystem when an ending should be triggered.
func _on_ending_triggered(ending_event_id: String, ending_type: String, character_id: String) -> void:
	var ending_title := ending_system.get_ending_title(ending_type, character_id)
	hud.push_status(">>> %s <<<" % ending_title)
	# Trigger the ending event through EventSystem
	var event_payload := EventSystem._find_event_by_id(ending_event_id)
	if not event_payload.is_empty():
		dialogue_panel.present_event(event_payload)
	else:
		hud.push_status("结局事件数据缺失：%s" % ending_event_id)
