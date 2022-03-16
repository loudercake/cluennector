extends "res://scenes/Level.gd"

onready var line_edit = $UI/Control/LineEdit

var ccodes = ['gp', 'nl', 'al', 'td', 'mw', 'na', 'tn', 'sa', 'ls', 'et', 'lr', 'bw', 'qa', 'rs', 'au', 'im', 'ck', 'sy', 'sj', 'bs', 'zw', 'mo', 'ec', 'ee', 'io', 'cl', 'gu', 'af', 'ky', 'ai', 'yt', 'km', 'by', 'br', 'us', 'ie', 'dm', 'si', 'cz', 'uy', 'pr', 'tf', 'jp', 'mv', 'sb', 'lk', 'ml', 'cy', 'tr', 'ch', 'gi', 'nr', 'tt', 'dk', 'cf', 'pe', 'ye', 'gm', 'mn', 'tl', 'sl', 'mx', 'co', 'sv', 'bf', 'ao', 'fr', 'mc', 'ly', 'cr', 'jo', 'fk', 'tw', 'ni', 'eg', 'so', 'tc', 'kw', 'gd', 'lc', 'ht', 'cu', 'in', 'hr', 'no', 'ge', 'hn', 'tg', 'li', 'sz', 'ba', 're', 'bn', 'mm', 'dz', 'ca', 'it', 'th', 'tk', 'bd', 'sh', 'ag', 'ar', 'cc', 'bi', 'fo', 'am', 'ma', 've', 'za', 'bz', 'sr', 'kh', 'bj', 'cm', 'lt', 'pn', 'vc', 'lb', 'fj', 'ru', 'bt', 'gh', 'to', 'at', 'pa', 'bq', 'ne', 'aq', 'pg', 'la', 'mu', 'gy', 'ss', 'gf', 'kz', 'ro', 'wf', 'mf', 'kr', 'dj', 'gt', 'sx', 'es', 'mt', 'ph', 'mr', 'me', 'se', 'bl', 'gg', 'ki', 'rw', 'zm', 'bo', 'ir', 'er', 'sc', 'pf', 'mk', 'jm', 'ae', 'bg', 'tj', 'ci', 'bm', 'vu', 'fi', 'bh', 'mg', 'be', 'pl', 'pk', 'iq', 'va', 'ms', 'gb', 'hu', 'sm', 'tm', 'as', 'cg', 'nc', 'gr', 'gw', 'sd', 'hk', 'ws', 'az', 'ax', 'cn', 'om', 'hm', 'gl', 'kp', 'vn', 'cw', 'vg', 'do', 'vi', 'pm', 'pt', 'bb', 'id', 'gq', 'nu', 'my', 'lu', 'cv', 'sn', 'nz', 'mz', 'sk', 'kn', 'eh', 'uz', 'gs', 'mq', 'aw', 'sg', 'cd', 'lv', 'py', 'cx', 'kg', 'nf', 'tz', 'ad', 'md', 'st', 'ke', 'il', 'ua', 'is', 'ga', 'np', 'ng', 'de', 'ug', 'gn', 'bv', 'pw']


func _on_ready():
	generate_random_level()
	._load_from_global()
	var start_level = Global.next_level
	var clues_array = (start_level.story + start_level.decoy)
	if len(clues_array) > 10:
		n_rows = int(len(clues_array) / 10) + 2

	._populate_clues()
	for clue in board_clues:
		clue.border_width = 12.0

func generate_random_level():
	randomize()
	var cc = ccodes[randi() % len(ccodes)]
	if Global.next_cc != null:
		cc = Global.next_cc
	Global.next_cc = null

	var start_clue = load("res://levels/countries/clues/" + cc + ".tres")
	while start_clue == null or not start_clue.next:
		randomize()
		cc = ccodes[randi() % len(ccodes)]
		start_clue = load("res://levels/countries/clues/" + cc + ".tres")
	Global.next_level = start_level.duplicate()
	Global.next_level.story = []
	Global.next_level.story.append(start_clue)
	Global.next_level.story.append_array(start_clue.next)


func _on_NextLevelBtn_pressed():
	description_label.text = "loading next level... "
	generate_random_level()
	get_tree().reload_current_scene()

func _level_reset():
	var text = line_edit.text.to_lower()
	if len(text) == 2 and text in ccodes:
		Global.next_cc = text
		._level_reset()
	elif len(text) > 0:
		description_label.text = text + " is an invalid country code!"
	else:
		._level_reset()
