## pcg/debug/pcg_profiler.gd
## Standalone profiling utility for PCGPipeline.
##
## Usage (from any scene script):
##   PCGProfiler.run_single(pipeline, context)
##   PCGProfiler.run_sweep(pipeline, context_factory, sweep_values, sweep_label)

@tool
class_name PCGProfiler


# ─────────────────────────────────────────────
#  Data Structures
# ─────────────────────────────────────────────
class OpResult:
	var op_name     : String
	var points_in   : int
	var points_out  : int
	var time_us     : int # in microseconds
	func _to_string() -> String:
		return "%-4s | in: %5d -> out: %5d | %6d µs" % [op_name, points_in, points_out, time_us]
		
class RunResult:
	var label       : String = ""
	var op_results  : Array[OpResult] = []
	var total_us    : int = 0
	
	func print_report():
		print("┌── PCG Profile: %s " % label + "─".repeat(max(0, 60 - label.length())) + "┐")
		for r in op_results:
			print("|  " + str(r))
		print("├" + "─".repeat(72) + "┤")
		print("│  TOTAL: %d µs  (%.2f ms)" % [total_us, total_us / 1000.0])
		print("└" + "─".repeat(72) + "┘")
		
# ─────────────────────────────────────────────
#  Core — single pipeline run with per-op timing
# ─────────────────────────────────────────────

## Runs [pipeline] against [context] and returns a [RunResult].
## Does NOT modify the pipeline or context.

static func run_single(pipeline: PCGPipeline, context: PCGContext, label : String = "") -> RunResult:
	var run := RunResult.new()
	run.label = label if label != "" else "unlabelled"
	
	var point_set := PCGPointSet.new()
	var pipeline_start := Time.get_ticks_usec()
	
	for op in pipeline.ops:
		if op == null or not op.enabled:
			continue

		var script := op.get_script() as Script
		var op_name : String = op.get_script().resource_path.get_file() if script else op.get_class()
		var before_count := point_set.get_count()
		var t0 := Time.get_ticks_usec()
		
		point_set = op.execute(point_set, context)
		if point_set == null:
			push_error("PCGProfiler: op '%s' returned null — aborting." % op_name)
			break
		
		var t1 := Time.get_ticks_usec()
		var r := OpResult.new()
		r.op_name       = op_name
		r.points_in     = before_count
		r.points_out    = point_set.get_count()
		r.time_us       = t1 - t0
		run.op_results.append(r)
	
	run.total_us = Time.get_ticks_usec() - pipeline_start
	return run
	
# ─────────────────────────────────────────────
#  Sweep — vary a single parameter and print a table
# ─────────────────────────────────────────────

## Runs the pipeline multiple times.
## [param context_factory] is a Callable(value) -> PCGContext.
## [param sweep_values] is an Array of values passed to the factory one by one.
## [param sweep_label] names the column being swept (e.g. "point_count").
##
## Example:
##   PCGProfiler.run_sweep(
##       pipeline,
##       func(n): var c = PCGContext.new(); c.bounds = AABB(...); return c,
##       [100, 500, 1000, 5000],
##       "point_count"
##   )

static func run_sweep(
		pipeline: PCGPipeline,
		context_factory: Callable,
		sweep_values: Array,
		sweep_label: String = "value") -> void:

	print("\n═══ PCG Sweep: %s ═══" % sweep_label)
	print("%-20s | %-10s | %s" % [sweep_label, "total_ms", "op breakdown (µs)"])
	print("─".repeat(80))

	for val in sweep_values:
		var context : PCGContext = context_factory.call(val)
		var result := run_single(pipeline, context, "%s=%s" % [sweep_label, str(val)])

		var breakdown := ""
		for r in result.op_results:
			breakdown += "%s:%dµs  " % [r.op_name.get_basename(), r.time_us]

		print("%-20s | %10.3f | %s" % [str(val), result.total_us / 1000.0, breakdown])

	print("─".repeat(80))
	
# ─────────────────────────────────────────────
#  Convenience — print immediately
# ─────────────────────────────────────────────

## Run and immediately print the report.
static func profile(pipeline: PCGPipeline, context: PCGContext, label: String = "") -> RunResult:
	var result := run_single(pipeline, context, label)
	result.print_report()
	return result