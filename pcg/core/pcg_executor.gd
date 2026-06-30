@tool
extends Node
class_name PCGExecutor

signal generation_complete(point_set : PCGPointSet)

@export var pipeline: PCGPipeline
@export var pcg_seed : int = 0
@export var bounds : AABB = AABB(Vector3.ZERO, Vector3(100,10,100))
@export var auto_generate_on_ready : bool = true
@export var spline_override : Array[Path3D] = []

@export_tool_button("Regenerate", "RefreshSmall") var _regenerate_btn : Callable = _regenerate


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
	context.splines = spline_override if not spline_override.is_empty() else PCGSpatialQuery.find_paths_in_bounds(get_tree(), bounds)
	context.collision_meshes = PCGSpatialQuery.find_concave_shape_in_bounds(get_tree(), bounds)
#	var world := get_viewport().get_world_3d() if get_viewport() else null
#	context.physics_space = world.direct_space_state if world else null
	
	if is_inside_tree():
		var world := get_viewport().get_world_3d()
		if world:
			var space_rid := world.space
			if space_rid.is_valid():
				context.physics_space = PhysicsServer3D.space_get_direct_state(space_rid)
	
	print("PCGExecutor: found %d splines, bounds = %s" % [context.splines.size(), bounds])
	
	_last_result = pipeline.run(context)
	generation_complete.emit(_last_result)
	return _last_result
	
func get_last_result() -> PCGPointSet:
	return _last_result
	
func _regenerate() -> void:
	pcg_seed = randi()
	generate()