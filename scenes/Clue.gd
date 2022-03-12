extends Node2D

var is_hovered: bool = false
var description: String = ""
var size = Vector2.ONE * 5
var texture: Texture
var resource
var next

onready var collision = $Area2D/CollisionShape2D
onready var sprite = $Sprite
onready var timer = $Timer

signal hovered
signal unhovered
signal clicked

func _ready():
	texture = resource.texture
	description = resource.description
	next = resource.next
	if not description:
		description = "No description."
	collision.shape.extents = size
	sprite.texture = texture
	sprite.scale = size / texture.get_size() * 2


func _process(_delta):
	if Input.is_action_just_pressed("mouse_left_click") and is_hovered:
		emit_signal("clicked", self)

func _on_Area2D_mouse_entered():
	is_hovered = true
	timer.start()

func _on_Area2D_mouse_exited():
	is_hovered = false
	emit_signal("unhovered", self)

func _on_Timer_timeout():
	if is_hovered:
		emit_signal("hovered", self)
