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

var sustain:Sustain

var color_array:Array[String] = ['purple', 'blue', 'green', 'red']

func _ready() -> void:
	scale = Vector2(0.7, 0.7)
	play(color_array[data])
	
	if data % 4 == 3 and not is_sustain:
		flip_v = true

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
