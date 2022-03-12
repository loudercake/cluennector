extends Resource

export(String) var title
export(Array, Resource) var story
export(Array, Resource) var decoy
export(Resource) var next_level

var size = 0

func _init(p_title = "", p_story = [], p_decoy = [], p_next_level=null):
	title = p_title
	story = p_story
	decoy = p_decoy
	next_level = p_next_level
	size = story.size() + decoy.size()
