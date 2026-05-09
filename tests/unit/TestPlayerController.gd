extends RefCounted

const PLAYER_CONTROLLER_PATH := "res://src/player/PlayerController.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not ResourceLoader.exists(PLAYER_CONTROLLER_PATH):
		failures.append("PlayerController.gd should exist")
		return failures

	var player_script := load(PLAYER_CONTROLLER_PATH)
	if player_script == null or not player_script.can_instantiate():
		failures.append("PlayerController.gd should parse and instantiate")
		return failures

	var player = player_script.new()
	player._ready()

	if player.stats == null:
		failures.append("player should create default stats on ready")
	if player.get_facing_direction() != 1:
		failures.append("player should face right by default")
	if not player.has_method("request_basic_attack"):
		failures.append("player should expose basic attack request")
	if not player.has_method("request_heavy_attack"):
		failures.append("player should expose heavy attack request")
	if not player.has_method("request_dodge"):
		failures.append("player should expose dodge request")

	player.free()
	return failures
