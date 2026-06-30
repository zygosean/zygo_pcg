@tool
extends PCGOp
class_name ProjectToSurfaceOp

## Raycasts downward from each point, snapping it to the surface and writing
## the hit normal as an attribute. Points that miss are optionally removed.

@export var ray_length : float = 500.0
@export var collision_mask : int = 1
@export var snap_to_surface : bool = true
@export var remove_missed : bool = true
@export var normal_attribute : String = PCGTags.Attributes.Normal

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	if context.physics_space != null:
		return _project_physics(point_set, context)
	elif not context.collision_meshes.is_empty():
		return _project_trimesh(point_set, context)	
	else:
		push_warning("ProjectToSurfaceOp: No physics space in context")
		return point_set
		
func _project_physics(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	var params := PhysicsRayQueryParameters3D.new()
	params.collision_mask = collision_mask
	
	var to_keep : Array[PCGPoint] = []
	for point in point_set.points:
		var origin := point.get_position() + Vector3.UP * (ray_length * 0.5)
		params.from = origin
		params.to = origin + Vector3.DOWN * ray_length
		var result :  = context.physics_space.intersect_ray(params)
		if result.is_empty():
			if not remove_missed:
				to_keep.append(point)
			continue
	
		if snap_to_surface:
			point.transform.origin = result.get("position")
		point.set_attribute(normal_attribute, result.get("normal"))
		to_keep.append(point)
	
	point_set.points = to_keep
	return point_set
	
func _project_trimesh(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	# Pre-extract all face data from all collision shapes
	var all_faces : Array = []
	for cs in context.collision_meshes:
		var shape := cs.shape as ConcavePolygonShape3D
		all_faces.append({"faces": shape.get_faces(), "xform": cs.global_transform})
	
	var to_keep : Array[PCGPoint] = []
	for point in point_set.points:
		var hit := _cast_ray_against_faces(all_faces, point.get_position())
		if hit.is_empty():
			if not remove_missed:
				to_keep.append(point)
			continue
		if snap_to_surface:
			point.transform.origin = hit.get("position")
		point.set_attribute(normal_attribute, hit.get("normal"))
		to_keep.append(point)
		
	point_set.points = to_keep	
	return point_set
	
func _cast_ray_against_faces(all_faces : Array, world_pos : Vector3) -> Dictionary:
	var ray_from := world_pos + Vector3.UP * (ray_length * 0.5)
	var ray_dir := Vector3.DOWN
	
	var best_dist := INF
	var best_pos := Vector3.ZERO
	var best_normal := Vector3.UP
	
	for entry in all_faces:
		var faces : PackedVector3Array = entry.get("faces")
		var xform : Transform3D = entry.get("xform")
		var face_count := faces.size() / 3
		for i in face_count:
			var a := xform * faces[i * 3]
			var b := xform * faces[i * 3 + 1]
			var c := xform * faces[i * 3 + 2]
			var result = Geometry3D.ray_intersects_triangle(ray_from, ray_dir, a, b, c)
			if result == null:
				continue
				
			var dist := ray_from.distance_to(result)
			if dist < best_dist:
				best_dist = dist
				best_pos = result
				best_normal = (b - a).cross(c - a).normalized()
				
	if best_dist == INF:
		return {}
	return { "position": best_pos, "normal": best_normal }
