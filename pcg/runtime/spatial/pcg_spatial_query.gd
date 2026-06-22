extends RefCounted
class_name PCGSpatialQuery

static func find_paths_in_bounds(tree : SceneTree, bounds : AABB) -> Array[Path3D]:
	var result : Array[Path3D] = []
	for node in tree.current_scene.find_children("*", "Path3D", true, false):
		var path := node as Path3D
		if path.curve == null:
			continue
		for point in path.curve.get_baked_points():
			if bounds.has_point(path.global_transform * point):
				result.append(path)
				break
	return result