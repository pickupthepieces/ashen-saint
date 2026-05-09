class_name ItemInstance
extends Resource

@export var definition: Resource
@export var rarity: String = "normal"
@export var affixes: Array = []
@export var fixed_effect_id: String = ""

func get_display_name() -> String:
	if definition == null:
		return ""
	return String(definition.display_name)

func get_stat_modifiers() -> Array:
	var modifiers: Array = []
	if definition != null and not definition.base_modifiers.is_empty():
		modifiers.append(definition.base_modifiers)

	for affix in affixes:
		if affix != null and not affix.modifiers.is_empty():
			modifiers.append(affix.modifiers)

	return modifiers
