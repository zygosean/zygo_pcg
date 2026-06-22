extends Node
class_name PCGExecutor

signal generation_complete(point_set : PCGPointSet)

@export var pipeline: PCGPipeline
@export var pcg_seed : int = 0
@export var bounds : AABB = AABB(Vector3.ZERO, Vector3(100,10,100))
@export var auto_generate_on_ready : bool = true

var _last_result : PCGPointSet = null

func _ready() -> void:
	if auto_generate_on_ready:
		generate()
		
func generate() -> PCGPointSet:
	if pipeline == null:
		push_error("PCGExecutor: No pipeline assigned.")
		return null
	
	var context = PCGContext.new()
	context.pcg_seed = pcg_seed
	context.bounds = bounds
	context.splines = PCGSpatialQuery.find_paths_in_bounds(get_tree(), bounds)
	
	_last_result = pipeline.run(context)
	generation_complete.emit(_last_result)
	return _last_result
	
func get_last_result() -> PCGPointSet:
	return _last_result