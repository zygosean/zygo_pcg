@tool
extends PCGOp
class_name ScatterInsideSplineOp

@export var point_count : int = 100
@export var max_attempts_multiplier : int = 5

var _rng : RandomNumberGenerator

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	if context.splines.is_empty():
		push_warning("ScatterInsideSplineOp: No splines in context")
		return point_set
		
	_rng = RandomNumberGenerator.new()
	_rng.seed = context.pcg_seed
	
	for path in context.splines:
		var baked : PackedVector3Array = path.curve.get_baked_points()
		if baked.size() < 3:
			continue 
		_scatter_inside(point_set, context, path, baked)
	
	return point_set
	
func _scatter_inside(point_set : PCGPointSet, context : PCGContext, path : Path3D, baked : PackedVector3Array) -> void:
	var min_x := INF; var max_x := -INF
	var min_z := INF; var max_z := -INF
	for p in baked:
		min_x = minf(min_x, p.x); max_x = maxf(max_x, p.x)
		min_z = minf(min_z, p.z); max_z = maxf(max_z, p.z)
		
	var placed := 0
	var attempts := 0
	var max_attempts = point_count * max_attempts_multiplier
	
	while placed < point_count and attempts < max_attempts:
		attempts += 1
		var local_pos := Vector3(_rng.randf_range(min_x, max_x), 0.0, _rng.randf_range(min_z, max_z))
		if not PCGSplineOp.is_inside_baked(local_pos, baked):
			continue
		var world_pos : Vector3 = path.global_transform * local_pos
		if not context.bounds.has_point(world_pos):
			continue
		point_set.add_point(PCGPoint.new(Transform3D(Basis.IDENTITY, world_pos)))
		placed += 1