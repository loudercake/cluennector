extends Resource

export(String) var description
export(Texture) var texture
export(Array, Resource) var next
export(Vector2) var pos
export(String) var title

func _init(p_description="", p_texture=null, p_next = [], p_pos = -Vector2.ONE, p_title=""):
	description = p_description
	texture = p_texture
	next = p_next
	pos = p_pos
	title = p_title
