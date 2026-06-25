@tool
extends Node3D
class_name PCGDebugVisualizer

@export var executor : PCGExecutor:
	set(value):
		executor = value
		if executor and not executor.generation_complete.is_connected(_on_generation_complete):
			executor.generation_complete.connect(_on_generation_complete)
@export var point_radius : float = 0.2
@export var show_bounds : bool = true

var _mesh_instance : MeshInstance3D
var _immediate_mesh : ImmediateMesh
var _material : StandardMaterial3D

func _ready() -> void:
	_immediate_mesh = ImmediateMesh.new()

	_material = StandardMaterial3D.new()
	_material.vertex_color_use_as_albedo = true
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.mesh = _immediate_mesh
	_mesh_instance.material_override = _material
	add_child(_mesh_instance)

	if executor:
		executor.generation_complete.connect(_on_generation_complete)

func _on_generation_complete(point_set : PCGPointSet) -> void:
	_draw_points(point_set)

func _draw_points(point_set : PCGPointSet) -> void:
	_immediate_mesh.clear_surfaces()

	if point_set == null or point_set.is_empty():
		print("PCGDebugVisualizer: No points to draw.")
		return

	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	for p in point_set.points:
		var pos : Vector3 = p.get_position()
		var density : float = p.get_attribute(PCGTags.Attributes.Density, 1.0)
		var color := Color(density, 0.2, 1.0 - density)

		# Draw a small 3-axis cross at each point position
		_immediate_mesh.surface_set_color(color)
		_immediate_mesh.surface_add_vertex(pos + Vector3(point_radius, 0, 0))
		_immediate_mesh.surface_set_color(color)
		_immediate_mesh.surface_add_vertex(pos - Vector3(point_radius, 0, 0))

		_immediate_mesh.surface_set_color(color)
		_immediate_mesh.surface_add_vertex(pos + Vector3(0, point_radius, 0))
		_immediate_mesh.surface_set_color(color)
		_immediate_mesh.surface_add_vertex(pos - Vector3(0, point_radius, 0))

		_immediate_mesh.surface_set_color(color)
		_immediate_mesh.surface_add_vertex(pos + Vector3(0, 0, point_radius))
		_immediate_mesh.surface_set_color(color)
		_immediate_mesh.surface_add_vertex(pos - Vector3(0, 0, point_radius))

	_immediate_mesh.surface_end()

	if show_bounds and executor:
		_draw_bounds(executor.bounds)

	print("PCGDebugVisualizer: Drew %d points." % point_set.get_count())

func _draw_bounds(aabb : AABB) -> void:
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_immediate_mesh.surface_set_color(Color.YELLOW)

	var corners := [
		aabb.position,
		aabb.position + Vector3(aabb.size.x, 0, 0),
		aabb.position + Vector3(0, aabb.size.y, 0),
		aabb.position + Vector3(aabb.size.x, aabb.size.y, 0),
		aabb.position + Vector3(0, 0, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, 0, aabb.size.z),
		aabb.position + Vector3(0, aabb.size.y, aabb.size.z),
		aabb.position + aabb.size,
	]

	var edges := [
		[0,1],[0,2],[1,3],[2,3],  # front face
		[4,5],[4,6],[5,7],[6,7],  # back face
		[0,4],[1,5],[2,6],[3,7],  # connecting edges
	]

	for edge in edges:
		_immediate_mesh.surface_add_vertex(corners[edge[0]])
		_immediate_mesh.surface_add_vertex(corners[edge[1]])

	_immediate_mesh.surface_end()