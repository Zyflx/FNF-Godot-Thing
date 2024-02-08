extends Node

func round_decimal(val:float, decimals:int) -> float:
	var mult:float = 1
	for i in decimals: mult *= 10
	return round(val * mult) / mult	
