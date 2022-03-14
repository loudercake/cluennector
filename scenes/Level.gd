extends Node

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

onready var board = $Board
onready var clues = $Board/Clues
onready var canvas = $Canvas
onready var description_label = $Control/DescLabel
onready var top_label = $Control/TopLabel
onready var background = $Control/ColorRect
onready var board_top_left = $BoardLimits/TopLeft
onready var board_bottom_right = $BoardLimits/BottomRight
onready var win_btn = $Control/NextLevelBtn


func if_not_null_set():
	var attributes = ["clue_max_rotation", "clue_max_random_offset", "clue_max_random_scale", "clue_base_size", "n_rows"]
	for attr in attributes:
		var value = start_level.get(attr)
		if value:
			set(attr, value)

func _ready():
	if Global.next_level:
		start_level = Global.next_level
		if_not_null_set()

	top_label.text = start_level.title
	top_left = board_top_left.global_position
	bottom_right = board_bottom_right.global_position

	var width = abs(top_left.x - bottom_right.x)
	var height = abs(top_left.y - bottom_right.y)

	# Programatically add clues to the board
	var clues_array = shuffle(start_level.story + start_level.decoy)
	var last_pos = top_left
	var n_cols = int(clues_array.size() / float(n_rows) + 0.5)
	var x_offset = width / n_cols
	var y_offset = height / n_rows
	var i = 1
	for clue_resource in clues_array:
		# Create the clue
		var clue = Clue.instance()
		clue.resource = clue_resource
		clue.size = Vector2.ONE * clue_base_size
		clue.position = Vector2.ZERO
		clue.global_position = last_pos
		clue.connect("hovered", self, "on_clue_hover")
		clue.connect("mouse_entered", self, "on_clue_mouse_entered")
		clue.connect("unhovered", self, "on_clue_unhover")
		clue.connect("clicked", self, "on_clue_click")
		clue.connect("drag_started", self, "on_drag_started")
		clue.connect("drag_stopped", self, "on_drag_stopped")
		clue.connect("right_clicked", self, "on_clue_right_click")
		last_pos.x += x_offset

		# Add
		clues.add_child(clue)

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
		board_clues.append(clue)

	clues.scale = Vector2.ONE / board.scale
	clue_view_scale = min(width, height) / clue_base_size / 2

	for clue in board_clues:
		clue.init()


func _process(_delta):
	if debug_mode:
		if Input.is_action_just_pressed("reset"):
			get_tree().reload_current_scene()

	if Input.is_action_just_released("mouse_left_click") and viewing_clue:
		viewing_clue.return_animation()
		background.visible = false
		viewing_clue = null
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
		description_label.text = clue.description

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

func on_drag_started(clue):
	is_connecting = true
	start_clue = clue
	canvas.dash_start = clue.initial_position
	canvas.dash_end = get_viewport().get_mouse_position()

func on_clue_right_click(clue):
	clue.next = []

func on_drag_stopped(_clue):
	canvas.clear_dash()

	# Connect
	if can_connect and end_clue and not start_clue in end_clue.next:
		start_clue.next.append(end_clue)
		canvas.add_clue(start_clue)
	elif start_clue:
		pass
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
				return false
	return true

func check_chain_complete():
	for clue in board_clues:
		if not check_chain_until(clue):
			return false
	return true


func _on_NextLevelBtn_pressed():
	# TODO just load the next level of the start_level (remove this if)
	if OS.get_name() == "HTML5":
		Global.next_level = start_level.next_level
		if not Global.next_level:
			win_game()
		else:
			get_tree().reload_current_scene()
		return

	# description_label.text = "loading next level... "
	# var new_clue = start_level.story[-1].duplicate(true)
	# new_clue.description = str(len(start_level.story) + 1) + "th clue"
	# start_level.story[-1].next.append(new_clue)
	# start_level.story.append(new_clue)
	# start_level.n_rows = 2 + int(len(start_level.story) / 10.0)
	# start_level.clue_base_size /= 1.03
	# Global.next_level = start_level
	# get_tree().reload_current_scene()


func win_level():
	win_btn.visible = true
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

func win_game():
	top_label.text = "You won the game!"
