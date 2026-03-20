extends Node

signal dialogue_requested(event_payload: Dictionary)
signal notification(message: String)
signal gallery_refresh_requested

const EVENTS_DATA_PATH := "res://data/events/events.json"

var events: Array = []
var events_by_key: Dictionary = {}

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
	if bool(conditions.get("once", false)) and GameState.was_event_visited(str(event_payload.get("id", ""))):
		return false
	for flag_name in conditions.get("required_flags", []):
		if not GameState.has_flag(str(flag_name)):
			return false
	for flag_name in conditions.get("blocked_flags", []):
		if GameState.has_flag(str(flag_name)):
			return false
	var affection_requirements: Dictionary = conditions.get("affection_at_least", {})
	for character_id in affection_requirements.keys():
		if AffectionSystem.get_affection(character_id) < int(affection_requirements[character_id]):
			return false
	return true

func _find_event_by_id(event_id: String) -> Dictionary:
	for entry in events:
		if str(entry.get("id", "")) == event_id:
			return entry
	return {}
