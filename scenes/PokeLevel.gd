extends "res://scenes/HistLevel.gd"

const MAX_N_CHAINS = 2
const MAX_N_DECOYS = 4
const N_CHAINS = 470
const N_POKEMONS = 890

var n_chains = 0
var completed_chains = 0
var pokemon_ids = []

func bbwrap(text, tag):
	return "[" + tag + "]" + text + "[/" + tag + "]"

func _on_ready():
	API = "https://pokeapi.co/api/v2/"
	border_width_override = 2.0
	http = HttpHelper.new(self)
	generate_random_level()

func generate_random_level():
	top_label.text = "Loading..."
	Global.next_level = start_level.duplicate()
	Global.next_level.story = []

	# create decoys:
	randomize()
	var n_decoys = randi() % MAX_N_DECOYS
	for _i in n_decoys:
		randomize()
		var id = randi() % N_POKEMONS + 1
		var url = API + "pokemon-species/" + str(id)
		http.json_get_request(url, [], "on_chain_info", true, "on_request_error")

	# Create chains
	randomize()
	n_chains = randi() % MAX_N_CHAINS + 1 + n_decoys
	for _i in n_chains - n_decoys:
		queue_new_chain()

func queue_new_chain():
	randomize()
	var chain = randi() % N_CHAINS + 1
	var url = API + "evolution-chain/" + str(chain)
	http.json_get_request(url, [], "on_chain_info", null, "on_request_error")


func generate_clue(evolution, child=[]):
	var title = evolution["species"]["name"]
	pokemon_ids.append(evolution["species"]["url"].split("/")[-
2])
	var description = title
	var texture = load("res://levels/histlevel/loading.png")
	var url = API + "pokemon/" + title
	var new_clue = BaseClue.new(description, texture, [], Vector2(-1, -1), title)
	if child:
		child.next.append(new_clue)

	Global.next_level.story.append(new_clue)
	http.json_get_request(url, [], "on_pokemon_received", new_clue, "on_add_error")
	url = API + "pokemon-species/" + title
	http.json_get_request(url, [], "on_pokedex_received", new_clue)

	n_clues_added += 1
	return new_clue

func on_pokemon_received(pokemon, new_clue):
	var url = pokemon["sprites"]["front_default"]
	http.image_get_request(url, [], "add_texture", new_clue, "on_add_error")

func on_pokedex_received(dex, clue_resource):
	for clue in board_clues:
		if clue.resource == clue_resource:
			var english = []
			for desc in dex["flavor_text_entries"]:
				if desc["language"]["name"] == "en":
					english.append(desc["flavor_text"])
			if len(english) == 0:
				return
			randomize()
			clue.description = english[randi() % len(english)]
			return

func add_evolutions(chain, child):
	for evolution in chain:
		if n_clues_added >= MAX_CLUES:
			break
		var sub_parent = generate_clue(evolution, child)
		if evolution["evolves_to"]:
			add_evolutions(evolution["evolves_to"], sub_parent)

func add_decoy(json):
	var evolution = {"species": {"name": json["name"], "url": str(json["id"]) + "/"}}
	generate_clue(evolution)
	check_chain_completed()

func on_chain_info(json, is_decoy):
	if is_decoy:
		add_decoy(json)
		return

	var chain = json["chain"]["evolves_to"]
	if len(chain) == 0:
		queue_new_chain()
		return

	var child = generate_clue(json["chain"])
	add_evolutions(chain, child)
	check_chain_completed()

func check_chain_completed():
	completed_chains += 1
	if completed_chains == n_chains:
		top_label.set_deferred("text", "Complete the evolution tree(s). There can be decoys.")
		on_level_ready()

func on_request_error(_extra):
	return get_tree().reload_current_scene()
	# top_label.set_deferred("text", "Error loading level :(")

func _on_NextLevelBtn_pressed():
	description_label.bbcode_text = bbwrap("loading next level... ", "center")
	generate_random_level()
	return get_tree().reload_current_scene()
