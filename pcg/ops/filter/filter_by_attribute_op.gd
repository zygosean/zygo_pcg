@tool
extends PCGOp
class_name FilterByAttributeOp

@export var attribute_key : String = ""
@export var expected_value : Variant = null

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	if attribute_key.is_empty():
		push_warning("FilterByAttributeOp: attribute_key is empty, passing through.")
		return point_set
	
	var predicate := func(p: PCGPoint) -> bool:	
		return p.get_attribute(attribute_key) == expected_value
	return point_set.filter(predicate)