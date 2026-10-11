@tool
extends Node

func scattershot(high: float, count: int, low: float = 0.0) -> Array[float]:
	var arr: Array[float] = [];
	var step = (high - low) / count;
	for i in range(count):
		arr.append(step * (i + randf()) + low)
	arr.shuffle()
	return arr;
