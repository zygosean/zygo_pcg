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
	
func clear():
	points.clear()