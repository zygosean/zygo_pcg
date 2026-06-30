extends RefCounted
class_name PCGSpatialQuery

static func find_paths_in_bounds(tree : SceneTree, bounds : AABB) -> Array[Path3D]:
	var result : Array[Path3D] = []
	if tree == null:
		return result
		
	var scene_root : Node
	if Engine.is_editor_hint():
		scene_root = Engine.get_singleton("EditorInterface").get_edited_scene_root()
	else:
		scene_root = tree.current_scene
	
	if scene_root == null:
		return result

	#var all_paths : Array[Node] = tree.current_scene.find_children("*", "Path3D", true, false)
	#print("PCGSpatialQuery: found %d paths in scene" % [all_paths.size()])
	print("PCGSpatialQuery: Current scene: ", scene_root.get_name())
	for node in scene_root.find_children("*", "Path3D", true, false):
		var path := node as Path3D
		if path.curve == null or path.curve.point_count < 2:
			print("PCGSpatialQuery: ignoring path with %d points" % [path.curve.point_count])
			continue
		if path.curve.get_baked_length() <= 0:
			print("PCGSpatialQuery: ignoring path with zero length")
			continue
		var found_point_in_bounds := false
		for point in path.curve.get_baked_points():
			var world_point := path.global_transform * point
			if bounds.has_point(world_point):
				found_point_in_bounds = true
				break
		if not found_point_in_bounds:
			print("PCGSpatialQuery: ignoring path %s with no points in bounds %s" % [path.name, bounds])
		else:
			result.append(path)
	return result
	
static func find_concave_shape_in_bounds(tree : SceneTree, bounds : AABB) -> Array[CollisionShape3D]:
	var result : Array[CollisionShape3D] = []
	if tree == null:
		return result
		
	var scene_root : Node
	if Engine.is_editor_hint():
		scene_root = Engine.get_singleton("EditorInterface").get_edited_scene_root()
	else:
		scene_root = tree.current_scene
		
	if scene_root == null:
		return result

	for node in scene_root.find_children("*", "CollisionShape3D", true, false):
		var cs:= node as CollisionShape3D
		if not cs.shape is ConcavePolygonShape3D:
			continue
			# Check if any face of the shape's AABB overlaps our bounds	
		var shape_aabb := cs.shape.get_debug_mesh().get_aabb()
		var world_aabb := AABB(cs.global_transform * shape_aabb.position, shape_aabb.size)
		if bounds.intersects(world_aabb):
			result.append(cs)
	
	return result