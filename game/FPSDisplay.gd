extends Label

var times:Array[float] = [];
var current_fps:int = 0

func _ready() -> void:
	position = Vector2(10, 10);

func _process(_delta:float) -> void:
	var time:float = Time.get_ticks_msec()
	times.append(time)
	
	while times.size() > 0 and times[0] <= time - 1000:
		times.pop_front()
		
	if DisplayServer.VSYNC_ENABLED:
		var refresh_rate:float = DisplayServer.screen_get_refresh_rate()
		current_fps = refresh_rate if times.size() > refresh_rate else times.size()
	elif Engine.max_fps > 0: # if vsync is off (you would have to have vsync off to even change this so)
		current_fps = Engine.max_fps if times.size() > Engine.max_fps else times.size()
	
	var mem:String = Util.format_bytes(OS.get_static_memory_usage(), true)
	var mem_peak:String = Util.format_bytes(OS.get_static_memory_peak_usage(), true)
	
	text = 'FPS: ' + str(current_fps) + '\nMemory: ' + mem + ' / ' + mem_peak + '\nScene: ' + get_tree().current_scene.name
