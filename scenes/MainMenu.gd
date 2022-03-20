extends Control


onready var gamebtn = $VBoxContainer/GameBtn
onready var quitbtn = $VBoxContainer/QuitBtn
onready var geobtn = $VBoxContainer/GeoBtn
onready var histbtn = $VBoxContainer/HistoryBtn
onready var musicbtn = $music

func _ready():
	gamebtn.grab_focus()
	musicbtn.pressed = not Global.music_muted
	Global.next_level = null
	Global.music_player.stop()
	Global.play_music(-1)
	Global.came_from_menu = true

func _on_GameBtn_pressed():
	Global.menu_button()
	return get_tree().change_scene("res://scenes/Level.tscn")

func _on_GeoBtn_pressed():
	Global.menu_button()
	return get_tree().change_scene("res://scenes/GeoLevel.tscn")

func _on_HistoryBtn_pressed():
	Global.menu_button()
	return get_tree().change_scene("res://scenes/HistLevel.tscn")

func _on_PokeBtn_pressed():
	Global.menu_button()
	return get_tree().change_scene("res://scenes/PokeLevel.tscn")

func _on_QuitBtn_pressed():
	Global.menu_button()
	if OS.get_name() == "HTML5":
		JavaScript.eval("confirm('Close this tab?') && window.close();")
		return
	get_tree().quit()


func _on_music_toggled(button_pressed:bool):
	Global.music_muted = not button_pressed
	if button_pressed:
		Global.play_music(-1)
	else:
		Global.music_player.stop()
