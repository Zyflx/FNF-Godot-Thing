extends Node

# signals
signal beat_hit(beat) # triggers every beat hit
signal step_hit(step) # triggers every step hit
signal bpm_changed(new_bpm) # triggered when the bpm changes
signal song_ended() # triggered when the song ends

# conductor stuff
const SIXTY:float = 0.0166666667

var bpm:float = 100.0
var crochet:float = (bpm * SIXTY) * 1000.0
var step_crochet:float = (crochet * 0.25) * 1000.0
var safe_offset:float = (10 * SIXTY) * 1000.0
var time:float = 0;

var stream_inst:AudioStreamPlayer
var stream_voices:AudioStreamPlayer

func set_bpm(new_bpm:float) -> void:
	bpm_changed.emit(new_bpm)
	crochet = (new_bpm * SIXTY) * 1000.0
	step_crochet = (crochet * 0.25) * 1000.0
	bpm = new_bpm
	
func init_music(data) -> void:
	var inst_path:String = 'res://assets/songs/' + data.song.replace(' ', '-') + '/audio/Inst.ogg'
	var voices_path:String = 'res://assets/songs/' + data.song.replace(' ', '-') + '/audio/Voices.ogg'
	
	if FileAccess.file_exists(inst_path):
		stream_inst = get_tree().current_scene.get_node('MusicPlayer')
		stream_inst.stream = load(inst_path)
	
	if FileAccess.file_exists(voices_path):
		stream_voices = get_tree().current_scene.get_node('VoicesPlayer')
		stream_voices.stream = load(voices_path)
		
func play_music():
	if stream_voices != null:
		stream_voices.play()
	if stream_inst != null:
		stream_inst.play()
	
func parse_json(song_name:String):
	var path:String = 'res://assets/songs/' + song_name + '/charts/normal.json'
	
	# if the file doesn't exist, stop the function so the game doesn't die lol
	if not FileAccess.file_exists(path):
		return
	
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	var chart = JSON.parse_string(file.get_as_text())
	
	# print(chart.song.song)
	
	return chart.song
	
func _ready() -> void:
	var game:Node2D = get_tree().current_scene
	song_ended.connect(game.song_ended)

func _process(delta:float) -> void:
	time += delta * 1000.0
	
	if time > 0:
		# vocal syncing
		if stream_voices != null and stream_voices.is_playing() and stream_inst.is_playing():
			var voice_time:float = stream_voices.get_playback_position() * 1000.0
			var inst_time:float = stream_inst.get_playback_position() * 1000.0
			if absf(voice_time - time) > 20.0:
				stream_voices.seek(time * 0.001)
			if absf(inst_time - time) > 20.0:
				stream_inst.seek(time * 0.001)
		else:
			# if the song doesn't have a voices file, sync the inst only
			if stream_inst != null and stream_inst.is_playing():
				var inst_time:float = stream_inst.get_playback_position() * 1000.0
				if absf(inst_time - time) > 20.0:
					stream_inst.seek(time * 0.001)
					
		if stream_inst != null and time >= stream_inst.stream.get_length() * 1000.0:
			song_ended.emit()
			stream_inst.stop()
			if stream_voices != null:
				stream_voices.stop()
			time = 0.0
			
