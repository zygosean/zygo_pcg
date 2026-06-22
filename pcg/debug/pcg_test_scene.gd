extends Node3D

func _ready() -> void:
	# --- Build pipeline in code ---
	var scatter := ScatterPointsOp.new()
	scatter.point_count = 200

	var density_filter := FilterByDensityOp.new()
	density_filter.min_density = 0.4

	var pipeline := PCGPipeline.new()
	pipeline.ops.assign([scatter, density_filter])

	# --- Set up executor ---
	var executor := PCGExecutor.new()
	executor.pipeline = pipeline
	executor.pcg_seed = randi()
	executor.bounds = AABB(Vector3.ZERO, Vector3(50, 5, 50))
	executor.auto_generate_on_ready = false
	add_child(executor)

	# --- Set up visualizer ---
	var visualizer := PCGDebugVisualizer.new()
	visualizer.executor = executor
	add_child(visualizer)

	# --- Set up camera so you can see something ---
	var camera := Camera3D.new()
	camera.position = Vector3(25, 60, 80)
	camera.rotation_degrees = Vector3(-35, 0, 0)
	add_child(camera)

	# --- Run ---
	executor.generate()
