extends Resource

export(String) var description
export(Texture) var texture
export(Array, Resource) var next

func _init(p_description="", p_texture=null, p_next = []):
	description = p_description
	texture = p_texture
	next = p_next
