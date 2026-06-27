@tool
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
	
	var positions := point_set.get_positions()
	var best_distances := PackedFloat32Array()
	best_distances.resize(positions.size())
	best_distances.fill(INF)
	
	for path in context.splines:
		var baked := path.curve.get_baked_points()
		var to_local := path.global_transform.affine_inverse()
		var dists := PCGKernels.closest_distances_to_polyline(positions, baked, to_local)
		for i in dists.size():
			if best_distances[i] < dists[i]:
				best_distances[i] = dists[i]
				
		# Optionally convert raw distances to a normalised falloff
	var values := PCGKernels.distances_to_falloff(best_distances, max_distance) if normalise else best_distances
	
	# Write back into points — this loop is O(N) trivial assignments, not compute
	for i in point_set.points.size():
		point_set.points[i].set_attribute(output_attribute, values[i])
		
#	for point in point_set.points:
#		var closest_dist := INF
#		for path in context.splines:
#			var local_pos : Vector3 = path.global_transform.affine_inverse() * point.get_position()
#			var closest_local : Vector3 = path.curve.get_closest_point(local_pos)
#			var world_closest : Vector3 = path.global_transform * closest_local
#			var dist := point.get_position().distance_to(world_closest)
#			if dist < closest_dist:
#				closest_dist = dist
#		
#		var value : float
#		if normalise:
#			value = 1.0 - clampf(closest_dist / max_distance, 0.0, 1.0)
#		else:
#			value = closest_dist
#			
#		point_set.attribute(output_attribute, value)
		
	return point_set
		