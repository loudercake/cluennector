extends Node2D

export var hover_border_color = Color(0.95, 0.1, 0, 1)
export var pressed_border_color = Color(0, 0.1, 0.95, 1)

const hover_scale = 1.3
const modulate_scale = 1.2
const border_width = 2.5
const transition_time = 0.5

var viewing = false
var is_hovered: bool = false
var mouse_pressed_inside = false
var has_mouse: bool = false
var has_drag_stared: bool = false

var description: String = ""
var size = Vector2.ONE * 5
var texture: Texture
var resource
var valid_next_list = []
var next = []


var initial_scale = Vector2.ONE
onready var initial_modulate = modulate
onready var initial_rotation = rotation
onready var initial_position = global_position

onready var collision = $Area2D/CollisionShape2D
onready var mouse_area = $Area2D
onready var sprite = $Sprite
onready var timer = $Timer
onready var hover_tween = $HoverTween
onready var tween = $Tween

signal hovered
signal mouse_entered
signal unhovered
signal drag_started
signal drag_stopped
signal clicked
signal right_clicked

func _ready():
	texture = resource.texture
	position = resource.pos
	description = resource.description
	valid_next_list = resource.next
	if not description:
		description = "No description."
	collision.shape.extents = size
	sprite.texture = texture
	sprite.scale = size / texture.get_size() * 2
	sprite.material.set_shader_param("color", hover_border_color)

## stores world scale, position and rotation
func init():
	initial_scale = scale
	initial_position = global_position
	initial_rotation = rotation
	initial_modulate = modulate

func diagonal_size():
	return (get_parent().get_parent().scale * size).length()

func stop_drag():
	has_drag_stared = false
	emit_signal("drag_stopped", self)
	sprite.material.set_shader_param("color", hover_border_color)
	is_hovered = has_mouse
	hover_animation()

func _input(event):
	if event is InputEventMouseMotion and mouse_pressed_inside:
		if has_drag_stared:
			return
		has_drag_stared = true
		emit_signal("drag_started", self)

func _process(_delta):
	if viewing:
		if has_drag_stared:
			stop_drag()
		has_drag_stared = false
	elif Input.is_action_just_pressed("mouse_left_click") and has_mouse:
		sprite.material.set_shader_param("color", pressed_border_color)
		mouse_pressed_inside = true
	elif Input.is_action_just_released("mouse_left_click") and has_mouse and not has_drag_stared and mouse_pressed_inside:
		sprite.material.set_shader_param("color", hover_border_color)
		if has_drag_stared:
			stop_drag()
		emit_signal("clicked", self)
	elif Input.is_action_just_released("mouse_left_click"):
		if has_drag_stared:
			stop_drag()
		mouse_pressed_inside = false
	elif Input.is_action_just_released("mouse_right_click") and has_mouse:
		emit_signal("right_clicked", self)

func click_animation(to_position: Vector2, to_scale: Vector2, to_rotation: float):
	z_index = 1000
	viewing = true
	if has_drag_stared:
		emit_signal("drag_stopped", self)

	hover_tween.stop_all()
	tween.stop_all()
	modulate = initial_modulate
	sprite.material.set_shader_param("border_width", 0.0)
	tween.interpolate_property(self, "scale",
			scale, to_scale, transition_time,
			tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	tween.interpolate_property(self, "global_position",
			global_position, to_position, transition_time,
			tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rotation",
			rotation, to_rotation, transition_time,
			tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	tween.interpolate_property(sprite.get_material(), "shader_param/border_width",
			sprite.material.get_shader_param("border_width"), 0.0, 0.15,
			hover_tween.TRANS_LINEAR, hover_tween.EASE_IN_OUT)
	tween.start()

func return_animation():
	tween.stop_all()
	tween.interpolate_property(self, "scale",
			scale, initial_scale, transition_time,
			tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	tween.interpolate_property(self, "global_position",
			global_position, initial_position, transition_time,
			tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rotation",
			rotation, initial_rotation, transition_time,
			tween.TRANS_LINEAR, tween.EASE_IN_OUT)
	tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")
	tween.start()

func hover_animation():
	if viewing:
		return
	hover_tween.stop_all()
	if is_hovered:
		hover_tween.interpolate_property(self, "scale",
				scale, initial_scale * hover_scale, 0.1,
				hover_tween.TRANS_LINEAR, hover_tween.EASE_IN_OUT)
		hover_tween.interpolate_property(self, "modulate",
				modulate, initial_modulate * modulate_scale, 0.1,
				hover_tween.TRANS_LINEAR, hover_tween.EASE_IN_OUT)
		hover_tween.interpolate_property(sprite.get_material(), "shader_param/border_width",
				sprite.material.get_shader_param("border_width"), border_width, 0.1,
				hover_tween.TRANS_LINEAR, hover_tween.EASE_IN_OUT)
	else:
		hover_tween.interpolate_property(self, "scale",
				scale, initial_scale, 0.5,
				hover_tween.TRANS_LINEAR, hover_tween.EASE_IN_OUT)
		hover_tween.interpolate_property(self, "modulate",
				modulate, initial_modulate, 0.2,
				hover_tween.TRANS_LINEAR, hover_tween.EASE_IN_OUT)
		hover_tween.interpolate_property(sprite.get_material(), "shader_param/border_width",
				sprite.material.get_shader_param("border_width"), 0.0, 0.15,
				hover_tween.TRANS_LINEAR, hover_tween.EASE_IN_OUT)
	hover_tween.start()

func _on_Area2D_mouse_entered():
	emit_signal("mouse_entered", self)
	has_mouse = true
	if is_hovered or viewing:
		return
	is_hovered = true
	timer.start()
	hover_animation()

func _on_Area2D_mouse_exited():
	has_mouse = false
	mouse_pressed_inside = false
	if not is_hovered or viewing or has_drag_stared:
		return
	is_hovered = false
	emit_signal("unhovered", self)
	sprite.material.set_shader_param("color", hover_border_color)
	hover_animation()

func _on_Timer_timeout():
	if is_hovered:
		hover_tween.stop_all()
		emit_signal("hovered", self)
		# Ensure because this scale hover_tween is not perfect
		scale = initial_scale * hover_scale
		modulate =  initial_modulate * hover_scale
		sprite.material.set_shader_param("border_width", border_width)


func _on_Tween_tween_all_completed():
	if tween.is_connected("tween_all_completed", self, "_on_Tween_tween_all_completed"):
		tween.disconnect("tween_all_completed", self, "_on_Tween_tween_all_completed")
	viewing = false
	is_hovered = false
	z_index = 0
