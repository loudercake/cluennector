extends Node2D

func _ready():
	set_process(true)

func _draw():
	pass

func _process(_delta):
	if visible:
		update()

