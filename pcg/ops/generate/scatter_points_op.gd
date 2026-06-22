extends PCGOp
class_name ScatterPointsOp

@export var point_count : int = 100

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	var rng := RandomNumberGenerator.new()
	rng.seed = context.pcg_seed
	
	var b := context.bounds
	for i in point_count:
		var pos := Vector3(
		b.position.x + rng.randf() * b.size.x,
		b.position.y + rng.randf() * b.size.y,
		b.position.z + rng.randf() * b.size.z
		)
		var point := PCGPoint.new(Transform3D(Basis.IDENTITY, pos))
		point.set_attribute(PCGTags.Attributes.Density, rng.randf())
		point_set.add_point(point)
	
	return point_set
	