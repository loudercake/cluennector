extends Node

export(Resource) var start_level
export(float) var clue_max_rotation = 20
export(float) var clue_max_random_offset = 70
export(float) var clue_max_random_scale = 0.5
export(int) var n_rows = 2
export(bool) var debug_mode = true

var Clue = preload("res://scenes/Clue.tscn")

var top_left = Vector2.ZERO
var bottom_right = Vector2.ONE
var viewing_clue = null
var board_clues = []
var is_connecting = false
var can_connect = false
var start_clue = null
var end_clue = null

onready var board = $Board
onready var clues = $Board/Clues
onready var canvas = $Canvas
onready var description_label = $Control/DescLabel
onready var background = $Control/ColorRect

func _ready():
	top_left = board.global_position
	bottom_right = top_left + board.texture.get_size()
	var width = abs(top_left.x - bottom_right.x)
	var height = abs(top_left.y - bottom_right.y)

	# Programatically add clues to the board
	var clues_array = shuffle(start_level.story + start_level.decoy)
	var last_pos = top_left / 2
	var n_cols = int(clues_array.size() / float(n_rows) + 0.5)
	var x_offset = width / n_cols
	var y_offset = height / n_rows
	var i = 1
	for clue_resource in clues_array:
		# Create the clue
		var clue = Clue.instance()
		clue.resource = clue_resource
		clue.size = Vector2.ONE * 5
		clue.global_position = last_pos
		clue.connect("hovered", self, "on_clue_hover")
		clue.connect("mouse_entered", self, "on_clue_mouse_entered")
		clue.connect("unhovered", self, "on_clue_unhover")
		clue.connect("clicked", self, "on_clue_click")
		clue.connect("drag_started", self, "on_drag_started")
		clue.connect("drag_stopped", self, "on_drag_stopped")
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
		clue.scale = Vector2.ONE * (1 + rndf() * clue_max_random_scale)
		board_clues.append(clue)

	clues.scale = Vector2.ONE * 0.8

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
	if not is_connecting or clue == start_clue:
		return
	can_connect = true
	clue.sprite.material.set_shader_param("color", clue.pressed_border_color)
	end_clue = clue

func on_clue_hover(clue):
	if not viewing_clue:
		description_label.text = clue.description

func on_clue_unhover(clue):
	if not is_connecting or clue == start_clue:
		can_connect = false
	if not viewing_clue:
		description_label.text = ""

func on_clue_click(clue):
	if can_connect:
		end_clue = clue
		return

	if viewing_clue:
		viewing_clue.return_animation()
		return

	var center = Vector2(512, 300)
	description_label.text = clue.description
	clue.click_animation(center, Vector2.ONE * 8, 2 * PI)
	viewing_clue = clue
	background.visible = true

func on_drag_started(clue):
	is_connecting = true
	start_clue = clue
	canvas.dash_start = clue.initial_position
	canvas.dash_end = get_viewport().get_mouse_position()
	print("drag started: ", clue)

func on_drag_stopped(clue):
	is_connecting = false
	canvas.clear_dash()

	# Connect
	if can_connect:
		start_clue.next = end_clue
		canvas.add_clue(start_clue)
	start_clue = null
	end_clue = null
	print("drag stopped: ", clue)
