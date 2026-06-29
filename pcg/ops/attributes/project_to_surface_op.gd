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
	if context.physics_space == null:
		push_warning("ProjectToSurfaceOp: No physics space in context")
		return point_set
	
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
