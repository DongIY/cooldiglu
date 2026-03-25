extends PanelContainer

signal choice_selected(event_id: String, choice_index: int)
signal dialogue_finished(event_id: String)

const DIALOGUES_DATA_PATH := "res://data/dialogues/dialogues.json"
const PORTRAITS_DIR := "res://assets/portraits/"
const TYPEWRITER_CHARS_PER_SEC := 30.0

@onready var portrait_rect: TextureRect = $HBoxContainer/PortraitRect
@onready var text_container: VBoxContainer = $HBoxContainer/TextContainer
@onready var speaker_label: Label = $HBoxContainer/TextContainer/SpeakerLabel
@onready var body_label: RichTextLabel = $HBoxContainer/TextContainer/BodyLabel
@onready var page_indicator: Label = $HBoxContainer/TextContainer/PageIndicator
@onready var choices_container: VBoxContainer = $HBoxContainer/TextContainer/ChoicesContainer
@onready var continue_hint: Label = $HBoxContainer/TextContainer/ContinueHint
@onready var typewriter_timer: Timer = $TypewriterTimer

## All dialogue data from dialogues.json, keyed by event_id.
var all_dialogues: Dictionary = {}

## Current presentation state.
var current_event_id := ""
var current_event_payload: Dictionary = {}
var current_pages: Array = []
var current_page_index: int = 0
var showing_choice_result: bool = false
var choice_result_pages: Array = []
var choice_result_index: int = 0

## Typewriter state.
var full_text: String = ""
var visible_chars: int = 0
var typewriter_active: bool = false

func _ready() -> void:
	hide()
	_load_dialogues()
	typewriter_timer.wait_time = 1.0 / TYPEWRITER_CHARS_PER_SEC
	typewriter_timer.timeout.connect(_on_typewriter_tick)
	continue_hint.hide()

func _load_dialogues() -> void:
	var file := FileAccess.open(DIALOGUES_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("dialogues.json 尚未准备好，将使用 events.json 内嵌文本。")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("dialogues.json 格式无效。")
		return
	all_dialogues = parsed

func is_open() -> bool:
	return visible

## Entry point: called by EventSystem.dialogue_requested signal.
func present_event(event_payload: Dictionary) -> void:
	current_event_payload = event_payload
	current_event_id = str(event_payload.get("id", ""))
	showing_choice_result = false
	choice_result_pages.clear()
	choice_result_index = 0

	# Try to load multi-page dialogue from dialogues.json
	var dialogue_data: Dictionary = all_dialogues.get(current_event_id, {})
	current_pages = dialogue_data.get("pages", [])

	if current_pages.is_empty():
		# Fallback: create a single page from event_payload inline text
		current_pages = [{
			"speaker": str(event_payload.get("speaker", "旁白")),
			"expression": "",
			"text": str(event_payload.get("text", ""))
		}]

	current_page_index = 0
	_clear_choices()
	_show_page(current_pages[current_page_index])
	show()

## Show a single dialogue page with typewriter effect.
func _show_page(page: Dictionary) -> void:
	var speaker_name: String = str(page.get("speaker", ""))
	var expression: String = str(page.get("expression", ""))
	var text: String = str(page.get("text", ""))

	# Speaker label
	if speaker_name.is_empty():
		speaker_label.text = "旁白"
	else:
		speaker_label.text = speaker_name

	# Portrait
	_update_portrait(speaker_name, expression)

	# Page indicator
	var total_pages: int = current_pages.size() if not showing_choice_result else choice_result_pages.size()
	var cur_idx: int = current_page_index if not showing_choice_result else choice_result_index
	if total_pages > 1:
		page_indicator.text = "%d / %d" % [cur_idx + 1, total_pages]
		page_indicator.show()
	else:
		page_indicator.hide()

	# Start typewriter
	full_text = text
	visible_chars = 0
	body_label.text = ""
	typewriter_active = true
	typewriter_timer.start()

	# Hide choices and continue hint during typing
	_clear_choices()
	continue_hint.hide()

func _update_portrait(speaker_name: String, expression: String) -> void:
	# Map speaker name to character ID for portrait lookup
	var char_id := _speaker_to_char_id(speaker_name)
	if char_id.is_empty():
		portrait_rect.texture = null
		portrait_rect.hide()
		return

	# Build portrait path: char_{id}_{expression}.svg or char_{id}_default.svg
	var expr_suffix := expression if not expression.is_empty() else "default"
	var portrait_path := PORTRAITS_DIR + "char_%s_%s.svg" % [char_id, expr_suffix]

	# Try expression-specific first, fallback to default
	if not ResourceLoader.exists(portrait_path):
		portrait_path = PORTRAITS_DIR + "char_%s_default.svg" % char_id

	if ResourceLoader.exists(portrait_path):
		portrait_rect.texture = load(portrait_path)
		portrait_rect.show()
	else:
		portrait_rect.texture = null
		portrait_rect.hide()

func _speaker_to_char_id(speaker_name: String) -> String:
	match speaker_name:
		"林澄": return "lin"
		"雪纪": return "yuki"
		"苏逸": return "suyi"
		"小唯": return "xiaowei"
		"周老师": return "zhou_laoshi"
		"陆辰": return ""  # Player, no portrait
		_: return ""

func _on_typewriter_tick() -> void:
	if not typewriter_active:
		typewriter_timer.stop()
		return
	visible_chars += 1
	if visible_chars >= full_text.length():
		body_label.text = full_text
		typewriter_active = false
		typewriter_timer.stop()
		_on_page_text_complete()
	else:
		body_label.text = full_text.substr(0, visible_chars)

func _finish_typewriter() -> void:
	typewriter_active = false
	typewriter_timer.stop()
	visible_chars = full_text.length()
	body_label.text = full_text
	_on_page_text_complete()

## Called when the page text finishes displaying.
func _on_page_text_complete() -> void:
	if showing_choice_result:
		# In choice result sequence
		if choice_result_index < choice_result_pages.size() - 1:
			continue_hint.text = "▼ 点击继续"
			continue_hint.show()
		else:
			# Choice result complete — finish dialogue
			continue_hint.text = "▼ 点击关闭"
			continue_hint.show()
	else:
		# In main page sequence
		if current_page_index < current_pages.size() - 1:
			# More pages
			continue_hint.text = "▼ 点击继续"
			continue_hint.show()
		else:
			# Last page — show choices or finish
			var choices: Array = current_event_payload.get("choices", [])
			if choices.size() > 0:
				_show_choices(choices)
			else:
				# No choices — auto-finish with click
				continue_hint.text = "▼ 点击关闭"
				continue_hint.show()

func _show_choices(choices: Array) -> void:
	_clear_choices()
	continue_hint.hide()
	for index in range(choices.size()):
		var choice: Dictionary = choices[index]
		var button := Button.new()
		button.text = str(choice.get("text", "继续"))
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_choice_pressed.bind(index))
		choices_container.add_child(button)

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_pressed(choice_index: int) -> void:
	_clear_choices()
	continue_hint.hide()
	_pending_choice_index = choice_index

	# Check if there are choice_result pages in dialogues.json
	var dialogue_data: Dictionary = all_dialogues.get(current_event_id, {})
	var choice_results: Dictionary = dialogue_data.get("choice_results", {})
	var result_key := str(choice_index)
	var result_pages: Array = choice_results.get(result_key, [])

	if not result_pages.is_empty():
		# Show choice result pages before emitting the signal
		showing_choice_result = true
		choice_result_pages = result_pages
		choice_result_index = 0
		_show_page(choice_result_pages[0])
	else:
		# No result pages, just emit and close
		hide()
		choice_selected.emit(current_event_id, choice_index)

## Handle user input for advancing pages.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if not (event is InputEventKey and event.pressed and not event.echo):
			return
		if event is InputEventKey:
			var key_event: InputEventKey = event
			if key_event.keycode != KEY_SPACE and key_event.keycode != KEY_ENTER and key_event.keycode != KEY_E:
				return

	# If typewriter is active, complete it instantly
	if typewriter_active:
		_finish_typewriter()
		get_viewport().set_input_as_handled()
		return

	# Advance to next page or close
	if showing_choice_result:
		if choice_result_index < choice_result_pages.size() - 1:
			choice_result_index += 1
			_show_page(choice_result_pages[choice_result_index])
		else:
			# Choice result finished — close and emit
			showing_choice_result = false
			hide()
			# Find which choice was selected by checking if we're in result pages
			# We need to store the choice index — let's extract it
			var choice_idx := _find_choice_index_from_results()
			choice_selected.emit(current_event_id, choice_idx)
		get_viewport().set_input_as_handled()
		return

	if current_page_index < current_pages.size() - 1:
		current_page_index += 1
		_show_page(current_pages[current_page_index])
		get_viewport().set_input_as_handled()
		return

	# At last page with no choices — close
	var choices: Array = current_event_payload.get("choices", [])
	if choices.is_empty():
		hide()
		dialogue_finished.emit(current_event_id)
		get_viewport().set_input_as_handled()

## Store the selected choice index when entering choice_result mode.
var _pending_choice_index: int = -1

func _find_choice_index_from_results() -> int:
	return _pending_choice_index
