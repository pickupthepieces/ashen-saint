extends RefCounted

const STAT_BLOCK_PATH := "res://src/stats/StatBlock.gd"
const DAMAGE_CALCULATOR_PATH := "res://src/combat/DamageCalculator.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not ResourceLoader.exists(STAT_BLOCK_PATH):
		failures.append("StatBlock.gd should exist")
		return failures
	if not ResourceLoader.exists(DAMAGE_CALCULATOR_PATH):
		failures.append("DamageCalculator.gd should exist")
		return failures

	var stat_script := load(STAT_BLOCK_PATH)
	var calculator_script := load(DAMAGE_CALCULATOR_PATH)
	if stat_script == null or not stat_script.can_instantiate():
		failures.append("StatBlock.gd should parse and instantiate")
		return failures
	if calculator_script == null or not calculator_script.can_instantiate():
		failures.append("DamageCalculator.gd should parse and instantiate")
		return failures

	var calculator = calculator_script.new()

	var attacker = stat_script.new()
	attacker.base_attack = 10.0
	attacker.weapon_attack = 20.0

	var target = stat_script.new()
	target.armor = 5.0

	_assert_close(
		calculator.calculate_damage(attacker, target, 1.5, "physical", false, false),
		42.5,
		"base physical damage should apply skill power and armor reduction",
		failures
	)

	attacker.crit_damage = 0.5
	_assert_close(
		calculator.calculate_damage(attacker, target, 1.0, "physical", true, false),
		42.5,
		"critical damage should multiply typed damage before armor reduction",
		failures
	)

	attacker.attack_bonus = 0.2
	attacker.greyflame_damage_bonus = 0.25
	_assert_close(
		calculator.calculate_damage(attacker, target, 1.0, "greyflame", false, false),
		42.5,
		"greyflame damage should apply attack and greyflame bonuses",
		failures
	)

	attacker.attack_bonus = 0.0
	attacker.greyflame_damage_bonus = 0.0
	attacker.elite_damage_bonus = 0.5
	_assert_close(
		calculator.calculate_damage(attacker, target, 1.0, "physical", false, true),
		42.5,
		"elite damage bonus should apply before armor reduction",
		failures
	)

	target.armor = 1000.0
	_assert_close(
		calculator.calculate_damage(attacker, target, 0.1, "physical", false, false),
		1.0,
		"final damage should never fall below 1",
		failures
	)

	return failures

func _assert_close(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > 0.001:
		failures.append("%s: expected %.3f, got %.3f" % [message, expected, actual])
