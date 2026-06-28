@tool
extends PCGOp
class_name SetSplineProgressOp

@export var output_attribute : String = PCGTags.Attributes.SplineProgress

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	if context.splines.is_empty():
		push_warning("SetSplineProgressOp: No splines in context")
		return point_set
		
	for point in point_set.points:
		var local_pos : Vector3
		var closest_offset = INF
		var closest_length := 1.0 # avoid divide by zero
		
		for path in context.splines:
			var length := path.curve.get_baked_length()
			if length <= 0.0:
				continue
			var lp : Vector3 = path.global_transform.affine_inverse() * point.get_position()
			var offset : float = path.curve.get_closest_offset(lp)
			var closest_world : Vector3 = path.global_transform * path.curve.sample_baked(offset)
			var dist := point.get_position().distance_to(closest_world)
			if dist < closest_offset:
				closest_offset = dist
				local_pos = lp
				#store progress for path
				var progress := offset / length
				point.set_attribute(output_attribute, progress)
				closest_length = path.curve.get_baked_length()
	
	return point_set
