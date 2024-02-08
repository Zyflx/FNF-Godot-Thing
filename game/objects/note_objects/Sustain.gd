class_name Sustain
extends TextureRect

var texture_name:String
var length:float = 0
var time:float = 0
var parent:Note

func _ready() -> void:
	texture = load('res://assets/images/notes/sustains/' + texture_name + '.png')
	stretch_mode = TextureRect.STRETCH_TILE
	scale = Vector2(0.7, 0.7)

func _process(_delta:float) -> void:
	if parent != null:
		position = Vector2((parent.position.x + parent.scale.x * 0.5) - 20, parent.position.y + parent.scale.y * 0.5)
