extends Node

signal dialogue_requested(event_payload: Dictionary)
signal notification(message: String)
signal gallery_refresh_requested

const EVENTS_DATA_PATH := "res://data/events/events.json"

var events: Array = []
var events_by_key: Dictionary = {}
## Tracks how many times each event has been triggered today (for daily_limit).
var daily_trigger_counts: Dictionary = {}

func _ready() -> void:
	reload_data()

func reload_data() -> void:
	events.clear()
	events_by_key.clear()
	var file := FileAccess.open(EVENTS_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("events.json 尚未准备好。")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_ARRAY:
		push_warning("events.json 格式无效。")
		return
	for entry in parsed:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		events.append(entry)
		var key := _make_key(str(entry.get("point_id", "")), str(entry.get("time_slot", "")))
		if not events_by_key.has(key):
			events_by_key[key] = []
		events_by_key[key].append(entry)

## Call this when a new day starts to reset daily trigger counts.
func on_new_day() -> void:
	daily_trigger_counts.clear()

func has_available_event(point_id: String) -> bool:
	return not get_available_event(point_id).is_empty()

func get_available_event(point_id: String) -> Dictionary:
	var key := _make_key(point_id, GameState.time_slot)
	var bucket: Array = events_by_key.get(key, [])
	for entry in bucket:
		if _conditions_met(entry):
			return entry
	return {}

func trigger_point(point_id: String) -> bool:
	var event_payload := get_available_event(point_id)
	if event_payload.is_empty():
		notification.emit("现在这里没有新的事情发生。")
		return false
	# Track daily trigger count for this event
	var evt_id := str(event_payload.get("id", ""))
	daily_trigger_counts[evt_id] = daily_trigger_counts.get(evt_id, 0) + 1
	dialogue_requested.emit(event_payload)
	return true

func apply_choice(event_id: String, choice_index: int) -> void:
	var event_payload := _find_event_by_id(event_id)
	if event_payload.is_empty():
		notification.emit("事件引用丢失：%s" % event_id)
		return
	var choices: Array = event_payload.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		notification.emit("无效的选项索引。")
		return
	var choice: Dictionary = choices[choice_index]
	var affection_delta: Dictionary = choice.get("affection_delta", {})
	for character_id in affection_delta.keys():
		AffectionSystem.change_affection(character_id, int(affection_delta[character_id]))
	for flag_name in choice.get("set_flags", []):
		GameState.set_flag(str(flag_name))
	if bool(choice.get("mark_visited", true)):
		GameState.mark_event_visited(event_id)
	var cg_id := str(choice.get("unlock_cg", ""))
	if not cg_id.is_empty():
		GameState.unlock_cg(cg_id)
		gallery_refresh_requested.emit()
	var result_text := str(choice.get("result_text", ""))
	if not result_text.is_empty():
		notification.emit(result_text)
	if bool(choice.get("advance_time", false)):
		TimeSystem.advance_time()

func _make_key(point_id: String, time_slot: String) -> String:
	return "%s|%s" % [point_id, time_slot]

func _conditions_met(event_payload: Dictionary) -> bool:
	var conditions: Dictionary = event_payload.get("conditions", {})
	var event_id := str(event_payload.get("id", ""))

	# --- once: if event can only be triggered once and already visited ---
	if bool(conditions.get("once", false)) and GameState.was_event_visited(event_id):
		return false

	# --- daily_limit: max triggers per day (for repeatable daily events) ---
	var daily_limit: int = int(conditions.get("daily_limit", 0))
	if daily_limit > 0:
		var current_count: int = daily_trigger_counts.get(event_id, 0)
		if current_count >= daily_limit:
			return false

	# --- trigger_chance: random probability gate ---
	var trigger_chance: float = float(conditions.get("trigger_chance", 0.0))
	if trigger_chance > 0.0 and trigger_chance < 1.0:
		if randf() > trigger_chance:
			return false

	# --- day_range: event only available within [min_day, max_day] ---
	var day_range: Array = event_payload.get("day_range", [])
	if day_range.size() >= 2:
		var current_day: int = GameState.current_day
		if current_day < int(day_range[0]) or current_day > int(day_range[1]):
			return false

	# --- required_flags: all listed flags must be set ---
	for flag_name in conditions.get("required_flags", []):
		if not GameState.has_flag(str(flag_name)):
			return false

	# --- blocked_flags: none of these flags may be set ---
	for flag_name in conditions.get("blocked_flags", []):
		if GameState.has_flag(str(flag_name)):
			return false

	# --- flag_any: at least one of these flags must be set ---
	var flag_any: Array = conditions.get("flag_any", [])
	if not flag_any.is_empty():
		var any_met := false
		for flag_name in flag_any:
			if GameState.has_flag(str(flag_name)):
				any_met = true
				break
		if not any_met:
			return false

	# --- affection_at_least: character affection must be >= threshold ---
	var affection_requirements: Dictionary = conditions.get("affection_at_least", {})
	for character_id in affection_requirements.keys():
		if AffectionSystem.get_affection(character_id) < int(affection_requirements[character_id]):
			return false

	# --- affection_below: character affection must be < threshold ---
	var affection_below: Dictionary = conditions.get("affection_below", {})
	for character_id in affection_below.keys():
		if AffectionSystem.get_affection(character_id) >= int(affection_below[character_id]):
			return false

	return true

func _find_event_by_id(event_id: String) -> Dictionary:
	for entry in events:
		if str(entry.get("id", "")) == event_id:
			return entry
	return {}
