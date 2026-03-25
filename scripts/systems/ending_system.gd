extends Node

## Ending System — 在 Day 28 结束时自动判定并触发结局事件。
## 本脚本不作为 Autoload，由 main.gd 实例化并管理。

signal ending_triggered(ending_event_id: String, ending_type: String, character_id: String)

const MAX_DAY := 28

## 结局判定优先级规则：
## 1. 真心结局（True Ending）: 好感 ≥ 15 + 所有关键 flag
## 2. 温暖结局（Warm Ending）: 好感 ≥ 8 但不满足 TE 条件
## 3. 遗憾结局（Miss Ending）: 好感 < 8
## 4. 优先判定好感最高的角色路线

## Ending event ID mapping
const ENDINGS := {
	"lin": {
		"true": "evt_lin_ch5_good",
		"normal": "evt_lin_ch5_normal",
		"miss": "evt_lin_ch5_miss"
	},
	"yuki": {
		"true": "evt_yuki_ch5_good",
		"normal": "evt_yuki_ch5_normal",
		"miss": "evt_yuki_ch5_miss"
	}
}

## True ending required flags for each character
## These must match the actual set_flags values in events.json
const TRUE_ENDING_FLAGS := {
	"lin": ["lin_ch1_helped", "lin_ch2_carry", "lin_ch3_promise", "lin_ch3_waited", "lin_ch4_trust", "lin_ch4_confession"],
	"yuki": ["yuki_ch1_posed", "yuki_ch1_darkroom", "yuki_ch2_joined", "yuki_ch2_smile", "yuki_ch3_stayed", "yuki_ch4_developed"]
}

const TRUE_ENDING_AFFECTION := 15
const NORMAL_ENDING_AFFECTION := 8

## Check if it's time to trigger endings. Call this after each time advance.
func check_ending(day: int, time_slot: String) -> void:
	# Ending triggers at the end of Day 28 night (when trying to advance past it)
	if day < MAX_DAY:
		return
	if day == MAX_DAY and time_slot == "night":
		# We're on the last night — trigger ending
		_determine_and_trigger_ending()

func _determine_and_trigger_ending() -> void:
	var lin_aff: int = AffectionSystem.get_affection("lin")
	var yuki_aff: int = AffectionSystem.get_affection("yuki")

	# Determine which character route to resolve (highest affection first)
	var primary_char: String = ""
	var primary_aff: int = 0

	if lin_aff >= yuki_aff:
		primary_char = "lin"
		primary_aff = lin_aff
	else:
		primary_char = "yuki"
		primary_aff = yuki_aff

	# If both are 0, default to lin route miss ending
	if primary_aff == 0:
		primary_char = "lin"

	var ending_type := _classify_ending(primary_char, primary_aff)
	var ending_event_id: String = ENDINGS[primary_char][ending_type]

	# Skip if already visited (player already reached ending via manual exploration)
	if GameState.was_event_visited(ending_event_id):
		return

	ending_triggered.emit(ending_event_id, ending_type, primary_char)

func _classify_ending(character_id: String, affection: int) -> String:
	if affection >= TRUE_ENDING_AFFECTION:
		# Check if all required flags are set
		var required_flags: Array = TRUE_ENDING_FLAGS.get(character_id, [])
		var all_flags_met := true
		for flag_name in required_flags:
			if not GameState.has_flag(str(flag_name)):
				all_flags_met = false
				break
		if all_flags_met:
			return "true"
		else:
			return "normal"
	elif affection >= NORMAL_ENDING_AFFECTION:
		return "normal"
	else:
		return "miss"

## Get a human-readable ending title.
func get_ending_title(ending_type: String, character_id: String) -> String:
	var char_name: String = AffectionSystem.get_character_name(character_id)
	match ending_type:
		"true":
			return "%s · 真心结局" % char_name
		"normal":
			return "%s · 温暖结局" % char_name
		"miss":
			return "%s · 遗憾结局" % char_name
		_:
			return "未知结局"
