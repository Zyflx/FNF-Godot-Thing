extends Label

var current_fps:float = 0

func _ready() -> void:
	position = Vector2(10, 10);

func _process(_delta:float) -> void:
	# thanks to srt and lavender for telling me about the built in functions for the fps and byte formatting
	
	current_fps = Engine.get_frames_per_second()
	
	var mem:String = String.humanize_size(OS.get_static_memory_usage())
	var mem_peak:String = String.humanize_size(OS.get_static_memory_peak_usage())
	var scene:String = 'None' if get_tree().current_scene == null else get_tree().current_scene.name
	
	text = 'FPS: ' + str(current_fps) + '\nMemory: ' + mem + ' / ' + mem_peak + '\nScene: ' + scene
