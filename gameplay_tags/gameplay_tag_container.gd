@tool
extends Resource
class_name GameplayTagContainer

## Container for holding multiple GameplayTags
## Provides Inspector UI for selecting tags via hierarchical checkboxes

signal tag_added(tag : String)
signal tag_removed(tag : String)

# Internal storage for tags
var tags: Array[String] = []

# Dictionary to track checkbox states for each tag
var _tag_states: Dictionary = {}

# Cache for available tags
var _available_tags: Array[String] = []

# Category filter for limiting displayed tags
var tag_category_filter: String = "All"

func _init():
	_load_available_tags()
	_sync_tag_states()

## Load available tags from GameplayTagManager
func _load_available_tags() -> void:
	if Engine.has_singleton("GameplayTagManager"):
		var manager := Engine.get_singleton("GameplayTagManager")
		for tag_value in manager.TAGS.values():
			if not _available_tags.has(tag_value):
				_available_tags.append(tag_value)
		_available_tags.sort()
	
	# Load the GameplayTagManager script to access TAGS constant
#	var manager_script = load("res://gameplay_tags/gameplay_tag_manager.gd")
#	if manager_script and manager_script.has_method("new"):
#		var temp_manager = manager_script.new()
#		if temp_manager and "TAGS" in temp_manager:
#			for tag_value in temp_manager.TAGS.values():
#				if not _available_tags.has(tag_value):
#					_available_tags.append(tag_value)
#			_available_tags.sort()
#		temp_manager.free()

## Sync tag states dictionary with tags array
func _sync_tag_states() -> void:
	_tag_states.clear()
	for tag in _available_tags:
		_tag_states[tag] = tags.has(tag)

## Get available categories from tags
func _get_available_categories() -> Array[String]:
	var categories: Array[String] = ["All"]
	var category_set = {}
	for tag in _available_tags:
		var parts = tag.split(".")
		if parts.size() > 0 and not category_set.has(parts[0]):
			category_set[parts[0]] = true
			categories.append(parts[0])
	return categories

## Filter tags by category
func _get_filtered_tags() -> Array[String]:
	if tag_category_filter == "All" or tag_category_filter.is_empty():
		return _available_tags.duplicate()
	
	var filtered: Array[String] = []
	for tag in _available_tags:
		if tag.begins_with(tag_category_filter + "."):
			filtered.append(tag)
	return filtered

## Build hierarchical tree structure from flat tag list
func _build_tag_tree(tag_list: Array[String]) -> Dictionary:
	var tree = {}
	for tag in tag_list:
		var parts = tag.split(".")
		var current = tree
		for i in range(parts.size()):
			var part = parts[i]
			if not current.has(part):
				current[part] = {
					"_full_tag": ".".join(parts.slice(0, i + 1)),
					"_children": {}
				}
			current = current[part]["_children"]
	return tree

## Add properties recursively from tree structure
func _add_tree_properties(properties: Array, tree: Dictionary, prefix: String = "", depth: int = 0) -> void:
	var sorted_keys = tree.keys()
	sorted_keys.sort()
	
	for key in sorted_keys:
		var node = tree[key]
		var full_tag: String = node["_full_tag"]
		var children: Dictionary = node["_children"]
		var has_children: bool = children.keys().size() > 0
		
		# Add group header if has children
		if has_children:
			properties.append({
				"name": prefix + key,
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
				"hint_string": prefix + key + ","
			})
		
		# Add checkbox for this tag (both parent and leaf tags are selectable)
		var tag_property_name: String = "tag_" + full_tag.replace(".", "_")
		properties.append({
			"name": tag_property_name,
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": full_tag
		})
		
		# Recursively add children
		if has_children:
			_add_tree_properties(properties, children, prefix + key + "/", depth + 1)

## Override to provide custom properties in Inspector
func _get_property_list() -> Array:
	# Ensure tags are loaded
	if _available_tags.is_empty():
		_load_available_tags()
		_sync_tag_states()
	
	var properties = []
	
	# Add the tags array for serialization (hidden from Inspector)
	properties.append({
		"name": "tags",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	# Add category filter property
	var categories = _get_available_categories()
	properties.append({
		"name": "tag_category_filter",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(categories)
	})
	
	# Add a header for tags section
	properties.append({
		"name": "Gameplay Tags",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})
	
	# Get filtered tags and build hierarchical structure
	var filtered_tags = _get_filtered_tags()
	var tree = _build_tag_tree(filtered_tags)
	
	# Add properties from tree structure
	_add_tree_properties(properties, tree)
	
	return properties

## Override to get property values
func _get(property: StringName):
	var prop_str = str(property)
	if prop_str == "tags":
		return tags
	elif prop_str == "tag_category_filter":
		return tag_category_filter
	elif prop_str.begins_with("tag_"):
		var tag_name = prop_str.substr(4).replace("_", ".")
		return _tag_states.get(tag_name, false)
	return null

## Override to set property values
func _set(property: StringName, value) -> bool:
	var prop_str = str(property)
	if prop_str == "tags":
		tags = value
		_sync_tag_states()
		return true
	elif prop_str == "tag_category_filter":
		if tag_category_filter != value:
			tag_category_filter = value
			notify_property_list_changed()  # Refresh Inspector UI
		return true
	elif prop_str.begins_with("tag_"):
		var tag_name = prop_str.substr(4).replace("_", ".")
		if _available_tags.has(tag_name):
			_tag_states[tag_name] = value
			# Update tags array
			if value and not tags.has(tag_name):
				tags.append(tag_name)
			elif not value and tags.has(tag_name):
				tags.erase(tag_name)
			return true
	return false

## Add a tag to the container
func add_tag(tag: String) -> void:
	if tag.is_empty():
		return
	if not tags.has(tag):
		tags.append(tag)
		emit_signal("tag_added", tag)
		if _available_tags.has(tag):
			_tag_states[tag] = true
			notify_property_list_changed()

## Remove a tag from the container
func remove_tag(tag: String) -> void:
	var idx = tags.find(tag)
	if idx >= 0:
		tags.remove_at(idx)
		emit_signal("tag_removed", tag)
		
		if _available_tags.has(tag):
			_tag_states[tag] = false
			notify_property_list_changed()

# Remove all tags matching a parent tag (including children)
func remove_tags_matching(parent_tag: String) -> Array[String]:
	var removed_tags: Array[String] = []
	
	# Backwards iteration for safe removal
	for i in range(tags.size() - 1, -1, -1):
		var tag = tags[i]
		if tag == parent_tag or tag.begins_with(parent_tag + "."):
			tags.remove_at(i)
			removed_tags.append(tag)
			emit_signal("tag_removed", tag)
			
			if _available_tags.has(tag):
				_tag_states[tag] = false
				
	if removed_tags.size() > 0:
		notify_property_list_changed()
		
	return removed_tags

## Check if container has a specific tag (exact match)
func has_tag_exact(tag: String) -> bool:
	return tags.has(tag)

## Check if container has a tag or any of its children
## Example: has_tag("Ability.Attack") returns true if container has "Ability.Attack.Melee"
func has_tag(tag: String) -> bool:
	if tag == null or tag.is_empty():
		return false
	
	for t in tags:
		if t == tag:
			return true
		# Check if t is a child of tag
		if t.begins_with(tag + "."):
			return true
	return false

## Check if container has any of the provided tags
func has_any(tag_list: Array) -> bool:
	for tag in tag_list:
		if has_tag(tag):
			return true
	return false

## Check if container has all of the provided tags
func has_all(tag_list: Array) -> bool:
	for tag in tag_list:
		if not has_tag(tag):
			return false
	return true

## Clear all tags
func clear() -> void:
	tags.clear()

## Get all tags as an array
func get_tags() -> Array[String]:
	return tags.duplicate()

## Get count of tags
func get_tag_count() -> int:
	return tags.size()

func _to_string() -> String:
	return "GameplayTagContainer(%s)" % [", ".join(tags)]
