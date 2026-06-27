## pcg/debug/pcg_profile_runner.gd
## Attach to any Node in a debug scene to run profiling on startup.
@tool
extends Node
class_name PCGProfilerRunner

@export var target_executor : NodePath = NodePath("")

@export var run_sweep : bool = true

@export var sweep_counts : Array[int] = [100, 500, 1000, 5000, 10000]

func _ready() -> void:
	# ── Resolve executor ──────────────────────────
	var executor : PCGExecutor
	if target_executor != NodePath():
		executor = get_node(target_executor) as PCGExecutor
	else:
		executor = _find_executor(get_tree().root)

	if executor == null:
		push_error("PCGProfilerRunner: No PCGExecutor found in the scene.")
		return

	if executor.pipeline == null:
		push_error("PCGProfilerRunner: PCGExecutor has no pipeline assigned.")
		return
		
	# ── Build context from the executor's settings ────────────────────


	var context := _make_context(executor)

	PCGProfiler.profile(executor.pipeline, context, executor.name)

		# ── Optional sweep ───────────────────────────────────────────────
	if run_sweep and not sweep_counts.is_empty():
		# Find the first scatter-like op to mutate point_count, if any.
		var scatter_op := _find_scatter_op(executor.pipeline)

		if scatter_op == null:
			push_warning("PCGProfilerRunner: No op with 'point_count' found — sweep skipped.")
			return

		var original_count : int = scatter_op.point_count

		var factory := func(n: int) -> PCGContext:
			scatter_op.point_count = n
			return _make_context(executor)

		PCGProfiler.run_sweep(executor.pipeline, factory, sweep_counts, "point_count")

		# Restore so the scene isn't mutated permanently.
		scatter_op.point_count = original_count

# ── Helpers ──────────────────────────────────────────────────────────────────

func _make_context(executor: PCGExecutor) -> PCGContext:
	var c := PCGContext.new()
	c.pcg_seed = executor.pcg_seed
	c.bounds   = executor.bounds
	c.splines  = executor.spline_override
	return c


func _find_executor(node: Node) -> PCGExecutor:
	if node is PCGExecutor:
		return node
	for child in node.get_children():
		var found := _find_executor(child)
		if found:
			return found
	return null


## Finds the first op in the pipeline that has a `point_count` property.
func _find_scatter_op(pipeline: PCGPipeline) -> Object:
	for op in pipeline.ops:
		if op != null and "point_count" in op:
			return op
	return null