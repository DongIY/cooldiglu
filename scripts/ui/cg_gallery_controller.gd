extends PanelContainer

const GALLERY_DATA_PATH := "res://data/cg/cg_gallery.json"

@onready var counter_label: Label = $MarginContainer/VBoxContainer/CounterLabel
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var preview_rect: ColorRect = $MarginContainer/VBoxContainer/PreviewRect
@onready var preview_label: Label = $MarginContainer/VBoxContainer/PreviewRect/PreviewLabel
@onready var description_label: RichTextLabel = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var prev_button: Button = $MarginContainer/VBoxContainer/Buttons/PrevButton
@onready var next_button: Button = $MarginContainer/VBoxContainer/Buttons/NextButton
@onready var close_button: Button = $MarginContainer/VBoxContainer/Buttons/CloseButton

var gallery_entries: Array = []
var current_index := 0

func _ready() -> void:
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	close_button.pressed.connect(hide)
	hide()
	refresh_gallery()

func toggle_visible() -> void:
	visible = not visible
	if visible:
		refresh_gallery()

func refresh_gallery() -> void:
	gallery_entries = _load_entries()
	if gallery_entries.is_empty():
		current_index = 0
	else:
		current_index = clamp(current_index, 0, gallery_entries.size() - 1)
	_render_current()

func _load_entries() -> Array:
	var file := FileAccess.open(GALLERY_DATA_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_ARRAY:
		return []
	return parsed

func _render_current() -> void:
	if gallery_entries.is_empty():
		counter_label.text = "0 / 0"
		title_label.text = "暂无回忆图鉴"
		preview_rect.color = Color("#3c4460")
		preview_label.text = "NO DATA"
		description_label.text = "等配置好图鉴数据后，这里会显示可解锁回忆。"
		prev_button.disabled = true
		next_button.disabled = true
		return
	var entry: Dictionary = gallery_entries[current_index]
	var cg_id := str(entry.get("id", ""))
	var unlocked := GameState.is_cg_unlocked(cg_id)
	counter_label.text = "%d / %d" % [current_index + 1, gallery_entries.size()]
	title_label.text = str(entry.get("title", "未命名回忆")) if unlocked else "未解锁回忆"
	preview_rect.color = Color("#ffd9e8") if unlocked else Color("#3c4460")
	preview_label.text = "MEMORY\n%s" % cg_id if unlocked else "LOCKED"
	description_label.text = str(entry.get("description", "")) if unlocked else str(entry.get("locked_hint", "继续提升关系以解锁。"))
	prev_button.disabled = gallery_entries.size() <= 1
	next_button.disabled = gallery_entries.size() <= 1

func _on_prev_pressed() -> void:
	if gallery_entries.is_empty():
		return
	current_index = wrapi(current_index - 1, 0, gallery_entries.size())
	_render_current()

func _on_next_pressed() -> void:
	if gallery_entries.is_empty():
		return
	current_index = wrapi(current_index + 1, 0, gallery_entries.size())
	_render_current()
