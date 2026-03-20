extends Node

signal state_changed

const DEFAULT_DAY := 1
const DEFAULT_SLOT := "morning"
const DEFAULT_LOCATION := "校门"

var current_day: int = DEFAULT_DAY
var time_slot: String = DEFAULT_SLOT
var current_location: String = DEFAULT_LOCATION
var story_flags: Dictionary = {}
var unlocked_cg: Array = []
var visited_events: Array = []

func reset_state() -> void:
	current_day = DEFAULT_DAY
	time_slot = DEFAULT_SLOT
	current_location = DEFAULT_LOCATION
	story_flags.clear()
	unlocked_cg.clear()
	visited_events.clear()
	state_changed.emit()

func set_location(location_name: String) -> void:
	current_location = location_name
	state_changed.emit()

func set_time_slot(slot_id: String) -> void:
	time_slot = slot_id
	state_changed.emit()

func set_day(day: int) -> void:
	current_day = int(max(day, 1))
	state_changed.emit()

func set_flag(flag_name: String, value: bool = true) -> void:
	story_flags[flag_name] = value
	state_changed.emit()

func has_flag(flag_name: String) -> bool:
	return bool(story_flags.get(flag_name, false))

func mark_event_visited(event_id: String) -> void:
	if event_id in visited_events:
		return
	visited_events.append(event_id)
	state_changed.emit()

func was_event_visited(event_id: String) -> bool:
	return event_id in visited_events

func unlock_cg(cg_id: String) -> void:
	if cg_id.is_empty() or cg_id in unlocked_cg:
		return
	unlocked_cg.append(cg_id)
	state_changed.emit()

func is_cg_unlocked(cg_id: String) -> bool:
	return cg_id in unlocked_cg

func to_dict() -> Dictionary:
	return {
		"current_day": current_day,
		"time_slot": time_slot,
		"current_location": current_location,
		"story_flags": story_flags.duplicate(true),
		"unlocked_cg": unlocked_cg.duplicate(),
		"visited_events": visited_events.duplicate()
	}

func load_from_dict(data: Dictionary) -> void:
	current_day = int(data.get("current_day", DEFAULT_DAY))
	time_slot = str(data.get("time_slot", DEFAULT_SLOT))
	current_location = str(data.get("current_location", DEFAULT_LOCATION))
	story_flags = data.get("story_flags", {}).duplicate(true)
	unlocked_cg = Array(data.get("unlocked_cg", []))
	visited_events = Array(data.get("visited_events", []))
	state_changed.emit()
