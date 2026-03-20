extends PanelContainer

signal save_requested(slot_id: int)
signal load_requested(slot_id: int)

@onready var info_label: Label = $MarginContainer/VBoxContainer/InfoLabel
@onready var save_button: Button = $MarginContainer/VBoxContainer/Buttons/SaveButton
@onready var load_button: Button = $MarginContainer/VBoxContainer/Buttons/LoadButton
@onready var close_button: Button = $MarginContainer/VBoxContainer/Buttons/CloseButton

func _ready() -> void:
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	close_button.pressed.connect(hide)
	hide()

func toggle_visible() -> void:
	visible = not visible

func set_status(message: String) -> void:
	info_label.text = message

func _on_save_pressed() -> void:
	save_requested.emit(1)

func _on_load_pressed() -> void:
	load_requested.emit(1)
