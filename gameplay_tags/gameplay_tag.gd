@tool
extends Resource
class_name GameplayTag

## Represents a single gameplay tag with hierarchical naming support
## Tags use dot notation for hierarchy (e.g., "Ability.Attack.Melee")

var tag_category_filter : String = ""
var tag_name : String = ""
var _last_filter : String = ""

func _init(p_tag_name: String = ""):
	tag_name = p_tag_name

func _to_string() -> String:
	return tag_name

func _get_property_list() -> Array:
	if _last_filter != tag_category_filter:
		_last_filter = tag_category_filter
	
	var properties = []
	
	properties.append({"name":"tag_category_filter",
						"type":TYPE_STRING,
						"usage": PROPERTY_USAGE_DEFAULT,
						"hint":PROPERTY_HINT_PLACEHOLDER_TEXT,
						"hint_string":"Filter by Category"
						})

	var available_tags = _get_filtered_tags()
	var enum_string = ",".join(available_tags)
	
	properties.append({
		"name": "tag_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": enum_string})
		
	return properties
	
func _get(property: StringName):
	if property == "tag_category_filter":
		return tag_category_filter
	elif property == "tag_name":
		return tag_name
	return null
	
func _set(property: StringName, value) -> bool:
	if property == "tag_category_filter":
		if tag_category_filter != value:
			tag_category_filter = value
			if not Engine.is_editor_hint() or value !=  _last_filter:
				_refresh_properties() # Refresh dropdown when filter changes
		return true
	elif property == "tag_name":
		tag_name = value
		return true
	return false	
	
func _refresh_properties():
	call_deferred("notify_property_list_changed")
	emit_changed()
	
func _get_filtered_tags() -> Array[String]:
	var all_tags = _get_available_tags()
	
	if tag_category_filter.is_empty():
		return all_tags
	
	var filtered: Array[String] = []
	for tag in all_tags:
		if tag_category_filter in tag:
			filtered.append(tag)
	
	return filtered	
	
func _get_available_tags() -> Array[String]:
	var tags_list: Array[String] = []
	
	# Access GameplayTagManager singleton
	if Engine.is_editor_hint():
		# In editor, load the script directly
		var manager_script = load("res://gameplay_tags/gameplay_tag_manager.gd")
		if manager_script and manager_script.has_method("new"):
			var temp_manager = manager_script.new()
			if temp_manager and "TAGS" in temp_manager:
				for tag_value in temp_manager.TAGS.values():
					if not tags_list.has(tag_value):
						tags_list.append(tag_value)
			temp_manager.free()
	else:
		# At runtime, use the autoload singleton
		if GameplayTagManager and "TAGS" in GameplayTagManager:
			for tag_value in GameplayTagManager.TAGS.values():
				if not tags_list.has(tag_value):
					tags_list.append(tag_value)
	
	tags_list.sort()
	return tags_list
	
## Check if this tag matches another tag exactly
func matches_exact(other: GameplayTag) -> bool:
	if other == null:
		return false
	return tag_name == other.tag_name

## Check if this tag matches another tag or is a parent of it
## Example: "Ability.Attack" matches "Ability.Attack.Melee"
func matches(other: GameplayTag) -> bool:
	if other == null:
		return false
	if tag_name == other.tag_name:
		return true
	# Check if this tag is a parent in the hierarchy
	return other.tag_name.begins_with(tag_name + ".")

## Get the parent tag (e.g., "Ability.Attack.Melee" -> "Ability.Attack")
func get_parent_tag() -> String:
	var last_dot = tag_name.rfind(".")
	if last_dot > 0:
		return tag_name.substr(0, last_dot)
	return ""

## Check if this tag is a child of another tag
func is_child_of(parent_tag: String) -> bool:
	if parent_tag.is_empty():
		return false
	return tag_name.begins_with(parent_tag + ".")
