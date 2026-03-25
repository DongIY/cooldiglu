extends Node

signal save_completed(success: bool, message: String)
signal load_completed(success: bool, message: String)

const SAVE_DIR := "user://saves"
const MAX_SLOTS := 3

func _ready() -> void:
	_ensure_save_dir()

func _ensure_save_dir() -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	if not dir.dir_exists("saves"):
		dir.make_dir_recursive("saves")

func get_slot_path(slot_id: int = 1) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot_id]

func has_slot_save(slot_id: int = 1) -> bool:
	return FileAccess.file_exists(get_slot_path(slot_id))

## Get metadata about a save slot without fully loading it.
func get_slot_info(slot_id: int) -> Dictionary:
	var path := get_slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var meta: Dictionary = parsed.get("meta", {})
	var gs: Dictionary = parsed.get("game_state", {})
	return {
		"day": int(gs.get("current_day", 1)),
		"time_slot": str(gs.get("time_slot", "morning")),
		"location": str(gs.get("current_location", "")),
		"saved_at": str(meta.get("saved_at", "未知")),
	}

func save_to_slot(slot_id: int = 1) -> void:
	_ensure_save_dir()
	var now := Time.get_datetime_dict_from_system()
	var timestamp := "%04d-%02d-%02d %02d:%02d" % [now["year"], now["month"], now["day"], now["hour"], now["minute"]]
	var payload := {
		"meta": {
			"saved_at": timestamp,
			"version": "0.3",
		},
		"game_state": GameState.to_dict(),
		"affection": AffectionSystem.to_dict()
	}
	var file := FileAccess.open(get_slot_path(slot_id), FileAccess.WRITE)
	if file == null:
		save_completed.emit(false, "存档失败：无法打开存档文件。")
		return
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	save_completed.emit(true, "已保存到槽位 %d。(%s)" % [slot_id, timestamp])

func load_from_slot(slot_id: int = 1) -> void:
	var path := get_slot_path(slot_id)
	if not FileAccess.file_exists(path):
		load_completed.emit(false, "槽位 %d 还没有存档。" % slot_id)
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		load_completed.emit(false, "读档失败：无法打开存档文件。")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		load_completed.emit(false, "读档失败：存档格式无效。")
		return
	GameState.load_from_dict(parsed.get("game_state", {}))
	AffectionSystem.load_from_dict(parsed.get("affection", {}))
	TimeSystem.sync_with_state()
	EventSystem.reload_data()
	load_completed.emit(true, "已读取槽位 %d。" % slot_id)

## Check if any save exists across all slots.
func has_any_save() -> bool:
	for i in range(1, MAX_SLOTS + 1):
		if has_slot_save(i):
			return true
	return false
