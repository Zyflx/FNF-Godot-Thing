extends Node2D

const Sustain_Node = preload("res://game/objects/Sustain.tscn")
const Note_Node = preload('res://game/objects/Note.tscn')

var sustain:Sustain
var note:Note

func _ready() -> void:
	note = Note_Node.instantiate()
	note.data = 0
	note.position.x = get_viewport().size.x * 0.5
	note.position.y = get_viewport().size.y * 0.5
	add_child(note)
	
	sustain = Sustain_Node.instantiate()
	sustain.parent = note
	sustain.texture_name = 'purple hold piece'
	add_child(sustain)

func _process(_delta:float) -> void:
	pass
