## pcg/ops/filter/splines/pcg_spline_filter_op.gd
## Base for all single-pass spline filter operations.
## Subclasses implement _apply_kernel() to mark points into the mask.
## The mask-build → invert → filter loop is handled here.
@tool
extends PCGOp
class_name PCGSplineFilterOp

## If true, the selection is inverted after the kernel runs.
@export var invert: bool = false

func execute(point_set : PCGPointSet, context : PCGContext) -> PCGPointSet:
	if context.splines.is_empty():
		push_warning(get_script().resource_path + ": no splines in context.")
		return point_set
		
	var positions := point_set.get_positions()
	var mask := PCGKernels.make_mask(positions.size())
	
	for path in context.splines:
		_apply_kernel(positions, path, mask)
		
	if invert:
		PCGKernels.invert_mask(mask)
		
	return point_set.filter_by_mask(mask)
	
func _apply_kernel(_positions : PackedVector3Array, _path : Path3D, _mask : PackedByteArray):
	push_warning("PCGSplineFilterOp._apply_kernel() not implemented in: " + get_script().resource_path + "")