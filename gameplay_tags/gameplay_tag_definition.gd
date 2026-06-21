extends Resource
class_name GameplayTagDefinition

## Override in subclasses for Domain/Plugin specific tags
## Default implementation auto-harvests all String consts via reflection
func get_tags() -> Dictionary[String, String]:
	var result : Dictionary[String, String] = {}
	_collect_from_script(get_script(), result)
	return result
	
func _collect_from_script(script : Script, result : Dictionary[String, String]) -> void: 
	if script == null:
		return
	for constant_name in script.get_script_constant_map():
		var value = script.get_script_constant_map()[constant_name]
		if value is String:
			result[value] = value
		elif value is Script:
			_collect_from_script(value, result)