@tool
extends Resource
class_name PCGOp

@export var enabled : bool = true

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	push_warning("PCGOp.execute() not implemented in: " + get_script().resource_path)
	return point_set