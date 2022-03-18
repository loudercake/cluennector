extends "res://scenes/Level.gd"

const BaseClue = preload("res://scenes/ClueResource.gd")
var API = "https://api.wikimedia.org/feed/v1/wikipedia/en/onthisday/selected/"
const MAX_CLUES = 12
const MAX_EVENTS = 3
const loading_texture_size = 6

onready var http = HttpHelper.new(self)

var n_clues_added = 0
var events_texts = PoolStringArray()
var border_width_override = 8.0

func _on_ready():
	http = HttpHelper.new(self)
	generate_random_level()

func on_level_ready():
	._load_from_global()
	var start_level = Global.next_level
	var clues_array = (start_level.story + start_level.decoy)
	if len(clues_array) > 10:
		n_rows = int(len(clues_array) / 10) + 2
	._populate_clues()
	for clue in board_clues:
		clue.set_block_signals(true)
		clue.border_width = border_width_override
		clue.size = Vector2.ONE * loading_texture_size
		.reset_clue_texture(clue, clue.texture, clue.size)
	bottom_right += Vector2(0, 100)


func generate_random_level():
	top_label.text = "Loading..."
	randomize()
	var datetime = OS.get_datetime_from_unix_time(randi())
	var date = str(datetime["month"]) + "/" + str(datetime["day"])
	var url = API + date
	http.json_get_request(url, [], "on_wiki_info", date, "on_request_error")

func generate_clue(page, parent=[]):
	if not "thumbnail" in page:
		return null
	n_clues_added += 1
	var title = page["displaytitle"]
	var description = page["extract"]
	var texture = load("res://levels/histlevel/loading.png")
	var url = page["thumbnail"]["source"]
	var new_clue = BaseClue.new(description, texture, parent, Vector2(-1, -1), title)
	Global.next_level.story.append(new_clue)
	http.image_get_request(url, [], "add_texture", new_clue, "on_add_error")
	return new_clue

func on_wiki_info(json, date):
	Global.next_level = start_level.duplicate()
	Global.next_level.story = []

	randomize()
	var n = randi() % MAX_EVENTS + 1
	# description_label.set_deferred("text",  selected["text"])

	var indexes = []
	for i in len(json["selected"]):
		indexes.append(i)
	indexes = shuffle(indexes)

	var i = 0
	var added = 0
	var years = PoolStringArray()
	while i < len(indexes):
		years.append(str(json["selected"][i]["year"]))
		if add_event(json, indexes[i]):
			added += 1
		if added >= n:
			break
		if n_clues_added >= MAX_CLUES:
			break
		i += 1
	top_label.set_deferred("text", "Connect the clues to the main event. Here there are " + str(added) + " unrelated events that happened on " + date + "/{" + years.join(", ") + "}")

	on_level_ready()

func add_event(json, idx):
	var selected = json["selected"][idx]
	var year = selected["year"]
	var pages = selected["pages"]
	var page = pages[0]

	var base = generate_clue(page)
	if base == null:
		return false
	events_texts.append(str(year) + " - " + selected["text"])
	var n_clues = len(pages)
	for i in n_clues - 1:
		if n_clues_added >= MAX_CLUES:
			break
		page = pages[i + 1]
		generate_clue(page, [base])
	return true

func on_request_error(_extra):
	on_level_ready()
	top_label.text = "Error loading level :("

func on_add_error(clue_resource):
	var texture = load("res://levels/histlevel/question_mark.png")
	add_texture(texture, clue_resource)

func add_texture(texture, clue_resource):
	for clue in board_clues:
		if clue.resource == clue_resource:
			.reset_clue_texture(clue, texture)
			clue.set_block_signals(false)
			return

func _on_NextLevelBtn_pressed():
	description_label.text = "loading next level... "
	generate_random_level()
	return get_tree().reload_current_scene()

func win_level():
	.win_level()
	for text in events_texts:
		description_label.text += text + "\n"
