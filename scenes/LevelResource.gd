extends Resource

export(String) var title
export(Array, Resource) var story
export(Array, Resource) var decoy
export(Resource) var next_level

export(float) var clue_max_rotation = 20
export(float) var clue_max_random_offset = 50
export(float) var clue_max_random_scale = 0.1
export(float) var clue_base_size = 4
export(int)   var n_rows = 2

var size = 0

func _init(p_title = "",
	p_story = [],
	p_decoy = [],
	p_next_level = null,
	p_clue_max_rotation = 20,
	p_clue_max_random_offset = 50,
	p_clue_max_random_scale = 0.1,
	p_clue_base_size = 4,
	p_n_rows = 2
	):

	n_rows = null
	title = p_title
	story = p_story
	decoy = p_decoy
	next_level = p_next_level
	size = story.size() + decoy.size()

	clue_max_rotation		= p_clue_max_rotation
	clue_max_random_offset	= p_clue_max_random_offset
	clue_max_random_scale	= p_clue_max_random_scale
	clue_base_size			= p_clue_base_size
	n_rows					= p_n_rows
