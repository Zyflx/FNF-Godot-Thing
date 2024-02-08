class_name GameUI
extends Node2D

# data
var rank_map:Dictionary = {
	100: 'S+', 95: 'S',
	90: 'A', 85: 'B',
	80: 'C', 75: 'D',
	70: 'E'
}

# stats
var accuracy:float = 0.0
var total:float = 0.0
var played:int = 0

# text objects
var score_txt:Label

# misc
@onready var game:Node2D = get_tree().current_scene

func _ready() -> void:
	score_txt = make_text()
	score_txt.position.x = get_viewport().size.x * 0.5 - 250
	score_txt.position.y = get_viewport().size.y * 0.1
	add_child(score_txt)
	update_score_txt()
	
func _process(_delta:float) -> void:
	pass
	
func update_score_txt() -> void:
	var acc:float = Util.round_decimal(accuracy, 2)
	var rank:String = determine_rank(acc)
	var text:String = 'Score: %s | Misses: %s | Accuracy: [%s%% | %s]'
	score_txt.text = text % [game.score, game.misses, acc, rank]
	
func update_accuracy(rating:int, missed:bool = false) -> void:
	played += 1
	if not missed: total += game.rating_data[rating][2]
	accuracy = (total / (played + game.misses)) * 100.0
	update_score_txt()

func determine_rank(acc:float = 0.0) -> String:
	for i in rank_map.keys():
		if i <= acc:
			return rank_map[i]
	return 'F' if acc <= 65 and acc > 0 else 'N/A'
	
func make_text() -> Label:
	var text:Label = Label.new()
	text.add_theme_font_size_override('font_size', 20)
	text.add_theme_font_override('font', load('res://assets/fonts/vcr.ttf'))
	text.add_theme_color_override('font_shadow_color', Color('000000'))
	text.add_theme_constant_override('shadow_offset_x', 0)
	text.add_theme_constant_override('shadow_offset_y', 0)
	text.add_theme_constant_override('shadow_outline_size', 7)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return text
