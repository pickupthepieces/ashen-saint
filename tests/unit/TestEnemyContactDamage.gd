extends RefCounted

const ENEMY_BASE_PATH := "res://src/enemies/EnemyBase.gd"
const PLAYER_CONTROLLER_PATH := "res://src/player/PlayerController.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	var enemy_script := load(ENEMY_BASE_PATH)
	var player_script := load(PLAYER_CONTROLLER_PATH)
	if enemy_script == null or not enemy_script.can_instantiate():
		failures.append("EnemyBase.gd should parse and instantiate")
		return failures
	if player_script == null or not player_script.can_instantiate():
		failures.append("PlayerController.gd should parse and instantiate")
		return failures

	var enemy = enemy_script.new()
	enemy._ready()
	var player = player_script.new()
	player._ready()
	var before_hp: float = player.current_hp

	if not enemy.has_method("try_contact_damage"):
		failures.append("enemy should support contact damage")
	else:
		enemy.try_contact_damage(player)
		if player.current_hp >= before_hp:
			failures.append("enemy contact damage should reduce player hp")

	enemy.free()
	player.free()
	return failures
