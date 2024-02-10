class_name Note
extends AnimatedSprite2D

var data:int = 0
var time:float = 0.0

var is_sustain:bool = false
var sustain_length:float = 0.0

var spawned:bool = false
var must_hit:bool = false
var can_be_hit:bool = false
var was_good_hit:bool = false
var can_cause_miss:bool = false

var speed:float = 0

var sustain:TextureRect

var color_array:Array[String] = ['purple', 'blue', 'green', 'red']

func _ready() -> void:
	scale = Vector2(0.7, 0.7)
	play(color_array[data])
	
	if data % 4 == 3 and not is_sustain:
		flip_v = true
		
	if is_sustain:
		sustain = TextureRect.new()
		sustain.texture = Util.get_texture('notes/sustains/' + color_array[data] + ' hold piece')
		sustain.size = Vector2(sustain.texture.get_width(), .45 * speed * sustain_length)
		sustain.scale.y = -1
		sustain.position.x = sustain.texture.get_width() * 0.5 - 50
		sustain.show_behind_parent = true
		sustain.material = load('res://game/materials/Sustain Clip.tres')
		add_child(sustain)
		
		var sustain_end:Sprite2D = Sprite2D.new()
		sustain_end.texture = Util.get_texture('notes/sustains/' + color_array[data] + ' hold end')
		sustain_end.position.y -= sustain.size.y
		sustain_end.scale.y = -1
		sustain_end.show_behind_parent = true
		sustain_end.material = load('res://game/materials/Sustain Clip.tres')
		add_child(sustain_end)

func _process(_delta:float) -> void:
	if must_hit:
		if time >= Conductor.time - (166 * 0.8) and time <= Conductor.time + (166 * 1):
			can_be_hit = true
		if position.y > get_viewport().size.y + 20:
			can_cause_miss = true
	else:
		can_be_hit = false
		if time <= Conductor.time:
			was_good_hit = true
			
func lock_to_strum(strum:StrumNote, speed:float) -> void:
	position.x = strum.position.x
	position.y = strum.position.y + (Conductor.time - time) * (0.45 * speed)
