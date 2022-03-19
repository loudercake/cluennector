extends Control


onready var gamebtn = $VBoxContainer/GameBtn
onready var quitbtn = $VBoxContainer/QuitBtn
onready var geobtn = $VBoxContainer/GeoBtn
onready var histbtn = $VBoxContainer/HistoryBtn

func _ready():
	gamebtn.grab_focus()
	Global.next_level = null
	Global.music_player.stop()

func _on_GameBtn_pressed():
	Global.play(0)
	return get_tree().change_scene("res://scenes/Level.tscn")

func _on_GeoBtn_pressed():
	Global.play(0)
	return get_tree().change_scene("res://scenes/GeoLevel.tscn")

func _on_HistoryBtn_pressed():
	Global.play(0)
	return get_tree().change_scene("res://scenes/HistLevel.tscn")

func _on_PokeBtn_pressed():
	Global.play(0)
	return get_tree().change_scene("res://scenes/PokeLevel.tscn")

func _on_QuitBtn_pressed():
	Global.play(0)
	if OS.get_name() == "HTML5":
		JavaScript.eval("confirm('Close this tab?') && window.close();")
		return
	get_tree().quit()
