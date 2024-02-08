class_name StrumNote
extends AnimatedSprite2D

var dir:int = 0
var reset_time:float = 0
var is_player:bool = false

const width:float = 160 * 0.7
const dir_array:Array[String] = ['left', 'down', 'up', 'right']

func _ready() -> void:
	scale = Vector2(0.7, 0.7)
	position = Vector2(100 + (width * dir), get_viewport().size.y - 120)
	if is_player:
		position.x += (get_viewport().size.x * 0.5) - 340
	play_anim('static')
	
func _process(delta:float) -> void:
	# for confirm anim
	if reset_time > 0:
		reset_time -= delta
		if reset_time <= 0:
			reset_time = 0
			play_anim('static')
	
	if animation.contains('press'):
		if frame_progress == 1.0:
			play_anim(dir_to_name() + ' press')
			frame = 3
	
func play_anim(anim:String) -> void:
	play(anim);
	if anim == 'static':
		frame = dir % 4
	# marios madness right strum note silly
	if dir % 4 == 3:
		flip_v = true
	
func dir_to_name():
	return dir_array[dir % 4]
