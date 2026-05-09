extends RefCounted

const ENEMY_BASE_PATH := "res://src/enemies/EnemyBase.gd"
const GREYED_VILLAGER_SCENE_PATH := "res://scenes/enemies/GreyedVillager.tscn"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not ResourceLoader.exists(ENEMY_BASE_PATH):
		failures.append("EnemyBase.gd should exist")
		return failures

	var enemy_script := load(ENEMY_BASE_PATH)
	if enemy_script == null or not enemy_script.can_instantiate():
		failures.append("EnemyBase.gd should parse and instantiate")
		return failures

	var enemy = enemy_script.new()
	enemy._ready()
	if enemy.health == null:
		failures.append("enemy should create health on ready")
	else:
		enemy.apply_damage(999.0)
		if not enemy.is_defeated():
			failures.append("enemy should be defeated when health reaches zero")
	enemy.free()

	if not ResourceLoader.exists(GREYED_VILLAGER_SCENE_PATH):
		failures.append("GreyedVillager.tscn should exist")
		return failures

	var scene := load(GREYED_VILLAGER_SCENE_PATH)
	if scene == null or not scene.can_instantiate():
		failures.append("GreyedVillager.tscn should load and instantiate")
		return failures
	var instance = scene.instantiate()
	instance.free()

	return failures
