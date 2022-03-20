extends Control


onready var gamebtn = $VBoxContainer/GameBtn
onready var quitbtn = $VBoxContainer/QuitBtn
onready var geobtn = $VBoxContainer/GeoBtn
onready var histbtn = $VBoxContainer/HistoryBtn
onready var musicbtn = $music

func _ready():
	Global.save_level()
	gamebtn.grab_focus()
	musicbtn.pressed = not Global.music_muted
	Global.next_level = null
	Global.music_player.stop()
	Global.play_music(-1)
	Global.came_from_menu = true

func load_mode(scene_path):
	Global.menu_button()
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	current_scene.queue_free()
	var scene = load(scene_path).instance()
	var level = Global.load_last_level(scene_path)
	if level:
		scene.start_level = level
	get_tree().get_root().add_child(scene)
	return get_tree().set_current_scene(scene)

func _on_GameBtn_pressed():
	load_mode("res://scenes/Level.tscn")

func _on_GeoBtn_pressed():
	load_mode("res://scenes/GeoLevel.tscn")

func _on_HistoryBtn_pressed():
	load_mode("res://scenes/HistLevel.tscn")

func _on_PokeBtn_pressed():
	load_mode("res://scenes/PokeLevel.tscn")

func _on_QuitBtn_pressed():
	Global.menu_button()
	if OS.get_name() == "HTML5":
		JavaScript.eval("confirm('Close this tab?') && window.close();")
	get_tree().quit()


func _on_music_toggled(button_pressed:bool):
	Global.music_muted = not button_pressed
	if button_pressed:
		Global.play_music(-1)
	else:
		Global.music_player.stop()
