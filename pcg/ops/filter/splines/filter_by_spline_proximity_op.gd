extends PCGOp
class_name FilterBySplineProximityOp

@export var max_distance : float = 10.0
## If true, keeps points WITHIN max_distance. If false, keeps points OUTSIDE.
@export var invert: bool = false

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	if context.splines.is_empty():
		push_warning("FilterBySplineProximityOp: No splines in context")
		return point_set
		
	var predicate := func(point : PCGPoint) -> bool:
		for path in context.splines:
			var local_pos : Vector3 = path.global_transform.affine_inverse() * point.get_position()
			var closest_local : Vector3 = path.curve.get_closest_point(local_pos)
			var world_closest : Vector3 = path.global_transform * closest_local
			var dist := point.get_position().distance_to(world_closest)
			if dist <= max_distance:
				return not invert 
				
		return invert
		
	return point_set.filter(predicate)