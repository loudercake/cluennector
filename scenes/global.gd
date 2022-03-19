extends Node

var next_level = null
var next_cc = null

var music_player = AudioStreamPlayer.new()


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
]

func _ready():
	add_child(music_player)

func play_music(m):
	music_player.stop()
	music_player.stream = music_list[m]
	music_player.play()

func play_music_once(m):
	play_music(m)
	music_player.connect("finished", self, "stop_music_player")

func stop_music_player():
	music_player.disconnect("finished", self, "stop_music_player")
	music_player.stop()

# Play audio effect
func play(m):
	var streamplayer = AudioStreamPlayer.new()
	streamplayer.connect("finished", streamplayer, "queue_free")
	add_child(streamplayer)
	streamplayer.stream = sfx_list[m]
	streamplayer.play()
