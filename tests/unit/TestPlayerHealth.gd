extends RefCounted

const PLAYER_CONTROLLER_PATH := "res://src/player/PlayerController.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	var player_script := load(PLAYER_CONTROLLER_PATH)
	if player_script == null or not player_script.can_instantiate():
		failures.append("PlayerController.gd should parse and instantiate")
		return failures

	var player = player_script.new()
	player._ready()
	player.global_position = Vector2(420, 610)
	if not player.has_method("apply_damage"):
		failures.append("player should support apply_damage")
		player.free()
		return failures
	if not player.has_method("set_checkpoint"):
		failures.append("player should support checkpoints")
		player.free()
		return failures

	player.set_checkpoint(Vector2(120, 610))
	player.apply_damage(25.0)
	if player.current_hp >= player.max_hp:
		failures.append("damage should reduce player hp")
	player.apply_damage(999.0)
	if player.current_hp != player.max_hp:
		failures.append("lethal damage should respawn with full hp")
	if player.global_position != Vector2(120, 610):
		failures.append("lethal damage should return player to checkpoint")

	player.free()
	return failures
