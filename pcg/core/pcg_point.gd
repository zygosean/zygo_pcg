extends RefCounted
class_name PCGPoint

var transform : Transform3D = Transform3D.IDENTITY
var attributes : Dictionary[String, Variant] = {}

func _init(p_transform: Transform3D = Transform3D.IDENTITY):
	transform = p_transform
	
func get_position() -> Vector3:
	return transform.origin
	
func set_attribute(key : String, value : Variant):
	attributes[key] = value
	
func get_attribute(key : String, default : Variant = null) -> Variant:
	return attributes.get(key, default)
	
func has_attribute(key : String) -> bool:
	return attributes.has(key)  