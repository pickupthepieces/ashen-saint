extends RefCounted

const ENEMY_SCENE_PATH := "res://scenes/enemies/GreyedVillager.tscn"
const LOOT_SCENE_PATH := "res://scenes/loot/LootPickup.tscn"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not ResourceLoader.exists(ENEMY_SCENE_PATH):
		failures.append("GreyedVillager.tscn should exist")
		return failures
	if not ResourceLoader.exists(LOOT_SCENE_PATH):
		failures.append("LootPickup.tscn should exist")
		return failures

	var scene := load(ENEMY_SCENE_PATH)
	var enemy = scene.instantiate()
	if not enemy.has_method("get_drop_scene_path"):
		failures.append("enemy should expose drop scene path")
		enemy.free()
		return failures

	if enemy.get_drop_scene_path() != LOOT_SCENE_PATH:
		failures.append("greyed villager should be configured to drop LootPickup")

	enemy.free()
	return failures
