@tool
extends PCGSplineFilterOp
class_name FilterBySplineProximityOp

@export var max_distance : float = 10.0

func _apply_kernel(positions : PackedVector3Array, path : Path3D, mask : PackedByteArray):
	var baked := path.curve.get_baked_points()
	var to_local := path.global_transform.affine_inverse()
	PCGKernels.mark_within_distance(positions, baked, to_local, max_distance, mask)

#func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
#	if context.splines.is_empty():
#		push_warning("FilterBySplineProximityOp: No splines in context")
#		return point_set
#		
#	var predicate := func(point : PCGPoint) -> bool:
#		for path in context.splines:
#			var local_pos : Vector3 = path.global_transform.affine_inverse() * point.get_position()
#			var closest_local : Vector3 = path.curve.get_closest_point(local_pos)
#			var world_closest : Vector3 = path.global_transform * closest_local
#			var dist := point.get_position().distance_to(world_closest)
#			if dist <= max_distance:
#				return not invert 
#				
#		return invert
#		
#	return point_set.filter(predicate)