extends RefCounted

const PLAYER_CONTROLLER_PATH := "res://src/player/PlayerController.gd"
const LOOT_PICKUP_PATH := "res://src/loot/LootPickup.gd"
const LOOT_PICKUP_SCENE_PATH := "res://scenes/loot/LootPickup.tscn"

func run() -> Array[String]:
	var failures: Array[String] = []

	for path in [PLAYER_CONTROLLER_PATH, LOOT_PICKUP_PATH]:
		if not FileAccess.file_exists(path):
			failures.append("%s should exist" % path.get_file())
			return failures
	if not ResourceLoader.exists(LOOT_PICKUP_SCENE_PATH):
		failures.append("LootPickup.tscn should exist")
		return failures

	var player_script := load(PLAYER_CONTROLLER_PATH)
	var loot_script := load(LOOT_PICKUP_PATH)
	if player_script == null or not player_script.can_instantiate():
		failures.append("PlayerController.gd should parse and instantiate")
		return failures
	if loot_script == null or not loot_script.can_instantiate():
		failures.append("LootPickup.gd should parse and instantiate")
		return failures

	var player = player_script.new()
	player._ready()
	var starting_damage: float = player.basic_attack_damage

	var loot = loot_script.new()
	loot.display_name = "旧裁决剑"
	loot.rarity = "rare"
	loot.slot = "two_hand_sword"
	loot.weapon_attack = 24.0

	if not loot.has_method("create_item_instance"):
		failures.append("loot should create an item instance")
		player.free()
		loot.free()
		return failures

	var item = loot.create_item_instance()
	if item == null:
		failures.append("loot should return an item instance")
	elif item.definition.display_name != "旧裁决剑":
		failures.append("loot item should preserve display name")
	elif item.affixes.size() == 0:
		failures.append("rare loot should roll at least one affix for equipment filtering")

	if not player.has_method("pickup_item"):
		failures.append("player should support pickup_item")
	else:
		player.pickup_item(item)
		if player.inventory == null or player.inventory.items.size() != 1:
			failures.append("picked item should enter inventory")
		if player.basic_attack_damage <= starting_damage:
			failures.append("equipped weapon pickup should increase attack damage")
		if not player.has_method("get_inventory_items") or player.get_inventory_items().size() != 1:
			failures.append("player should expose inventory items for UI")
		if not player.has_method("get_equipped_weapon_name") or player.get_equipped_weapon_name() != "旧裁决剑":
			failures.append("player should expose equipped weapon name for UI")

	var loot_scene := load(LOOT_PICKUP_SCENE_PATH)
	var loot_instance = loot_scene.instantiate()
	if loot_instance.collision_mask & 1 == 0:
		failures.append("loot pickup should detect the player's default collision layer")
	if loot_instance.get_node_or_null("PromptLabel") == null:
		failures.append("loot pickup should show an F pickup prompt")
	loot_instance.free()

	player.free()
	loot.free()
	return failures
