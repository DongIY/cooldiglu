extends Control

@onready var day_label: Label = $TopBar/DayLabel
@onready var location_label: Label = $TopBar/LocationLabel
@onready var affection_label: Label = $TopBar/AffectionLabel
@onready var prompt_label: Label = $BottomBar/PromptLabel
@onready var status_label: Label = $BottomBar/StatusLabel

func set_day_and_time(day: int, slot_name: String) -> void:
	day_label.text = "Day %d · %s" % [day, slot_name]

func set_location(location_name: String) -> void:
	location_label.text = "地点：%s" % location_name

func set_affection_summary(summary: String) -> void:
	affection_label.text = "关系：%s" % summary

func set_interaction_prompt(prompt_text: String) -> void:
	prompt_label.text = prompt_text

func push_status(message: String) -> void:
	status_label.text = message
