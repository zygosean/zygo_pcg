@tool
extends PCGOp
class_name FilterByDensityOp

@export var min_density : float = 0.3

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	var predicate := func(p : PCGPoint) -> bool:
		return p.get_attribute(PCGTags.Attributes.Density, 1.0) >= min_density
	return point_set.filter(predicate)