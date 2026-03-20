extends Node

signal affection_changed(character_id: String, new_value: int, delta: int)

const CHARACTER_DATA_PATH := "res://data/characters/characters.json"

var character_defs: Dictionary = {}
var affection_map: Dictionary = {}

func _ready() -> void:
	reload_characters()

func reload_characters() -> void:
	character_defs.clear()
	var file := FileAccess.open(CHARACTER_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("characters.json 尚未准备好。")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_ARRAY:
		push_warning("characters.json 格式无效。")
		return
	for entry in parsed:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var character_id := str(entry.get("id", ""))
		if character_id.is_empty():
			continue
		character_defs[character_id] = entry
		if not affection_map.has(character_id):
			affection_map[character_id] = int(entry.get("initial_affection", 0))
	var stale_ids: Array = []
	for existing_id in affection_map.keys():
		if not character_defs.has(existing_id):
			stale_ids.append(existing_id)
	for stale_id in stale_ids:
		affection_map.erase(stale_id)

func get_character_name(character_id: String) -> String:
	var info: Dictionary = character_defs.get(character_id, {})
	return str(info.get("name", character_id))

func get_affection(character_id: String) -> int:
	return int(affection_map.get(character_id, 0))

func change_affection(character_id: String, delta: int) -> void:
	var next_value: int = int(max(0, get_affection(character_id) + delta))
	affection_map[character_id] = next_value
	affection_changed.emit(character_id, next_value, delta)

func get_affection_summary() -> String:
	var parts: Array[String] = []
	for character_id in character_defs.keys():
		parts.append("%s %d" % [get_character_name(character_id), get_affection(character_id)])
	return " / ".join(parts)

func to_dict() -> Dictionary:
	return affection_map.duplicate(true)

func load_from_dict(data: Dictionary) -> void:
	affection_map = data.duplicate(true)
	reload_characters()
	for character_id in character_defs.keys():
		if not affection_map.has(character_id):
			affection_map[character_id] = int(character_defs[character_id].get("initial_affection", 0))
