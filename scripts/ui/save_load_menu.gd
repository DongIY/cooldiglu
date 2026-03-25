extends PanelContainer

signal save_requested(slot_id: int)
signal load_requested(slot_id: int)

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var slots_container: VBoxContainer = $MarginContainer/VBoxContainer/SlotsContainer
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	close_button.pressed.connect(hide)
	hide()

func toggle_visible() -> void:
	if visible:
		hide()
	else:
		_refresh_slots()
		show()

func set_status(message: String) -> void:
	title_label.text = message

func _refresh_slots() -> void:
	# Clear previous slot UI
	for child in slots_container.get_children():
		child.queue_free()

	# Build slot entries
	for slot_id in range(1, SaveManager.MAX_SLOTS + 1):
		var slot_row := HBoxContainer.new()
		slot_row.add_theme_constant_override("separation", 8)

		var info_label := Label.new()
		info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var slot_info := SaveManager.get_slot_info(slot_id)
		if slot_info.is_empty():
			info_label.text = "槽位 %d — 空" % slot_id
		else:
			var time_names := {"morning": "早晨", "after_school": "放学后", "night": "夜晚"}
			var slot_name: String = time_names.get(str(slot_info.get("time_slot", "")), str(slot_info.get("time_slot", "")))
			info_label.text = "槽位 %d — Day %d · %s  [%s]" % [
				slot_id,
				int(slot_info.get("day", 1)),
				slot_name,
				str(slot_info.get("saved_at", ""))
			]

		var save_btn := Button.new()
		save_btn.text = "保存"
		save_btn.custom_minimum_size = Vector2(60, 0)
		save_btn.pressed.connect(_on_save_slot.bind(slot_id))

		var load_btn := Button.new()
		load_btn.text = "读取"
		load_btn.custom_minimum_size = Vector2(60, 0)
		load_btn.disabled = slot_info.is_empty()
		load_btn.pressed.connect(_on_load_slot.bind(slot_id))

		slot_row.add_child(info_label)
		slot_row.add_child(save_btn)
		slot_row.add_child(load_btn)
		slots_container.add_child(slot_row)

func _on_save_slot(slot_id: int) -> void:
	save_requested.emit(slot_id)
	# Refresh after a short delay so the file is written
	await get_tree().create_timer(0.1).timeout
	_refresh_slots()

func _on_load_slot(slot_id: int) -> void:
	load_requested.emit(slot_id)
	hide()
