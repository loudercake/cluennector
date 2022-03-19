extends Node

enum MUSIC {
	WIN_GAME,
	DETECTIVE,
	GEOGRAPHY,
	HISTORY,
	POKEMON,
}

enum SFX {
	BUTTON,
	BACK,
	WIN,
	PAPER,
	CONNECT,
	DISCONNECT,
}


export(MUSIC) var music

const HttpHelper = preload("HttpHelper.gd")

export(Resource) var start_level
export(bool) var debug_mode = true

var clue_max_rotation = 20
var clue_max_random_offset = 70
var clue_max_random_scale = 0.5
var clue_base_size = 5
var n_rows = 2

var Clue = preload("res://scenes/Clue.tscn")

var top_left = Vector2.ZERO
var bottom_right = Vector2.ONE
var viewing_clue = null
var board_clues = []
var is_connecting = false
var can_connect = false
var start_clue = null
var end_clue = null
var clue_view_scale = 40
var help_hint = null

onready var board = $Board
onready var clues = $Board/Clues
onready var canvas = $Canvas
onready var description_label = $UI/Control/DescLabel
onready var top_label = $UI/Control/TopLabel
onready var background = $UI/Control/ColorRect
onready var board_top_left = $BoardLimits/TopLeft
onready var board_bottom_right = $BoardLimits/BottomRight
onready var win_btn = $UI/Control/NextLevelBtn
onready var confetti = [$Win/Particles2D, $Win/Particles2D2]
onready var confetti_timer = $Win/Timer
onready var confetti_tween = $Win/Tween
onready var resetbtn = $UI/Control/ResetButton

func debug(string):
	print(string)

# Display the image in a TextureRect node.
func debug_img(texture):
	var texture_rect = TextureRect.new()
	add_child(texture_rect)
	texture_rect.texture = texture


func if_not_null_set():
	var attributes = ["clue_max_rotation", "clue_max_random_offset", "clue_max_random_scale", "clue_base_size", "n_rows"]
	for attr in attributes:
		var value = start_level.get(attr)
		if value != null:
			set(attr, value)

func _ready():
	if not Global.music_player.playing:
		Global.play_music(music)

	# This is so children classes can overwrite the ready function doing stuff before it
	_on_ready()

func _load_from_global():
	if_not_null_set()
	if Global.next_level:
		start_level = Global.next_level

func _on_ready():
	_load_from_global()
	_populate_clues()

func _populate_clues():
	top_label.text = start_level.title
	top_left = board_top_left.global_position
	bottom_right = board_bottom_right.global_position

	var width = abs(top_left.x - bottom_right.x)
	var height = abs(top_left.y - bottom_right.y)

	# Programatically add clues to the board
	var clues_array = shuffle(start_level.story + start_level.decoy)
	var n_cols = int(clues_array.size() / float(n_rows) + 0.5)
	var last_pos = top_left
	var x_offset = width / n_cols
	var y_offset = height / n_rows
	var sum_pos = Vector2.ZERO
	var i = 1
	for clue_resource in clues_array:
		# Create the clue
		var clue = Clue.instance()
		clue.resource = clue_resource

		# Keep aspect ratio
		var t_size = clue_resource.texture.get_size()
		if t_size.x > t_size.y:
			clue.size.x = clue_base_size
			clue.size.y = t_size.y / t_size.x * clue_base_size
		elif t_size.x < t_size.y:
			clue.size.x = t_size.x / t_size.y * clue_base_size
			clue.size.y = clue_base_size
		else:
			clue.size = Vector2.ONE * clue_base_size

		# Add
		clues.add_child(clue)
		clue.position = Vector2.ZERO
		if clue.resource.pos == Vector2(-1, -1):
			clue.position = last_pos
		else:
			clue.position = clue.resource.pos

		clue.connect("hovered", self, "on_clue_hover")
		clue.connect("mouse_entered", self, "on_clue_mouse_entered")
		clue.connect("unhovered", self, "on_clue_unhover")
		clue.connect("clicked", self, "on_clue_click")
		clue.connect("drag_started", self, "on_drag_started")
		clue.connect("drag_stopped", self, "on_drag_stopped")
		clue.connect("right_clicked", self, "on_clue_right_click")
		last_pos.x += x_offset

		# Check grid
		if i % n_cols == 0:
			last_pos.x = top_left.x
			last_pos.y += y_offset
		i += 1

		# Randomize
		clue.rotation =  rndf() * clue_max_rotation * PI / 180
		clue.global_position.x += rndf() * clue_max_random_offset
		clue.global_position.y -= rndf() * clue_max_random_offset
		clue.scale = board.scale * (1 + rndf() * clue_max_random_scale)
		sum_pos += clue.global_position
		board_clues.append(clue)

	# Correct scale, centralize
	clues.global_position += (top_left + bottom_right) / 2 - sum_pos / len(board_clues) / board.scale
	clues.scale = Vector2.ONE / board.scale
	clue_view_scale = min(width, height) / clue_base_size / 2.0

	for clue in board_clues:
		clue.init()

func _level_reset():
	return get_tree().reload_current_scene()


func _process(_delta):
	if debug_mode:
		if Input.is_action_just_pressed("reset"):
			_level_reset()

	if Input.is_action_just_released("mouse_left_click") and viewing_clue:
		viewing_clue.return_animation()
		background.visible = false
		viewing_clue = null
		Global.play(SFX.PAPER)
		description_label.text = ""

	if Input.is_action_just_released("mouse_left_click"):
		is_connecting = false

func _input(event):
	if not is_connecting:
		return
	if event is InputEventMouseMotion:
		canvas.dash_end = event.position


## Random float between -1 and 1
func rndf():
	randomize()
	return (randf() - 0.5) * 2


func shuffle(list):
	randomize()
	var shuffled_list = []
	var index_list = range(list.size())
	for _i in range(list.size()):
		var x = randi()%index_list.size()
		shuffled_list.append(list[index_list[x]])
		index_list.remove(x)
	return shuffled_list

func on_clue_mouse_entered(clue):
	if not is_connecting or clue == start_clue or start_clue in clue.next:
		return
	can_connect = true
	clue.sprite.material.set_shader_param("color", clue.pressed_border_color)
	end_clue = clue

# hover after delay
func on_clue_hover(clue):
	if not viewing_clue:
		description_label.text = clue.get_title()

# unhover and mouse exit
func on_clue_unhover(_clue):
	end_clue = null
	if not is_connecting:
		can_connect = false
	if not viewing_clue:
		description_label.text = ""

# Mouse release over same clue
func on_clue_click(clue):
	if is_connecting:
		can_connect = false
		return

	if can_connect:
		end_clue = clue
		return

	if viewing_clue:
		viewing_clue.return_animation()
		return

	var center = (top_left + bottom_right) / 2
	description_label.text = clue.description
	clue.click_animation(center, Vector2.ONE * clue_view_scale, 2 * PI)
	viewing_clue = clue
	background.visible = true
	Global.play(SFX.PAPER)

func on_drag_started(clue):
	Global.play(SFX.BUTTON)
	is_connecting = true
	start_clue = clue
	canvas.dash_start = clue.initial_position
	canvas.dash_end = get_viewport().get_mouse_position()

func on_clue_right_click(clue):
	clue.next = []
	Global.play(SFX.DISCONNECT)
	if check_chain_complete():
		win_level()

func on_drag_stopped(_clue):
	canvas.clear_dash()

	# Connect
	if can_connect and end_clue and not start_clue in end_clue.next:
		start_clue.next.append(end_clue)
		canvas.add_clue(start_clue)
		Global.play(SFX.CONNECT)
	elif start_clue:
		Global.play(SFX.DISCONNECT)
		# start_clue.next = null
	start_clue = null
	end_clue = null
	is_connecting = false

	if check_chain_complete():
		win_level()


## Warning, you can cause infinite recurssion if you have a clue that references itself or a clue that references a clue that references itself
func check_chain_until(check_clue):
	for clue in board_clues:
		if check_clue.resource in clue.resource.next:
			if not (check_clue in clue.next and check_chain_until(clue)):
				if help_hint == null:
					help_hint = "Connect: \"" + clue.get_title() + "\" -> \"" + check_clue.get_title() + "\""
				return false
	return true

func check_chain_complete():

	# Is there any not needed connection?
	for check_clue in board_clues:
		for clue in board_clues:
			if clue == check_clue:
				continue
			if check_clue in clue.next and not check_clue.resource in clue.resource.next:
				help_hint = "Remove: \"" + clue.get_title() + "\" -> \"" + check_clue.get_title() + "\""
				return false

	# Are all necessary connections there?
	help_hint = null
	for clue in board_clues:
		if not check_chain_until(clue):
			return false

	return true


func _on_NextLevelBtn_pressed():
	Global.play(SFX.BUTTON)
	Global.next_level = start_level.next_level
	if not Global.next_level:
		win_game()
	else:
		return get_tree().reload_current_scene()
	return


func win_level():
	Global.play(SFX.WIN)
	win_btn.visible = true
	win_btn.grab_focus()
	top_label.text = "You won!"
	description_label.text = ""
	for clue in board_clues:
		clue.disconnect("hovered", self, "on_clue_hover")
		clue.disconnect("mouse_entered", self, "on_clue_mouse_entered")
		clue.disconnect("unhovered", self, "on_clue_unhover")
		clue.disconnect("clicked", self, "on_clue_click")
		clue.disconnect("drag_started", self, "on_drag_started")
		clue.disconnect("drag_stopped", self, "on_drag_stopped")
		clue.disconnect("right_clicked", self, "on_clue_right_click")

	confetti_timer.start()
	confetti_tween.stop_all()
	for particles in confetti:
		confetti_tween.interpolate_property(particles.process_material, "shader_param/initial_velocity",
		Vector3(0, 30, 0), Vector3(0, 3, 0), 0.5, confetti_tween.TRANS_QUART, confetti_tween.EASE_IN_OUT, 0.1)
		confetti_tween.start()
		particles.emitting = true

func win_game():
	Global.play_music_once(MUSIC.WIN_GAME)
	top_label.text = "You won the game!"
	resetbtn.text = "Play again"	
	confetti_timer.disconnect("timeout", self, "_on_Win_Timer_timeout")
	win_btn.visible = false
	for particles in confetti:
		particles.emitting = true

func _on_MenuButton_pressed():
	Global.play(SFX.BACK)
	return get_tree().change_scene("res://scenes/MainMenu.tscn")


func _on_Button_pressed():
	Global.play(SFX.BUTTON)
	_level_reset()

func _on_HelpBtn_pressed():
	Global.play(SFX.BUTTON)
	check_chain_complete()
	if help_hint != null:
		description_label.text = help_hint


func _on_Win_Timer_timeout():
	for particles in confetti:
		particles.emitting = false

func reset_clue_texture(clue, texture, size=null):
	clue.sprite.texture = texture
	clue.texture = texture
	if size != null:
		clue.size = size
	else:
		var t_size = texture.get_size()
		if t_size.x > t_size.y:
			clue.size.x = clue_base_size
			clue.size.y = t_size.y / t_size.x * clue_base_size
		elif t_size.x < t_size.y:
			clue.size.x = t_size.x / t_size.y * clue_base_size
			clue.size.y = clue_base_size
		else:
			clue.size = Vector2.ONE * clue_base_size
	clue.sprite.scale = clue.size / clue.texture.get_size() * 2
	clue.init()
