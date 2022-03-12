extends Resource

export(String) var description
export(Texture) var texture

func _init(p_description="", p_texture=null):
	description = p_description
	texture = p_texture
