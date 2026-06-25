@tool
extends PCGSplineOp
class_name SampleSplineOp

func on_spline_sample(point_set : PCGPointSet, _context : PCGContext, xform : Transform3D, _progress : float):
	point_set.add_point(PCGPoint.new(xform))

#func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
#	if context.splines.is_empty():
#		push_warning("SampleSplineOp: No splines in found in bounds")
#		return point_set
#		
#	for path in context.splines:
#		var curve : Curve3D = path.curve
#		var length : float = curve.get_baked_length()
#		var t := 0.0
#		while t < length:
#			var xform := curve.sample_baked_with_rotation(t, true)
#			xform.origin = path.global_transform * xform.origin
#			if not clip_to_bounds or context.bounds.has_point(xform.origin):
#				point_set.add_point(PCGPoint.new(xform))
#			t+= sample_step
#			
#	return point_set