extends Node3D

func _ready() -> void:

	var curve := Curve3D.new()

## Curve test
#	curve.add_point(Vector3(5, 0, 10), Vector3.ZERO, Vector3(5, 0, 5))
#	curve.add_point(Vector3(25, 0, 25), Vector3(-8, 0, 0), Vector3(8, 0, 0))
#	curve.add_point(Vector3(45, 0, 40), Vector3(-5, 0, -5), Vector3.ZERO)

## closed loop curve for testing FilterInsideSplineOp
	curve.add_point(Vector3(10, 0, 10))
	curve.add_point(Vector3(40, 0, 10))
	curve.add_point(Vector3(40, 0, 40))
	curve.add_point(Vector3(10, 0, 40))
	curve.add_point(Vector3(10, 0, 10))  # closes back to start
	
	var path := Path3D.new()
	path.curve = curve
	add_child(path)
	
	# --- Build pipeline in code ---
#	var scatter := ScatterPointsOp.new()
#	scatter.point_count = 200

#	var spline_op := SampleSplineOp.new()

	var scatter_on_spline := ScatterOnSplineOp.new()
	scatter_on_spline.sample_step = 2.0
	scatter_on_spline.radius = 1.0
	scatter_on_spline.points_per_sample = 4
	
	var scatter_inside_spline := ScatterInsideSplineOp.new()

#	var density_filter := FilterByDensityOp.new()
#	density_filter.min_density = 0.3

	var filter_by_spline_prox := FilterInsideSplineOp.new()
	#filter_by_spline_prox.max_distance = 10.5
	filter_by_spline_prox.invert = false

	var pipeline := PCGPipeline.new()
	pipeline.ops.assign([scatter_inside_spline, filter_by_spline_prox])

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
