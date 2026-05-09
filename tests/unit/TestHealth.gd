extends RefCounted

const HEALTH_PATH := "res://src/combat/Health.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not ResourceLoader.exists(HEALTH_PATH):
		failures.append("Health.gd should exist")
		return failures

	var health_script := load(HEALTH_PATH)
	if health_script == null or not health_script.can_instantiate():
		failures.append("Health.gd should parse and instantiate")
		return failures

	var health = health_script.new()
	health.max_hp = 50.0
	health.current_hp = 50.0

	health.apply_damage(12.5)
	_assert_close(health.current_hp, 37.5, "damage should reduce current hp", failures)
	if health.is_dead():
		failures.append("health should not be dead before hp reaches zero")

	health.apply_damage(100.0)
	_assert_close(health.current_hp, 0.0, "damage should not reduce hp below zero", failures)
	if not health.is_dead():
		failures.append("health should be dead at zero hp")

	health.heal(20.0)
	_assert_close(health.current_hp, 20.0, "heal should restore hp from zero", failures)
	health.heal(100.0)
	_assert_close(health.current_hp, 50.0, "heal should not exceed max hp", failures)

	health.free()
	return failures

func _assert_close(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > 0.001:
		failures.append("%s: expected %.3f, got %.3f" % [message, expected, actual])
