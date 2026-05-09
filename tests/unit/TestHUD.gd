extends RefCounted

const HUD_PATH := "res://src/ui/HUD.gd"
const HUD_SCENE_PATH := "res://scenes/ui/HUD.tscn"
const PLAYER_CONTROLLER_PATH := "res://src/player/PlayerController.gd"
const LOOT_PICKUP_PATH := "res://src/loot/LootPickup.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not FileAccess.file_exists(HUD_PATH):
		failures.append("HUD.gd should exist")
		return failures
	if not ResourceLoader.exists(HUD_SCENE_PATH):
		failures.append("HUD.tscn should exist")
		return failures

	var hud_script := load(HUD_PATH)
	if hud_script == null or not hud_script.can_instantiate():
		failures.append("HUD.gd should parse and instantiate")
		return failures

	var scene := load(HUD_SCENE_PATH)
	if scene == null or not scene.can_instantiate():
		failures.append("HUD.tscn should load and instantiate")
		return failures

	var instance = scene.instantiate()
	if instance.get_node_or_null("Root/StatsLabel") == null:
		failures.append("HUD should contain StatsLabel")
	if instance.get_node_or_null("Root/HintLabel") == null:
		failures.append("HUD should contain HintLabel")
	if instance.get_node_or_null("Root/InventoryPanel") == null:
		failures.append("HUD should contain InventoryPanel")
	if instance.get_node_or_null("Root/InventoryPanel/ItemList") == null:
		failures.append("HUD should contain inventory ItemList")
	if instance.get_node_or_null("Root/InventoryPanel/DetailLabel") == null:
		failures.append("HUD should contain inventory DetailLabel")

	var player_script := load(PLAYER_CONTROLLER_PATH)
	var loot_script := load(LOOT_PICKUP_PATH)
	if player_script != null and player_script.can_instantiate() and loot_script != null and loot_script.can_instantiate():
		var player = player_script.new()
		player._ready()
		var loot = loot_script.new()
		loot.display_name = "旧裁决剑"
		loot.rarity = "rare"
		loot.weapon_attack = 26.0
		player.pickup_item(loot.create_item_instance())

		if not instance.has_method("set_inventory_visible"):
			failures.append("HUD should expose set_inventory_visible")
		elif not instance.has_method("render_inventory"):
			failures.append("HUD should expose render_inventory")
		else:
			instance.set_inventory_visible(true)
			instance.render_inventory(player)
			var panel = instance.get_node("Root/InventoryPanel")
			var list = instance.get_node("Root/InventoryPanel/ItemList")
			var detail = instance.get_node("Root/InventoryPanel/DetailLabel")
			if not panel.visible:
				failures.append("inventory panel should become visible")
			if list.text.find("旧裁决剑") < 0:
				failures.append("inventory list should show picked item")
			if detail.text.find("已装备") < 0:
				failures.append("inventory detail should show equipped weapon")
		player.free()
		loot.free()

	instance.free()

	return failures
