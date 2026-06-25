@tool
extends PCGSplineOp
class_name ScatterOnSplineOp

@export var radius : float = 5.0
@export var points_per_sample : int = 3

var _rng : RandomNumberGenerator

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	_rng = RandomNumberGenerator.new()
	_rng.seed = context.pcg_seed
	return super.execute(point_set, context)
	
func on_spline_sample(point_set : PCGPointSet, _context : PCGContext, xform : Transform3D, _progress : float):
	for i in points_per_sample:
		var angle := _rng.randf() * TAU
		var dist := sqrt(_rng.randf()) * radius
		var offset := (xform.basis.x * cos(angle) + xform.basis.z * sin(angle)) * dist
		var pos := xform.origin + offset
		if not clip_to_bounds or _context.bounds.has_point(pos):
			var point := PCGPoint.new(Transform3D(xform.basis, pos))
			point.set_attribute(PCGTags.Attributes.Density, 1.0 - (dist / radius))
			point_set.add_point(point)