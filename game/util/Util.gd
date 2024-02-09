extends Node

func round_decimal(val:float, decimals:int) -> float:
	var mult:float = 1
	for i in decimals: mult *= 10
	return round(val * mult) / mult
	
func get_inst(song:String) -> AudioStreamOggVorbis:
	var path:String = 'res://assets/songs/' + song.replace(' ', '-').to_lower() + '/audio/Inst.ogg'
	if FileAccess.file_exists(path): return load(path)
	return null
	
func get_voices(song:String) -> AudioStreamOggVorbis:
	var path:String = 'res://assets/songs/' + song.replace(' ', '-').to_lower() + '/audio/Voices.ogg'
	if FileAccess.file_exists(path): return load(path)
	return null
