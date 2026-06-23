extends PCGOp
class_name SetDistanceToSplineOp

## The attribute key to write the result into.
@export var output_attribute : String = PCGTags.Attributes.Density
## Distance at which the attribute value reaches 0. Beyond this, value is clamped to 0.
@export var max_distance : float = 10.0

## If true, value is 1.0 at the spline and 0.0 at max_distance (falloff).
## If false, writes the raw distance instead.
@export var normalise : bool = true

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	if context.splines.is_empty():
		push_warning("SetDistanceToSplineOp: No splines in context")
		return point_set
	
	for point in point_set.points:
		var closest_dist := INF
		for path in context.splines:
			var local_pos : Vector3 = path.global_transform.affine_inverse() * point.get_position()
			var closest_local : Vector3 = path.curve.get_closest_point(local_pos)
			var world_closest : Vector3 = path.global_transform * closest_local
			var dist := point.get_position().distance_to(world_closest)
			if dist < closest_dist:
				closest_dist = dist
		
		var value : float
		if normalise:
			value = 1.0 - clampf(closest_dist / max_distance, 0.0, 1.0)
		else:
			value = closest_dist
			
		point_set.attribute(output_attribute, value)
		
	return point_set
		