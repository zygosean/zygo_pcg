@tool
extends Node3D
class_name PCGRunnerRealizer

## Listens to a PCGExecutor and drives a list of realizers, owning the
## lifecycle of all spawned content. Regenerating clears previous output.

@export var executor : PCGExecutor:
	set(value):
		_disconnect_executor()
		executor = value
		_connect_executor()
		
@export var realizers : Array[PCGRealizer] = []

## When true, realize automatically whenever the executor finishes.
@export var auto_realize : bool = true

@export_tool_button("Realize Now", "Play") var _realize_btn : Callable = _realize_last
@export_tool_button("Clear Output", "Remove") var _clear_btn : Callable = clear_output

const _OUTPUT_NAME = "PCGRunnerRealizer_Output"
var _output_root : Node3D 

func _ready():
	_connect_executor()
		
func _connect_executor() -> void:
	if executor and not executor.generation_complete.is_connected(_on_generation_complete):
		executor.generation_complete.connect(_on_generation_complete)
	
func _disconnect_executor() -> void:
	if executor and executor.generation_complete.is_connected(_on_generation_complete):
		executor.generation_complete.disconnect(_on_generation_complete)
	
func _on_generation_complete(point_set : PCGPointSet) -> void:
	if auto_realize:
		realize(point_set)

func _realize_last() -> void:
	if executor:
		realize(executor.get_last_result())

## Clear previous output and run every enabled realizer.
func realize(point_set : PCGPointSet) -> void:
	clear_output()
	if point_set == null or point_set.is_empty():
		print("PCGRunnerRealizer: No points to realize.")
		return
	
	var root := _ensure_output_root()
	var context := _make_context()
	
	for r in realizers:
		if r == null or not r.enabled:
			continue
		r.realize(point_set, root, context)
		
	print("PCGRealizationRunner: realized %d points via %d realizer(s)." %[point_set.get_count(), realizers.size()])
	
func clear_output() -> void:
	if _output_root and is_instance_valid(_output_root):
		_output_root.queue_free()
		_output_root = null
	# Also catch a stale node left from a previous session.
	var existing := get_node_or_null(_OUTPUT_NAME)
	if existing:
		existing.queue_free()
	

func _ensure_output_root() -> Node3D:
	_output_root = Node3D.new()
	_output_root.name = _OUTPUT_NAME
	add_child(_output_root)
	# Keep output visible/editable in the tree while authoring in-editor.
	if Engine.is_editor_hint() and get_tree():
		_output_root.owner = get_tree().edited_scene_root
	return _output_root
	
func _make_context() -> PCGContext:
	var ctx := PCGContext.new()
	if executor:
		ctx.pcg_seed = executor.pcg_seed
		ctx.bounds = executor.bounds
	return ctx