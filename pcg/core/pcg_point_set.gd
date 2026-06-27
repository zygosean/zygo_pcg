@tool
extends RefCounted
class_name PCGPointSet

var points : Array[PCGPoint] = []

func add_point(point : PCGPoint):
	points.append(point)
	
func remove_point(point : PCGPoint):
	points.erase(point)
	
func get_count() -> int:
	return points.size()
	
func is_empty() -> bool:
	return points.is_empty()
	
func filter(predicate : Callable) -> PCGPointSet:
	var result := PCGPointSet.new()
	for p in points:
		if predicate.call(p):
			result.add_point(p)
	return result
	
func get_positions() -> PackedVector3Array:
	var result := PackedVector3Array()
	result.resize(points.size())
	for i in points.size():
		result[i] = points[i].get_position()
	return result	
	
func filter_by_mask(mask : PackedByteArray) -> PCGPointSet:
	var result := PCGPointSet.new()
	for i in points.size():
		if mask[i] == 1:
			result.add_point(points[i])
	return result

func clear():
	points.clear()