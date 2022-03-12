extends Node

export(Resource) var start_level
export(float) var clue_max_rotation = 5
export(float) var clue_max_random_offset = 70
export(int) var n_rows = 2
export(bool) var debug_mode = true

var Clue = preload("res://scenes/Clue.tscn")

var top_left = Vector2.ZERO
var bottom_right = Vector2.ONE

onready var board = $Board
onready var clues = $Board/Clues
onready var description_label = $Control/DescLabel

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
		var clue = Clue.instance()
		clue.resource = clue_resource
		clue.size = Vector2.ONE * 5
		clue.global_position = last_pos
		clue.connect("hovered", self, "on_clue_hover")
		clue.connect("unhovered", self, "on_clue_unhover")
		clue.connect("clicked", self, "on_clue_click")
		clues.add_child(clue)
		last_pos.x += x_offset

		if i % n_cols == 0:
			last_pos.x = top_left.x
			last_pos.y += y_offset
		i += 1

		# Randomize
		randomize()
		clue.rotation = (randf() - 0.5) * 2 * clue_max_rotation * PI / 180
		clue.global_position.x += (randf() - 0.5) * 2 * clue_max_random_offset
		clue.global_position.y -= (randf() - 0.5) * 2 * clue_max_random_offset

	clues.scale = Vector2.ONE * 0.8


func _process(_delta):
	if debug_mode:
		if Input.is_action_just_pressed("reset"):
			get_tree().reload_current_scene()


func shuffle(list):
	randomize()
	var shuffled_list = []
	var index_list = range(list.size())
	for _i in range(list.size()):
		var x = randi()%index_list.size()
		shuffled_list.append(list[index_list[x]])
		index_list.remove(x)
	return shuffled_list

func on_clue_hover(clue):
	description_label.text = clue.description

func on_clue_unhover(clue):
	description_label.text = ""

func on_clue_click(clue):
	print("Click: ", clue)
