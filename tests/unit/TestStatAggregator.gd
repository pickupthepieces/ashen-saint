extends RefCounted

const STAT_BLOCK_PATH := "res://src/stats/StatBlock.gd"
const STAT_AGGREGATOR_PATH := "res://src/stats/StatAggregator.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not ResourceLoader.exists(STAT_BLOCK_PATH):
		failures.append("StatBlock.gd should exist")
		return failures
	if not ResourceLoader.exists(STAT_AGGREGATOR_PATH):
		failures.append("StatAggregator.gd should exist")
		return failures

	var stat_script := load(STAT_BLOCK_PATH)
	var aggregator_script := load(STAT_AGGREGATOR_PATH)
	if stat_script == null or not stat_script.can_instantiate():
		failures.append("StatBlock.gd should parse and instantiate")
		return failures
	if aggregator_script == null or not aggregator_script.can_instantiate():
		failures.append("StatAggregator.gd should parse and instantiate")
		return failures

	var base_stats = stat_script.new()
	base_stats.max_hp = 120.0
	base_stats.base_attack = 10.0
	base_stats.move_speed = 180.0
	base_stats.jump_velocity = -360.0
	base_stats.gravity = 980.0

	var aggregator = aggregator_script.new()
	var result = aggregator.aggregate(base_stats, [
		{"weapon_attack": 25.0},
		{"max_hp": 30.0, "attack_bonus": 0.2, "jump_velocity": -20.0},
		{"unknown_stat": 999.0}
	])

	_assert_close(result.max_hp, 150.0, "max_hp modifiers should add to base", failures)
	_assert_close(result.base_attack, 10.0, "base_attack should be preserved", failures)
	_assert_close(result.weapon_attack, 25.0, "weapon_attack should aggregate", failures)
	_assert_close(result.attack_bonus, 0.2, "attack_bonus should aggregate", failures)
	_assert_close(result.move_speed, 180.0, "move_speed should be preserved", failures)
	_assert_close(result.jump_velocity, -380.0, "jump_velocity modifiers should aggregate", failures)
	_assert_close(result.gravity, 980.0, "gravity should be preserved", failures)

	return failures

func _assert_close(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > 0.001:
		failures.append("%s: expected %.3f, got %.3f" % [message, expected, actual])
