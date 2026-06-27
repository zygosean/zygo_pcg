## PCGKernels.gd
## Pure-GDScript implementations of all per-point bulk operations.
## All methods are static and operate on PackedArrays — no per-point GDScript 
## loop should exist outside of this file.
##
## IMPORTANT: Method signatures here are the stable contract.
## A future C++ GDExtension registers a class also named PCGKernels with
## identical signatures, and all call sites automatically use the native version
## with zero changes to any op.
class_name PCGKernels

# ─────────────────────────────────────────────
#  SECTION 1 — Mask Utilities
#  Masks are PackedByteArray: 1 = keep, 0 = drop.
#  Ops build a mask, then call filter_by_mask().
# ─────────────────────────────────────────────

## Inverts a mask in place: 0 → 1, 1 → 0.
static func invert_mask(mask: PackedByteArray) -> void:
	for i in mask.size():
		mask[i] = 1 if mask[i] == 0 else 0

## Combines two masks with OR: output[i] = 1 if either input is 1.
## Useful when testing against multiple splines — any match = keep.
static func mask_union(a: PackedByteArray, b: PackedByteArray) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(a.size())
	for i in a.size():
		result[i] = 1 if (a[i] == 1 or b[i] == 1) else 0
	return result

## Creates a fresh zero-filled mask of the given size.
static func make_mask(size: int) -> PackedByteArray:
	var mask := PackedByteArray()
	mask.resize(size)
	mask.fill(0)
	return mask


# ─────────────────────────────────────────────
#  SECTION 2 — Spline Proximity
#  Used by: FilterBySplineProximityOp, SetDistanceToSplineOp
# ─────────────────────────────────────────────

## For each position, computes the closest distance to a baked polyline.
## Returns one distance per point as PackedFloat32Array.
## [param to_local] transforms world positions into the spline's local space.
static func closest_distances_to_polyline(
		positions: PackedVector3Array,
		baked: PackedVector3Array,
		to_local: Transform3D) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	result.resize(positions.size())
	for i in positions.size():
		var local_pos := to_local * positions[i]
		result[i] = _closest_dist_on_polyline(local_pos, baked)
	return result

## Marks positions within [max_distance] of the polyline as 1 in the mask.
## Writes into an existing mask using OR — call make_mask() first if fresh.
static func mark_within_distance(
		positions: PackedVector3Array,
		baked: PackedVector3Array,
		to_local: Transform3D,
		max_distance: float,
		mask: PackedByteArray) -> void:
	for i in positions.size():
		if mask[i] == 1:
			continue  # already marked, skip work
		var local_pos := to_local * positions[i]
		if _closest_dist_on_polyline(local_pos, baked) <= max_distance:
			mask[i] = 1


# ─────────────────────────────────────────────
#  SECTION 3 — Polygon Inside/Outside Test
#  Used by: FilterInsideSplineOp, ScatterInsideSplineOp
# ─────────────────────────────────────────────

## Marks positions that are inside the XZ-projected polygon as 1 in the mask.
## [param baked] is a closed PackedVector3Array (last point ≈ first point).
## [param to_local] transforms world positions into the polygon's local space.
static func mark_inside_polygon(
		positions: PackedVector3Array,
		baked: PackedVector3Array,
		to_local: Transform3D,
		mask: PackedByteArray) -> void:
	if baked.size() < 3:
		return
	for i in positions.size():
		if mask[i] == 1:
			continue
		var local_pos := to_local * positions[i]
		if _point_in_polygon_xz(local_pos, baked):
			mask[i] = 1

## Tests a single point against a baked polygon.
## Thin wrapper kept for cases where you need a one-off check without building a mask.
static func is_inside_polygon(
		local_pos: Vector3,
		baked: PackedVector3Array) -> bool:
	return _point_in_polygon_xz(local_pos, baked)


# ─────────────────────────────────────────────
#  SECTION 4 — Spline Progress / Offset
#  Used by: SetSplineProgressOp
# ─────────────────────────────────────────────

## For each position, computes the normalised progress (0.0→1.0) along the
## closest point on the baked curve. Returns PackedFloat32Array.
static func compute_spline_progress(
		positions: PackedVector3Array,
		baked: PackedVector3Array,
		to_local: Transform3D,
		baked_length: float) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	result.resize(positions.size())
	if baked_length <= 0.0:
		return result
	for i in positions.size():
		var local_pos := to_local * positions[i]
		var offset := _closest_offset_on_polyline(local_pos, baked)
		result[i] = offset / baked_length
	return result


# ─────────────────────────────────────────────
#  SECTION 5 — Attribute Kernels
#  Used by: FilterByDensityOp, SetDistanceToSplineOp
# ─────────────────────────────────────────────

## Marks positions where attribute[i] >= min_value as 1 in the mask.
static func mark_attribute_gte(
		values: PackedFloat32Array,
		min_value: float,
		mask: PackedByteArray) -> void:
	for i in values.size():
		if values[i] >= min_value:
			mask[i] = 1

## Normalises distances into a falloff attribute: 1.0 at spline, 0.0 at max_distance.
static func distances_to_falloff(
		distances: PackedFloat32Array,
		max_distance: float) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	result.resize(distances.size())
	for i in distances.size():
		result[i] = 1.0 - clampf(distances[i] / max_distance, 0.0, 1.0)
	return result


# ─────────────────────────────────────────────
#  SECTION 6 — Point Generation
#  Used by: ScatterPointsOp, ScatterInsideSplineOp
# ─────────────────────────────────────────────

## Generates [count] random positions inside an AABB using the given RNG.
## Returns a PackedVector3Array.
static func scatter_in_aabb(
		rng: RandomNumberGenerator,
		bounds: AABB,
		count: int) -> PackedVector3Array:
	var result := PackedVector3Array()
	result.resize(count)
	for i in count:
		result[i] = Vector3(
			bounds.position.x + rng.randf() * bounds.size.x,
			bounds.position.y + rng.randf() * bounds.size.y,
			bounds.position.z + rng.randf() * bounds.size.z
		)
	return result

## Samples positions along a baked polyline at regular [step] intervals.
## Returns an array of Transform3D (origin + orientation from baked rotation).
## Caller is responsible for converting to world space.
static func sample_polyline_transforms(
		curve: Curve3D,
		step: float) -> Array[Transform3D]:
	var result : Array[Transform3D] = []
	var length := curve.get_baked_length()
	if length <= 0.0 or step <= 0.0:
		return result
	var t := 0.0
	while t <= length:
		result.append(curve.sample_baked_with_rotation(t, true))
		t += step
	return result


# ─────────────────────────────────────────────
#  PRIVATE HELPERS
#  These are NOT part of the public contract — they won't exist in C++.
#  The C++ implementation replaces the entire method above with its own loop.
# ─────────────────────────────────────────────

static func _closest_dist_on_polyline(local_pos: Vector3, baked: PackedVector3Array) -> float:
	var min_dist := INF
	for i in baked.size() - 1:
		var a := baked[i]
		var b := baked[i + 1]
		var ab := b - a
		var len_sq := ab.length_squared()
		var closest : Vector3
		if len_sq < 1e-8:
			closest = a
		else:
			var t := clampf((local_pos - a).dot(ab) / len_sq, 0.0, 1.0)
			closest = a + ab * t
		var d := local_pos.distance_to(closest)
		if d < min_dist:
			min_dist = d
	return min_dist

static func _closest_offset_on_polyline(local_pos: Vector3, baked: PackedVector3Array) -> float:
	var min_dist := INF
	var best_offset := 0.0
	var accumulated := 0.0
	for i in baked.size() - 1:
		var a := baked[i]
		var b := baked[i + 1]
		var ab := b - a
		var seg_len := ab.length()
		var len_sq := seg_len * seg_len
		var t := 0.0
		if len_sq >= 1e-8:
			t = clampf((local_pos - a).dot(ab) / len_sq, 0.0, 1.0)
		var closest := a + ab * t
		var d := local_pos.distance_to(closest)
		if d < min_dist:
			min_dist = d
			best_offset = accumulated + t * seg_len
		accumulated += seg_len
	return best_offset

static func _point_in_polygon_xz(local_pos: Vector3, baked: PackedVector3Array) -> bool:
	var px := local_pos.x
	var pz := local_pos.z
	var crossings := 0
	var count := baked.size()
	for i in count:
		var a := baked[i]
		var b := baked[(i + 1) % count]
		if (a.z <= pz and b.z > pz) or (b.z <= pz and a.z > pz):
			var t := (pz - a.z) / (b.z - a.z)
			if a.x + t * (b.x - a.x) > px:
				crossings += 1
	return (crossings % 2) == 1
