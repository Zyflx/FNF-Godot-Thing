extends Node2D

# cameras
@onready var cam_hud:CanvasLayer = CanvasLayer.new()
@onready var cam_notes:CanvasLayer = CanvasLayer.new()

# objects
const StrumNote_Node = preload('res://game/objects/note_objects/StrumNote.tscn')
const Note_Node = preload('res://game/objects/note_objects/Note.tscn')

# strum groups
var player_strums:Array[StrumNote] = []
var cpu_strums:Array[StrumNote] = []

# controls
var keys_array:Array[String] = ['A', 'S', 'K', 'L']
# var last_key:int = 0 # unused

# data
var song_data
var note_data

# note stuff
var notes:Array[Note] = []

# rating stuff
enum RatingData {UNDEFINED = 0, TIER1 = 1, TIER2 = 2, TIER3 = 3, TIER4 = 4}

var rating_data:Dictionary = {
	RatingData.TIER4: ['sick', 45, 1, 350, 0.023], # name, timing window, accuracy modifier, score, health gain
	RatingData.TIER3: ['good', 90, 0.75, 200, 0.023],
	RatingData.TIER2: ['bad', 135, 0.4, 100, 0.015],
	RatingData.TIER1: ['shit', 166, 0.15, 50, 0.01],
	RatingData.UNDEFINED: ['undefined', 0, 0, 0, 0]
}

# stats
var score:int = 0
var misses:int = 0

# ui
var game_ui:GameUI

# music
var stream_inst:AudioStreamPlayer
var stream_voices:AudioStreamPlayer

func _ready() -> void:
	# this is only here because i didnt feel like going into the project settings lol
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	song_data = Conductor.parse_json('minacious')
	
	Conductor.init_music(song_data)
	Conductor.play_music()
	Conductor.set_bpm(song_data.bpm)
	
	generate_chart(song_data)
	
	# print([song_data.song, Conductor.bpm, get_tree().current_scene.name])
	
	cam_notes.layer = -2
	cam_hud.layer = -1
	add_child(cam_notes)
	add_child(cam_hud)
	
	game_ui = GameUI.new()
	cam_hud.add_child(game_ui)
	
	for i in 8:
		var strum_note:StrumNote = StrumNote_Node.instantiate()
		strum_note.dir = i
		strum_note.is_player = i > 3
		if i > 3: player_strums.append(strum_note)
		else: cpu_strums.append(strum_note)
		cam_notes.add_child(strum_note)

func _process(_delta:float) -> void:
	# note spawning
	if note_data != null:
		while note_data.size() > 0 and note_data[0][0] - Conductor.time < 1800 / song_data.speed:
			if note_data[0][0] - Conductor.time > 1800 / song_data.speed:
				break
			
			var new_note:Note = Note_Node.instantiate()
			new_note.is_sustain = note_data[0][2]
			new_note.sustain_length = note_data[0][3]
			new_note.time = note_data[0][0]
			new_note.data = note_data[0][1] % 4
			new_note.must_hit = note_data[0][4]
			new_note.spawned = true
			note_data.pop_at(0)
			notes.append(new_note)
			notes.sort_custom(sort_notes)
			cam_notes.add_child(new_note)
			
	if notes != null and notes.size() > 0:
		for note in notes:
			if note != null and note.spawned:
				var strum:StrumNote = player_strums[note.data] if note.must_hit else cpu_strums[note.data]
				
				note.position.x = strum.position.x
				note.position.y = strum.position.y + (Conductor.time - note.time) * (0.45 * song_data.speed)
					
				if not note.must_hit and note.was_good_hit:
					cpu_note_hit(note)
				
				if note.can_cause_miss:
					note_miss(note)
					
func player_note_hit(note:Note) -> void:
	var diff:float = absf(note.time - Conductor.time)
	spawn_rating(diff)
	player_strums[note.data].play_anim(player_strums[note.data].dir_to_name() + ' confirm')
	destroy_note(note)
					
func cpu_note_hit(note:Note) -> void:
	cpu_strums[note.data].play_anim(cpu_strums[note.data].dir_to_name() + ' confirm')
	cpu_strums[note.data].reset_time = 0.10
	destroy_note(note)
					
func note_miss(note:Note) -> void:
	misses += 1
	game_ui.update_accuracy(RatingData.UNDEFINED, true)
	destroy_note(note)
	
func destroy_note(note:Note) -> void:
	note.spawned = false
	notes.remove_at(notes.find(note))
	note.queue_free()
	
func spawn_rating(diff:float) -> void:
	var rating:RatingData = get_rating(diff)
	
	if rating == RatingData.UNDEFINED: return
	
	score += rating_data[rating][3]
	game_ui.update_accuracy(rating)
	
func start_countdown() -> void:
	pass
	
func generate_chart(data) -> void:
	note_data = []
	for sec in data.notes:
		for note in sec.sectionNotes:
			var time:float = maxf(0, note[0])
			var sustain_length:float = maxf(0, note[2])
			var is_sustain:bool = sustain_length > 0
			var n_data:int = int(note[1])
			var must_hit:bool = sec.mustHitSection if note[1] <= 3 else not sec.mustHitSection
			
			note_data.append([time, n_data, is_sustain, sustain_length, must_hit])
			note_data.sort()
			# print(note_data)
		
func _input(event) -> void:
	if event is InputEventKey:
		var key_str:String = OS.get_keycode_string(event.keycode)
		var key:int = get_key(key_str)
		
		if key < 0: return
		
		var control_array:Array[bool] = [
			Input.is_action_just_pressed('NoteLeft'),
			Input.is_action_just_pressed('NoteDown'),
			Input.is_action_just_pressed('NoteUp'),
			Input.is_action_just_pressed('NoteRight')
		]
		
		var hittable_notes:Array[Note] = []
		
		for i in notes:
			if i != null and i.spawned and i.must_hit and i.can_be_hit and i.data == key and not i.was_good_hit and not i.can_cause_miss:
				hittable_notes.append(i)
		
		if control_array[key]:
			if hittable_notes.size() > 0:
				var note:Note = hittable_notes[0]
				
				if hittable_notes.size() > 1:
					hittable_notes.sort_custom(sort_notes)
					
					var behind_note:Note = hittable_notes[1]
					
					if absf(behind_note.time - note.time) < 2.0:
						destroy_note(behind_note)
					elif behind_note.data == note.data and behind_note.time < note.time:
						note = behind_note
				
				player_note_hit(note)
			
		if event.pressed:
			if hittable_notes.size() == 0:
				player_strums[key].play_anim(player_strums[key].dir_to_name() + ' press')
		else:
			player_strums[key].play_anim('static')
	
func get_key(key:String) -> int:
	for i in keys_array.size():
		if keys_array[i] == key:
			return i
	return -1
	
func get_rating(diff:float = 0.0) -> RatingData:
	for i in rating_data.keys():
		if diff <= rating_data[i][1]:
			return i
	return RatingData.UNDEFINED
	
func sort_notes(a:Note, b:Note) -> bool:
	return a.time < b.time
