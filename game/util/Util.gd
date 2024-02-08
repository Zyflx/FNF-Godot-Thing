extends Node

func round_decimal(val:float, decimals:int) -> float:
	var mult:float = 1
	for i in decimals: mult *= 10
	return round(val * mult) / mult
	
func format_bytes(bytes:float, add_units:bool = false):
	const units:Array[String] = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB']
	var cur_unit:int = 0
	while bytes >= 1024 and cur_unit < units.size() - 1:
		bytes /= 1024
		cur_unit += 1
	return str(round_decimal(bytes, 2)) + units[cur_unit] if add_units else round_decimal(bytes, 2)
	
