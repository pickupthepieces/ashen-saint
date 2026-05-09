extends RefCounted

const ITEM_DEFINITION_PATH := "res://src/items/ItemDefinition.gd"
const ITEM_INSTANCE_PATH := "res://src/items/ItemInstance.gd"
const AFFIX_DEFINITION_PATH := "res://src/items/AffixDefinition.gd"
const ITEM_GENERATOR_PATH := "res://src/items/ItemGenerator.gd"

func run() -> Array[String]:
	var failures: Array[String] = []
	for path in [ITEM_DEFINITION_PATH, ITEM_INSTANCE_PATH, AFFIX_DEFINITION_PATH, ITEM_GENERATOR_PATH]:
		if not ResourceLoader.exists(path):
			failures.append("%s should exist" % path.get_file())
			return failures

	var item_definition_script := load(ITEM_DEFINITION_PATH)
	var affix_definition_script := load(AFFIX_DEFINITION_PATH)
	var generator_script := load(ITEM_GENERATOR_PATH)
	var scripts := {
		"ItemDefinition.gd": item_definition_script,
		"AffixDefinition.gd": affix_definition_script,
		"ItemGenerator.gd": generator_script,
	}
	for script_name in scripts.keys():
		var script = scripts[script_name]
		if script == null or not script.can_instantiate():
			failures.append("%s should parse and instantiate" % script_name)
			return failures

	var definition = item_definition_script.new()
	definition.id = "old_judgement_sword"
	definition.display_name = "旧裁决剑"
	definition.slot = "two_hand_sword"
	definition.base_modifiers = {"weapon_attack": 18.0}

	var affixes := [
		_make_affix(affix_definition_script, "sharp", "锋利", {"weapon_attack": 4.0}),
		_make_affix(affix_definition_script, "steady", "沉稳", {"crit_chance": 0.05}),
		_make_affix(affix_definition_script, "greyflame", "灰焰", {"greyflame_damage_bonus": 0.08}),
	]

	var generator = generator_script.new()

	var normal_item = generator.generate(definition, "normal", affixes, 7)
	if normal_item.affixes.size() != 0:
		failures.append("normal items should have 0 affixes")

	var magic_item = generator.generate(definition, "magic", affixes, 7)
	if magic_item.affixes.size() < 1 or magic_item.affixes.size() > 2:
		failures.append("magic items should have 1-2 affixes")

	var rare_item = generator.generate(definition, "rare", affixes, 7)
	if rare_item.affixes.size() != 3:
		failures.append("rare items should have 3 affixes")

	var story_item = generator.generate(definition, "story_legendary", affixes, 7)
	if story_item.affixes.size() < 1 or story_item.affixes.size() > 2:
		failures.append("story legendary items should have 1-2 rolled affixes")
	if story_item.fixed_effect_id == "":
		failures.append("story legendary items should have a fixed effect id")

	var modifiers = rare_item.get_stat_modifiers()
	if modifiers.size() != 4:
		failures.append("item modifiers should include base modifiers plus 3 affixes")

	return failures

func _make_affix(script, id: String, display_name: String, modifiers: Dictionary):
	var affix = script.new()
	affix.id = id
	affix.display_name = display_name
	affix.modifiers = modifiers
	return affix
