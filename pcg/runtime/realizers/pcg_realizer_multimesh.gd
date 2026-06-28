@tool
extends PCGRealizer
class_name PCGRealizerMultimesh

## GPU-instanced realization. Ideal for dense static scatter (grass, rocks, props).

@export var mesh : Mesh
@export var material_override : Material
@export var cast_shadows : bool = true

func realize(point_set : PCGPointSet, output_root : Node3D, context : PCGContext):
	if mesh == null:
		push_warning("PCGRealizerMultimesh: mesh is null")
		return
	
	var points := _select_points(point_set)
	if points.is_empty():
		return
	
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = points.size()
	
	var to_local := output_root.global_transform.affine_inverse()
	for i in points.size():
		# Bake into output_root's local space so the instance offsets are correct.
		mm.set_instance_transform(i, to_local * points[i].transform)
		
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	if material_override:
		mmi.material_override = material_override
	mmi.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)	

	output_root.add_child(mmi)	
