extends RefCounted

const HERMANN_SCRIPT_PATH := "res://src/bosses/HermannBoss.gd"
const HERMANN_SCENE_PATH := "res://scenes/bosses/HermannBoss.tscn"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not FileAccess.file_exists(HERMANN_SCRIPT_PATH):
		failures.append("HermannBoss.gd should exist")
		return failures
	if not ResourceLoader.exists(HERMANN_SCENE_PATH):
		failures.append("HermannBoss.tscn should exist")
		return failures

	var scene := load(HERMANN_SCENE_PATH)
	if scene == null or not scene.can_instantiate():
		failures.append("HermannBoss.tscn should load and instantiate")
		return failures

	var boss = scene.instantiate()
	boss._ready()
	if not boss.has_method("get_phase"):
		failures.append("Hermann boss should expose get_phase")
	else:
		if boss.get_phase() != 1:
			failures.append("Hermann should start in phase 1")
		boss.apply_damage(999.0)
		if boss.get_phase() != 2:
			failures.append("Hermann should enter phase 2 below half health before defeat")
		if not boss.is_defeated():
			failures.append("Hermann should be defeated by lethal damage")

	if boss.health == null or boss.health.max_hp < 150.0:
		failures.append("Hermann should have boss-scale health")

	boss.free()
	return failures
