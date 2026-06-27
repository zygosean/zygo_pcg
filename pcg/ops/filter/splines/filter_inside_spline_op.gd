@tool
extends PCGSplineFilterOp
class_name FilterInsideSplineOp

func _apply_kernel(positions : PackedVector3Array, path : Path3D, mask : PackedByteArray):
	var baked := path.curve.get_baked_points()
	var to_local := path.global_transform.affine_inverse()
	PCGKernels.mark_inside_polygon(positions, baked, to_local, mask)
#
#func execute(point_set: PCGPointSet, context: PCGContext) -> PCGPointSet:
#	if context.splines.is_empty():
#		push_warning("FilterInsideSplineOp: no splines in context.")
#		return point_set
#		
#	var positions := point_set.get_positions()
#	var mask := PCGKernels.make_mask(positions.size())
#	
#	for path in context.splines:
#		var baked := path.curve.get_baked_points()
#		var to_local := path.global_transform.affine_inverse()
#		PCGKernels.mark_inside_polygon(positions, baked, to_local, mask)
#		
#	if invert:
#		PCGKernels.invert_mask(mask)
#		
#	var predicate := func(point: PCGPoint) -> bool:
#		var pos := point.get_position()
#		for path in context.splines:
#			var local_pos : Vector3 = path.global_transform.affine_inverse() * pos
#			var baked : PackedVector3Array = path.curve.get_baked_points()
#			if PCGSplineOp.is_inside_baked(local_pos, baked):
#				return not invert
#		return invert
#			
#	return point_set.filter_by_mask(mask)
