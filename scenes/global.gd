extends Node

var next_level = null
var next_cc = null

var music_player = AudioStreamPlayer.new()
var music_muted = false
var came_from_menu = true

var last_level_for_mode = {}
var current_scene_path = ""


# Let's preload the audio effects
var sfx_list = [
    preload("res://assets/sound/button.wav"),
    preload("res://assets/sound/back_to_menu.wav"),
    preload("res://assets/sound/win.wav"),
    preload("res://assets/sound/paper.wav"),
    preload("res://assets/sound/connect.wav"),
    preload("res://assets/sound/disconnect.wav"),
]

var music_list = [
    preload("res://assets/sound/win_game.ogg"),
    preload("res://assets/sound/detective.ogg"),
    preload("res://assets/sound/geography.ogg"),
    preload("res://assets/sound/geography.ogg"),
    preload("res://assets/sound/geography.ogg"),
    preload("res://assets/sound/menu-theme.ogg"),
]

func _ready():
	add_child(music_player)

func is_from_menu():
	var before = came_from_menu
	came_from_menu = false
	return before

func menu_button():
	music_player.playing = false
	music_player.stop()
	play(0)

func play_music(m):
	if music_muted:
		return
	music_player.stop()
	music_player.stream = music_list[m]
	music_player.play()

func play_music_once(m):
	if music_muted:
		return
	play_music(m)
	if not music_player.is_connected("finished", self, "stop_music_player"):
		music_player.connect("finished", self, "stop_music_player")

func stop_music_player():
	if music_player.is_connected("finished", self, "stop_music_player"):
		music_player.disconnect("finished", self, "stop_music_player")
	music_player.stop()

# Play audio effect
func play(m):
	var streamplayer = AudioStreamPlayer.new()
	streamplayer.connect("finished", streamplayer, "queue_free")
	add_child(streamplayer)
	streamplayer.stream = sfx_list[m]
	streamplayer.play()

func save_level():
	last_level_for_mode[current_scene_path] = next_level

func load_last_level(scene_path):
	current_scene_path = scene_path
	var level = last_level_for_mode.get(scene_path)
	next_level = level if level else null
	return next_level
