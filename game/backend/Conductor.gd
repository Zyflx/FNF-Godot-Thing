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
	stream_inst = get_tree().current_scene.get_node('MusicPlayer')
	stream_inst.stream = Util.get_inst(data.song)
	stream_voices = get_tree().current_scene.get_node('VoicesPlayer')
	stream_voices.stream = Util.get_voices(data.song)
		
func play_music() -> void:
	if stream_voices != null:
		stream_voices.play()
	if stream_inst != null:
		stream_inst.play()
		
func stop_music() -> void:
	if stream_voices != null:
		stream_voices.stop()
	if stream_inst != null:
		stream_inst.stop()
		
func sync_stream(stream:AudioStreamPlayer) -> void:
	if stream != null and stream.is_playing():
		if absf(stream.get_playback_position() * 1000.0 - time) > 20.0:
			stream.seek(time * 0.001)
	
func parse_json(song_name:String):
	var path:String = 'res://assets/songs/' + song_name + '/charts/normal.json'
	# if the file doesn't exist, stop the function so the game doesn't die lol
	if not FileAccess.file_exists(path): return
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text()).song
	
func _ready() -> void:
	var game:Node2D = get_tree().current_scene
	song_ended.connect(game.song_ended)

func _process(delta:float) -> void:
	time += delta * 1000.0
	
	if time > 0:
		# vocal and inst syncing
		sync_stream(stream_inst)
		sync_stream(stream_voices)	
		if stream_inst != null and time >= stream_inst.stream.get_length() * 1000.0:
			song_ended.emit()
			stop_music()
			time = 0.0
