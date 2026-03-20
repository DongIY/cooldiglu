extends Node

signal time_changed(day: int, slot_id: String, slot_name: String)

const SLOT_ORDER := ["morning", "after_school", "night"]
const SLOT_NAMES := {
	"morning": "早晨",
	"after_school": "放学后",
	"night": "夜晚"
}

func _ready() -> void:
	sync_with_state()

func get_current_slot_name() -> String:
	return SLOT_NAMES.get(GameState.time_slot, GameState.time_slot)

func advance_time() -> void:
	var index := SLOT_ORDER.find(GameState.time_slot)
	if index == -1:
		index = 0
	index += 1
	if index >= SLOT_ORDER.size():
		index = 0
		GameState.set_day(GameState.current_day + 1)
	GameState.set_time_slot(SLOT_ORDER[index])
	time_changed.emit(GameState.current_day, GameState.time_slot, get_current_slot_name())

func sync_with_state() -> void:
	if SLOT_ORDER.find(GameState.time_slot) == -1:
		GameState.set_time_slot(SLOT_ORDER[0])
	time_changed.emit(GameState.current_day, GameState.time_slot, get_current_slot_name())
