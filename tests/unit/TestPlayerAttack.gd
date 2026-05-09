extends RefCounted

const PLAYER_CONTROLLER_PATH := "res://src/player/PlayerController.gd"
const ENEMY_BASE_PATH := "res://src/enemies/EnemyBase.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	for path in [PLAYER_CONTROLLER_PATH, ENEMY_BASE_PATH]:
		if not ResourceLoader.exists(path):
			failures.append("%s should exist" % path.get_file())
			return failures

	var player_script := load(PLAYER_CONTROLLER_PATH)
	var enemy_script := load(ENEMY_BASE_PATH)
	if player_script == null or not player_script.can_instantiate():
		failures.append("PlayerController.gd should parse and instantiate")
		return failures
	if enemy_script == null or not enemy_script.can_instantiate():
		failures.append("EnemyBase.gd should parse and instantiate")
		return failures

	var player = player_script.new()
	player._ready()
	if not player.has_method("apply_basic_attack_to"):
		failures.append("player should apply basic attack to explicit targets")
		player.free()
		return failures
	if not player.has_method("is_attack_feedback_active"):
		failures.append("player should expose attack feedback state")
		player.free()
		return failures

	player.request_basic_attack()
	if not player.is_attack_feedback_active():
		failures.append("basic attack should trigger visible player feedback even without a target")

	var enemy = enemy_script.new()
	enemy._ready()
	var before_hp: float = float(enemy.health.current_hp)
	var hit_count: int = player.apply_basic_attack_to([enemy])
	var after_hp: float = float(enemy.health.current_hp)

	if hit_count != 1:
		failures.append("basic attack should report one hit")
	if after_hp >= before_hp:
		failures.append("basic attack should damage enemy health")

	player.apply_basic_attack_to([enemy])
	if not enemy.is_defeated():
		failures.append("two basic attacks should defeat a greyed villager")
	if enemy.visible:
		failures.append("defeated enemies should visibly disappear")
	if enemy.collision_layer != 0 or enemy.collision_mask != 0:
		failures.append("defeated enemies should stop blocking attacks and movement")

	player.free()
	enemy.free()
	return failures
