extends Node

## Audio Manager — 全局音频管理，支持 BGM 和 UI 音效。
## 注册为 Autoload，所有场景可通过 AudioManager 访问。

const BGM_DIR := "res://assets/audio/bgm/"
const SFX_DIR := "res://assets/audio/sfx/"

## BGM player (persistent, loops)
var bgm_player: AudioStreamPlayer = null
## SFX player (one-shot)
var sfx_player: AudioStreamPlayer = null

## Current BGM track ID (for avoiding re-play of same track)
var current_bgm_id: String = ""

## Master volume settings (linear, 0.0–1.0)
var bgm_volume: float = 0.8
var sfx_volume: float = 1.0
var master_mute: bool = false

func _ready() -> void:
	# Create BGM player
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	bgm_player.bus = "Master"
	add_child(bgm_player)

	# Create SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "Master"
	add_child(sfx_player)

	_apply_volumes()

## Play a BGM track by ID. If the same track is already playing, do nothing.
## BGM files should be at: res://assets/audio/bgm/{track_id}.ogg (or .mp3/.wav)
func play_bgm(track_id: String) -> void:
	if master_mute:
		return
	if track_id == current_bgm_id and bgm_player.playing:
		return

	var path := _find_audio_file(BGM_DIR, track_id)
	if path.is_empty():
		push_warning("BGM 文件未找到: %s" % track_id)
		return

	current_bgm_id = track_id
	var stream = load(path)
	if stream == null:
		push_warning("无法加载 BGM: %s" % path)
		return
	bgm_player.stream = stream
	bgm_player.play()

## Stop BGM playback.
func stop_bgm() -> void:
	bgm_player.stop()
	current_bgm_id = ""

## Play a one-shot SFX by ID.
## SFX files should be at: res://assets/audio/sfx/{sfx_id}.ogg (or .mp3/.wav)
func play_sfx(sfx_id: String) -> void:
	if master_mute:
		return

	var path := _find_audio_file(SFX_DIR, sfx_id)
	if path.is_empty():
		# Silently skip missing SFX (placeholder mode)
		return

	var stream = load(path)
	if stream == null:
		return
	sfx_player.stream = stream
	sfx_player.play()

## Set BGM volume (0.0 – 1.0).
func set_bgm_volume(vol: float) -> void:
	bgm_volume = clampf(vol, 0.0, 1.0)
	_apply_volumes()

## Set SFX volume (0.0 – 1.0).
func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)
	_apply_volumes()

## Toggle global mute.
func toggle_mute() -> void:
	master_mute = not master_mute
	if master_mute:
		bgm_player.stop()
	_apply_volumes()

func _apply_volumes() -> void:
	if bgm_player:
		bgm_player.volume_db = linear_to_db(bgm_volume if not master_mute else 0.0)
	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_volume if not master_mute else 0.0)

## Look for an audio file with common extensions.
func _find_audio_file(directory: String, file_id: String) -> String:
	for ext in ["ogg", "mp3", "wav"]:
		var path := "%s%s.%s" % [directory, file_id, ext]
		if ResourceLoader.exists(path):
			return path
	return ""

## Play a contextual BGM based on time of day.
func play_time_bgm(time_slot: String) -> void:
	match time_slot:
		"morning":
			play_bgm("morning_campus")
		"after_school":
			play_bgm("afternoon_breeze")
		"night":
			play_bgm("night_quiet")
		_:
			play_bgm("morning_campus")

## Play title screen BGM.
func play_title_bgm() -> void:
	play_bgm("title_theme")
