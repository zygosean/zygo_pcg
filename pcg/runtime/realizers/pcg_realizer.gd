@tool
extends Resource
class_name PCGRealizer

## Base class for realizers: turn an abstract PCGPointSet into concrete
## scene content. Realizers are stateless Resources — all spawned nodes are
## parented under the supplied `output_root` so the runner owns their lifecycle.

@export var enabled : bool = true

## Optional tag gate: only realize points carrying this attribute/value.
## Leave empty to realize every point.
@export var require_attribute : String = ""

## Realize the given points as children of output_root
## 'context' is passed for seed/bounds-aware realizers
func realize(point_set : PCGPointSet, output_root : Node3D, context : PCGContext):
	push_warning("PCGRealizer.realize() not implemented in: " + get_script().resource_path)

## Helper: filter the points this realizer cares about
func _select_points(point_set : PCGPointSet) -> Array[PCGPoint]:
	if require_attribute.is_empty():
		return point_set.points
	var result : Array[PCGPoint] = []
	for p in point_set.points:
		if p.has_attribute(require_attribute):
			result.append(p)
	return result