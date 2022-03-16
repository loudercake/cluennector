extends Control


onready var gamebtn = $VBoxContainer/GameBtn
onready var quitbtn = $VBoxContainer/QuitBtn
onready var geobtn = $VBoxContainer/GeoBtn
onready var histbtn = $VBoxContainer/HistoryBtn

func _ready():
	gamebtn.grab_focus()
	Global.next_level = null

func _on_GameBtn_pressed():
	get_tree().change_scene("res://scenes/Level.tscn")

func _on_GeoBtn_pressed():
	get_tree().change_scene("res://scenes/GeoLevel.tscn")

func _on_HistoryBtn_pressed():
	# get_tree().change_scene("res://scenes/HistLevel.tscn")
	pass # Replace with function body.

func _on_QuitBtn_pressed():
	get_tree().quit()
