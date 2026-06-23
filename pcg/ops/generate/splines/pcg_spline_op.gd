extends PCGOp
class_name PCGSplineOp

@export var sample_step: float = 1.0
@export var clip_to_bounds: bool = true

func execute(point_set: PCGPointSet, context: PCGContext) -> PCGPointSet:
	if context.splines.is_empty():
		push_warning(get_script().resource_path + ": no splines found in bounds.")
		return point_set

	for path in context.splines:
		var curve: Curve3D = path.curve
		var length: float = curve.get_baked_length()
		var t := 0.0
		while t <= length:
			var xform := curve.sample_baked_with_rotation(t, true)
			xform.origin = path.global_transform * xform.origin
			xform.basis = path.global_transform.basis * xform.basis
			if not clip_to_bounds or context.bounds.has_point(xform.origin):
				on_spline_sample(point_set, context, xform, t / length)
			t += sample_step

	return point_set

## Override in subclasses. Called once per sample point along each spline.
## [param progress] is 0.0 → 1.0 along the spline length.
func on_spline_sample(point_set: PCGPointSet, context: PCGContext, xform: Transform3D, progress: float) -> void:
	push_warning("PCGSplineOp.on_spline_sample() not implemented in: " + get_script().resource_path)

static func is_inside_baked(local_pos : Vector3, baked : PackedVector3Array) -> bool:
	if baked.size() < 3:
		return false
	var px := local_pos.x
	var pz := local_pos.z
	var crossings := 0
	var count := baked.size()
	for i in count:
		var a := baked[i]
		var b := baked[(i + 1) % count]
		if (a.z <= pz and b.z > pz) or (b.z <= pz and a.z > pz):
			var t := (pz - a.z) / (b.z - a.z)
			if a.x + t * (b.x - a.x) > px:
				crossings += 1
	return (crossings % 2) == 1