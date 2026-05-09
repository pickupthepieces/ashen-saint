extends RefCounted

const INVENTORY_PATH := "res://src/items/Inventory.gd"
const EQUIPMENT_SLOTS_PATH := "res://src/items/EquipmentSlots.gd"
const ITEM_DEFINITION_PATH := "res://src/items/ItemDefinition.gd"
const ITEM_INSTANCE_PATH := "res://src/items/ItemInstance.gd"
const AFFIX_DEFINITION_PATH := "res://src/items/AffixDefinition.gd"
const STAT_BLOCK_PATH := "res://src/stats/StatBlock.gd"

func run() -> Array[String]:
	var failures: Array[String] = []
	for path in [INVENTORY_PATH, EQUIPMENT_SLOTS_PATH, ITEM_DEFINITION_PATH, ITEM_INSTANCE_PATH, AFFIX_DEFINITION_PATH, STAT_BLOCK_PATH]:
		if not ResourceLoader.exists(path):
			failures.append("%s should exist" % path.get_file())
			return failures

	var inventory_script := load(INVENTORY_PATH)
	var equipment_script := load(EQUIPMENT_SLOTS_PATH)
	var definition_script := load(ITEM_DEFINITION_PATH)
	var item_script := load(ITEM_INSTANCE_PATH)
	var affix_script := load(AFFIX_DEFINITION_PATH)
	var stat_script := load(STAT_BLOCK_PATH)
	var scripts := {
		"Inventory.gd": inventory_script,
		"EquipmentSlots.gd": equipment_script,
		"ItemDefinition.gd": definition_script,
		"ItemInstance.gd": item_script,
		"AffixDefinition.gd": affix_script,
		"StatBlock.gd": stat_script,
	}
	for script_name in scripts.keys():
		var script = scripts[script_name]
		if script == null or not script.can_instantiate():
			failures.append("%s should parse and instantiate" % script_name)
			return failures

	var sword_def = definition_script.new()
	sword_def.display_name = "旧裁决剑"
	sword_def.slot = "two_hand_sword"
	sword_def.base_modifiers = {"weapon_attack": 22.0}

	var sword = item_script.new()
	sword.definition = sword_def
	sword.rarity = "rare"
	sword.affixes = [_affix(affix_script, {"crit_chance": 0.1}), _affix(affix_script, {"attack_bonus": 0.2})]

	var inventory = inventory_script.new()
	inventory.add_item(sword)
	if not inventory.contains_item(sword):
		failures.append("inventory should contain added item")

	var equipment = equipment_script.new()
	if not equipment.equip(sword):
		failures.append("two hand sword should equip successfully")
	if inventory.remove_item(sword) == false:
		failures.append("inventory should remove equipped item")

	var base_stats = stat_script.new()
	base_stats.base_attack = 10.0
	base_stats.crit_chance = 0.05
	var final_stats = equipment.calculate_stats(base_stats)

	_assert_close(final_stats.base_attack, 10.0, "base attack should remain from base stats", failures)
	_assert_close(final_stats.weapon_attack, 22.0, "weapon attack should come from equipped sword", failures)
	_assert_close(final_stats.crit_chance, 0.15, "crit chance should include affix", failures)
	_assert_close(final_stats.attack_bonus, 0.2, "attack bonus should include affix", failures)

	return failures

func _affix(script, modifiers: Dictionary) -> Resource:
	var affix = script.new()
	affix.modifiers = modifiers
	return affix

func _assert_close(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > 0.001:
		failures.append("%s: expected %.3f, got %.3f" % [message, expected, actual])
