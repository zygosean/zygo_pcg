extends Resource
class_name PCGPipeline

## Ordered list of operations to execute
@export var ops: Array[PCGOp] = []

## Run all enabled ops in order, threading the point set through each.
func run(context: PCGContext) -> PCGPointSet:
	var point_set := PCGPointSet.new()
	for op in ops:
		if op == null or not op.enabled:
			continue
		point_set = op.execute(point_set, context)
		if point_set == null:
			push_error("PCGPipeline: op returned null PCGPointSet — '%s'" % op.get_script().resource_path)
			return PCGPointSet.new()
	return point_set
	
	