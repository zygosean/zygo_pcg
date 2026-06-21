extends Node

## GameplayTagManager - Autoload singleton for managing gameplay tags
## Provides centralized tag definitions and comparison methods

## Predefined tag registry - Add your game's tags here to avoid magic strings
#const TAGS : Dictionary[String, String] = {
#	# Character States
#	"State.Aerial" : "State.Aerial",
#	"State.Idle": "State.Idle",
#	"State.Stunned": "State.Stunned",
#	"State.Invulnerable": "State.Invulnerable",
#	"State.Moving" : "State.Moving",
#	"State.Attacking" : "State.Attacking",
#	
#	# Character Equipment States
#	"State.Equipped" : "State.Equipped",
#	"State.Equipped.Weapon" : "State.Equipped.Weapon",
#	"State.Equipped.Weapon.Melee" : "State.Equipped.Weapon.Melee",
#	"State.Equipped.Weapon.Pistol" : "State.Equipped.Weapon.Pistol",
#	"State.Equipped.Weapon.Rifle" : "State.Equipped.Weapon.Rifle",
#	"State.Equipped.Weapon.Unarmed" : "State.Equipped.Weapon.Unarmed",
#	
#	# Character Action States
#	"State.Action" : "State.Action",
#	"State.Action.Attack" : "State.Action.Attack",
#	"State.Action.Casting" : "State.Action.Casting",
#	"State.Action.Aiming" : "State.Action.Aiming",
#	"State.Action.Interacting" : "State.Action.Interacting",
#	"State.Action.Falling" : "State.Action.Falling",
#	"State.Action.Dodging" : "State.Action.Dodging",
#	"State.Action.Jumping" : "State.Action.Jumping",
#	
#	# Abilities
#	"Ability": "Ability",
#	"Ability.Attack": "Ability.Attack",
#	"Ability.Attack.Melee": "Ability.Attack.Melee",
#	"Ability.Attack.Ranged": "Ability.Attack.Ranged",
#	
#	"Ability.Spell" : "Ability.Spell",
#	
#	"Ability.Cooldown" : "Ability.Cooldown",
#	"Ability.Cooldown.Active" : "Ability.Cooldown.Active",
#	
#	"Ability.Effect" : "Ability.Effect",
#	"Ability.Effect.DurationPolicy" : "Ability.Effect.DurationPolicy",
#	"Ability.Effect.DurationPolicy.Instant" : "Ability.Effect.DurationPolicy.Instant",
#	"Ability.Effect.DurationPolicy.HasDuration" : "Ability.Effect.DurationPolicy.HasDuration",
#	"Ability.Effect.DurationPolicy.Infinite" : "Ability.Effect.DurationPolicy.Infinite",
#	
#	# Ability input
#	"Ability.Input" : "Ability.Input",
#	"Ability.Input.Pressed" : "Ability.Input.Pressed",
#	"Ability.Input.Released" : "Ability.Input.Released",
#	"Ability.Input.Held" : "Ability.Input.Held",
#	"Ability.Input.Ability_1" : "Ability.Input.Ability_1",
#	"Ability.Input.Ability_2" : "Ability.Input.Ability_2",
#	"Ability.Input.Ability_3" : "Ability.Input.Ability_3",
#	"Ability.Input.Ability_4" : "Ability.Input.Ability_4",
#	"Ability.Input.Jump" : "Ability.Input.Jump",
#	"Ability.Input.Dodge" : "Ability.Input.Dodge",
#	"Ability.Input.PrimaryAttack" : "Ability.Input.PrimaryAttack",
#	"Ability.Input.SecondaryAttack" : "Ability.Input.SecondaryAttack",
#	
#	# Ability Fragments *****************
#	"Ability.Fragment": "Ability.Fragment",
#	
#	# Ability Fragments : Damage
#	"Ability.Fragment.Damage" : "Ability.Fragment.Damage",
#	"Ability.Fragment.Damage.Hit" : "Ability.Fragment.Damage.Hit",
#	"Ability.Fragment.Damage.DoT" : "Ability.Fragment.Damage.DoT",
#	
#	# Ability Fragments : Behaviour
#	"Ability.Fragment.Behaviour.Projectile" : "Ability.Fragment.Behaviour.Projectile",
#	"Ability.Fragment.Behaviour.AoE" : "Ability.Fragment.Behaviour.AoE",
#	
#	# Ability Fragments : Targeting
#	"Ability.Fragment.Targeting.LineTrace" : "Ability.Fragment.Targeting.LineTrace",
#	"Ability.Fragment.Targeting.AreaIndicator" : "Ability.Fragment.Targeting.AreaIndicator",
#	
#	#AbilityFragments : Movement
#	"Ability.Fragment.Movement.Impulse" : "Ability.Fragment.Movement.Impulse",
#	
#	#AbilityFragments : Duration
#	"Ability.Fragment.Duration" : "Ability.Fragment.Duration",
#	"Ability.Fragment.Cooldown" : "Ability.Fragment.Cooldown",
#	
#	# Ability context
#	"Ability.Context" : "Ability.Context",
#	"Ability.Context.Instigator" : "Ability.Context.Instigator",
#	"Ability.Context.InstigatorASC" : "Ability.Context.InstigatorASC",
#	"Ability.Context.Velocity" : "Ability.Context.Velocity",
#	"Ability.Context.HomingTarget" : "Ability.Context.HomingTarget",
#	
#	# Cooldowns
#	"Ability.Cooldown.Projectile.Basic" : "Ability.Cooldown.Projectile.Basic",
#	"Ability.Cooldown.Projectile.MeteorShower" : "Ability.Cooldown.Projectile.MeteorShower",
#	"Ability.Cooldown.Projectile.SpinningOrb" : "Ability.Cooldown.Projectile.SpinningOrb",
#	
#	# Ability socket locations
#	"Ability.Socket" : "Ability.Socket",
#	"Ability.Socket.Hand.Right" : "Ability.Socket.Hand.Right",
#	"Ability.Socket.Hand.Left" : "Ability.Socket.Hand.Left",
#	"Ability.Socket.Head" : "Ability.Socket.Head",
#	"Ability.Socket.Chest" : "Ability.Socket.Chest",
#	"Ability.Socket.Muzzle" : "Ability.Socket.Muzzle",
#	"Ability.Socket.Hand.Both" : "Ability.Socket.Hand.Both",
#	
#	# Aerial Abilities
#	
#	"Ability.Aerial" : "Ability.Aerial",
#	"Ability.Aerial.Jump" : "Ability.Aerial.Jump",
#	
#	# Projectile Abilities
#	
#	"Ability.Projectile" : "Ability.Projectile",
#	"Ability.Projectile.Basic" : "Ability.Projectile.Basic",
#	"Ability.Projectile.MeteorShower" : "Ability.Projectile.MeteorShower",
#	"Ability.Projectile.SpinningOrb" : "Ability.Projectile.SpinningOrb", #TODO: I don't think Projectile is the correct category, as each ability could have multiple types such as that
#	
#	#Attributes
#	
#	"Attribute" : "Attribute",
#	"Attribute.Vital" : "Attribute.Vital",
#	"Attribute.Vital.Health" : "Attribute.Vital.Health",
#	"Attribute.Vital.MaxHealth" : "Attribute.Vital.MaxHealth",
#	
#	"Attribute.Meta" : "Attribute.Meta",
#	"Attribute.Meta.DamageIn" : "Attribute.Meta.DamageIn",
#	"Attribute.Meta.XP" : "Attribute.Meta.XP",
#	
#	# Status Effects
#	"Status.Buff": "Status.Buff",
#	"Status.Buff.Strength": "Status.Buff.Strength",
#	"Status.Buff.Speed": "Status.Buff.Speed",
#	"Status.Debuff": "Status.Debuff",
#	"Status.Debuff.Weakness": "Status.Debuff.Weakness",
#	"Status.Debuff.Slow": "Status.Debuff.Slow",
#	
#	# Item Types
#	"Item": "Item",
#	"Item.Weapon": "Item.Weapon",
#	"Item.Weapon.Sword": "Item.Weapon.Sword",
#	"Item.Weapon.Bow": "Item.Weapon.Bow",
#	"Item.Armor": "Item.Armor",
#	"Item.Consumable": "Item.Consumable",
#	"Item.Consumable.Potion": "Item.Consumable.Potion",
#	
#	# Item Fragments
#	"Item.Fragment": "Item.Fragment",
#	"Item.Fragment.Grid" : "Item.Fragment.Grid",
#	"Item.Fragment.Stackable" : "Item.Fragment.Stackable",
#	"Item.Fragment.Highlight" : "Item.Fragment.Highlight",
#	"Item.Fragment.Image" : "Item.Fragment.Image",
#	"Item.Fragment.ItemName" : "Item.Fragment.ItemName",
#	
#	# ItemTypes
#	
#	"ItemType.Equippable" : "ItemType.Equippable",
#	"ItemType.Equippable.Weapon" : "ItemType.Equippable.Weapon",
#	"ItemType.Equippable.Weapon.OneHand" : "ItemType.Equippable.Weapon.OneHand",
#	"ItemType.Equippable.Weapon.OneHand.Sword" : "ItemType.Equippable.Weapon.OneHand.Sword",
#	
#	"ItemType.Consumable" : "ItemType.Consumable",
#	"ItemType.Consumable.Potion" : "ItemType.Consumable.Potion"
#	}

## Add Tag directories here
const TAG_DEFINITION_DIRS := [
	"res://pcg/tags/",
]

var TAGS : Dictionary[String, String] = {}

func _ready():  
	_load_all_tag_definitions()
	print("GameplayTagManager initialized with %d tags" % TAGS.size())
	
func _load_all_tag_definitions():
	for dir_path in TAG_DEFINITION_DIRS:
		print("GameplayTagManager: Loading tag definitions from: " + dir_path)
		_scan_directory(dir_path)
	print("GameplayTagManager: Loaded %d tags" % TAGS.size())

func _scan_directory(path : String):
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".gd"):
			var script = load(path + file_name)
			if script:
				var instance = script.new()
				if instance is GameplayTagDefinition:
					TAGS.merge(instance.get_tags())
				#instance.free()
		file_name = dir.get_next()

## Get all available tags as an array
func get_all_tags() -> Array[String]:
	var tag_array: Array[String] = []
	for tag in TAGS.values():
		tag_array.append(tag)
	return tag_array

## Get all tags organized by category
func get_tags_by_category() -> Dictionary:
	var categories = {}
	for tag in TAGS.values():
		var parts = tag.split(".")
		if parts.size() > 0:
			var category = parts[0]
			if not categories.has(category):
				categories[category] = []
			categories[category].append(tag)
	return categories

## Check if a container has a specific tag (exact match)
func has_tag_exact(container: GameplayTagContainer, tag: String) -> bool:
	if container == null:
		return false
	return container.has_tag_exact(tag)

## Check if a container has a tag or any of its children
## Example: has_tag(container, "Ability.Attack") returns true if container has "Ability.Attack.Melee"
func has_tag(container: GameplayTagContainer, tag: String) -> bool:
	if container == null:
		return false
	return container.has_tag(tag)

## Check if a container has any of the provided tags
func has_any(container: GameplayTagContainer, tag_list: Array) -> bool:
	if container == null:
		return false
	return container.has_any(tag_list)

## Check if a container has all of the provided tags
func has_all(container: GameplayTagContainer, tag_list: Array) -> bool:
	if container == null:
		return false
	return container.has_all(tag_list)

## Check if two containers share any tags
func containers_share_tags(container_a: GameplayTagContainer, container_b: GameplayTagContainer) -> bool:
	if container_a == null or container_b == null:
		return false
	
	for tag in container_a.get_tags():
		if container_b.has_tag(tag):
			return true
	return false

## Get common tags between two containers
func get_common_tags(container_a: GameplayTagContainer, container_b: GameplayTagContainer) -> Array[String]:
	var common: Array[String] = []
	if container_a == null or container_b == null:
		return common
	
	for tag in container_a.get_tags():
		if container_b.has_tag_exact(tag):
			common.append(tag)
	return common

## Add a tag to a container (helper method)
func add_tag(container: GameplayTagContainer, tag: String) -> void:
	if container != null:
		container.add_tag(tag)

## Remove a tag from a container (helper method)
func remove_tag(container: GameplayTagContainer, tag: String) -> void:
	if container != null:
		container.remove_tag(tag)
		
func remove_tags_matching(container : GameplayTagContainer, parent_tag : String) -> Array[String]:
	if container != null:
		return container.remove_tags_matching(parent_tag)
	return []

## Create a new GameplayTagContainer with specified tags
func create_container(tag_list: Array = []) -> GameplayTagContainer:
	var container = GameplayTagContainer.new()
	for tag in tag_list:
		container.add_tag(tag)
	return container

## Validate if a tag exists in the registry
func is_valid_tag(tag: String) -> bool:
	return TAGS.has(tag) or TAGS.values().has(tag)

## Get tag suggestions based on a prefix
func get_tag_suggestions(prefix: String) -> Array[String]:
	var suggestions: Array[String] = []
	for tag in TAGS.values():
		if tag.begins_with(prefix):
			suggestions.append(tag)
	return suggestions
