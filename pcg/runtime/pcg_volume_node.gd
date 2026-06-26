@tool
extends Node3D
class_name PCGVolumeNode

@export var size : Vector3 = Vector3(100,100,100):
	set(v):
		size = v
		_push_bounds_to_executors()
		
@export var pipeline : PCGPipeline:
	set(v): 
		pipeline = v
		var ex := get_executor()
		if ex:
			ex.pipeline = v

@export_tool_button("Regenerate", "RefreshSmall") var _regenerate_btn : Callable = _regenerate
		
func get_executor() -> PCGExecutor:
	for child in get_children():
		if child is PCGExecutor:
			return child
	return null
	
func _ready() -> void:
	set_notify_transform(true)
	_push_bounds_to_executors(true)

func _notification(what : int) -> void:
	if what & NOTIFICATION_TRANSFORM_CHANGED:
		_push_bounds_to_executors(true)

func _push_bounds_to_executors(and_generate : bool = false):
	if not is_inside_tree():
		return
	var aabb := AABB(global_position - size * 0.5, size)
	for child in get_children():
		if child is PCGExecutor:
			child.bounds = aabb
			if and_generate:
				child.generate()
				
## Re-seeds and regenerates from the volume's CURRENT world position.
func _regenerate() -> void:
	var ex := get_executor()
	if ex:
		ex.pcg_seed = randi()
	_push_bounds_to_executors(true)