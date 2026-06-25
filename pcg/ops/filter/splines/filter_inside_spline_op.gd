@tool
extends PCGOp
class_name FilterInsideSplineOp

## If true, keeps points OUTSIDE the spline boundary instead.
@export var invert: bool = false

func execute(point_set: PCGPointSet, context: PCGContext) -> PCGPointSet:
	if context.splines.is_empty():
		push_warning("FilterInsideSplineOp: no splines in context.")
		return point_set
		
	var predicate := func(point: PCGPoint) -> bool:
		var pos := point.get_position()
		for path in context.splines:
			var local_pos : Vector3 = path.global_transform.affine_inverse() * pos
			var baked : PackedVector3Array = path.curve.get_baked_points()
			if PCGSplineOp.is_inside_baked(local_pos, baked):
				return not invert
		return invert
			
	return point_set.filter(predicate)
