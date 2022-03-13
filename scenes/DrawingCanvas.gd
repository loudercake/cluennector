extends Node2D

export var dash_color = Color(0.0, 0.5, 1.0, 1.0)
export var dash_width = 3.0
export var dash_length = 10.0
export var arrow_color = Color(1.0, 0.2, 0.0, 1.0)
export var arrow_width = 4.0
export var arrow_head_width = 10.0
export var arrow_head_length = 15.0

var dash_start = Vector2(0, 0)
var dash_end = Vector2(0, 0)
var clues = []

func add_clue(clue):
	if not clue in clues:
		clues.append(clue)

func _ready():
	set_process(true)
	global_position = Vector2.ZERO

func clear_dash():
	dash_start = Vector2(0, 0)
	dash_end = Vector2(0, 0)

func _draw():
	draw_dashed_line(dash_start, dash_end, dash_color, dash_width, dash_length)
	for clue in clues:
		if clue.next:
			for next in clue.next:
				var dir = (next.initial_position - clue.initial_position).normalized()
				var arrow_start = clue.initial_position + dir * clue.diagonal_size() / 2
				var arrow_end  = next.initial_position - dir * next.diagonal_size() / 2
				draw_arrow(arrow_start, arrow_end, arrow_color, arrow_width, arrow_head_width, arrow_head_length)

func _process(_delta):
	update()

func draw_arrow(from, to, color, width, head_width, head_height, antialiased=true):
	var head = PoolVector2Array()
	var dir = (to - from).normalized()
	var perp = dir.rotated(PI / 2)
	var base = to - dir * head_height
	draw_line(from, base, color, width, antialiased)
	head.append_array([to, base + perp * head_width, base - perp * head_width])
	draw_colored_polygon(head, color)

func draw_dashed_line(from, to, color, width, p_dash_length = 5, cap_end = true, antialiased = true):
	var length = (to - from).length()
	var normal = (to - from).normalized()
	var dash_step = normal * p_dash_length

	if length < p_dash_length: #not long enough to dash
		draw_line(from, to, color, width, antialiased)
		return

	else:
		var draw_flag = true
		var segment_start = from
		var steps = length/p_dash_length
		for _start_length in range(0, steps + 1):
			var segment_end = segment_start + dash_step
			if draw_flag:
				draw_line(segment_start, segment_end, color, width, antialiased)

			segment_start = segment_end
			draw_flag = !draw_flag

		if cap_end:
			draw_line(segment_start, to, color, width, antialiased)
