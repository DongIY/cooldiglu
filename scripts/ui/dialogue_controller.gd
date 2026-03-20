extends PanelContainer

signal choice_selected(event_id: String, choice_index: int)

@onready var speaker_label: Label = $MarginContainer/VBoxContainer/SpeakerLabel
@onready var body_label: RichTextLabel = $MarginContainer/VBoxContainer/BodyLabel
@onready var choices_container: VBoxContainer = $MarginContainer/VBoxContainer/ChoicesContainer

var current_event_id := ""

func _ready() -> void:
	hide()

func is_open() -> bool:
	return visible

func present_event(event_payload: Dictionary) -> void:
	current_event_id = str(event_payload.get("id", ""))
	speaker_label.text = str(event_payload.get("speaker", "旁白"))
	body_label.text = str(event_payload.get("text", ""))
	for child in choices_container.get_children():
		child.queue_free()
	var choices: Array = event_payload.get("choices", [])
	for index in range(choices.size()):
		var choice: Dictionary = choices[index]
		var button := Button.new()
		button.text = str(choice.get("text", "继续"))
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_choice_pressed.bind(index))
		choices_container.add_child(button)
	show()

func _on_choice_pressed(choice_index: int) -> void:
	hide()
	choice_selected.emit(current_event_id, choice_index)
