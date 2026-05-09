class_name DamageCalculator
extends RefCounted

func calculate_damage(
	attacker,
	target,
	skill_power: float,
	damage_type: String = "physical",
	is_critical: bool = false,
	is_elite_or_boss: bool = false
) -> float:
	var raw_damage: float = skill_power * (float(attacker.base_attack) + float(attacker.weapon_attack)) * (1.0 + float(attacker.attack_bonus))
	var typed_damage: float = raw_damage * (1.0 + _damage_type_bonus(attacker, damage_type))
	var critical_damage: float = typed_damage
	if is_critical:
		critical_damage *= 1.0 + float(attacker.crit_damage)

	var elite_damage: float = critical_damage
	if is_elite_or_boss:
		elite_damage *= 1.0 + float(attacker.elite_damage_bonus)

	return maxf(1.0, elite_damage - float(target.armor) * 0.5)

func _damage_type_bonus(attacker, damage_type: String) -> float:
	if damage_type == "greyflame":
		return float(attacker.greyflame_damage_bonus)
	return 0.0
