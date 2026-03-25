extends Control

## Title screen controller.
## Displayed on launch before entering the campus map.

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var button_container: VBoxContainer = $VBoxContainer/ButtonContainer
@onready var new_game_button: Button = $VBoxContainer/ButtonContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ButtonContainer/ContinueButton
@onready var gallery_button: Button = $VBoxContainer/ButtonContainer/GalleryButton
@onready var quit_button: Button = $VBoxContainer/ButtonContainer/QuitButton

signal start_new_game
signal continue_game
signal open_gallery
signal quit_game

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game)
	continue_button.pressed.connect(_on_continue)
	gallery_button.pressed.connect(_on_gallery)
	quit_button.pressed.connect(_on_quit)
	# Hide continue button if no save exists
	continue_button.visible = SaveManager.has_any_save()

func _on_new_game() -> void:
	start_new_game.emit()

func _on_continue() -> void:
	continue_game.emit()

func _on_gallery() -> void:
	open_gallery.emit()

func _on_quit() -> void:
	quit_game.emit()
