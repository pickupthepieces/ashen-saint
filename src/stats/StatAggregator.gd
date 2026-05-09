class_name StatAggregator
extends RefCounted

const StatBlockScript := preload("res://src/stats/StatBlock.gd")
const STAT_FIELDS := [
	"max_hp",
	"stamina_max",
	"ash_max",
	"base_attack",
	"weapon_attack",
	"armor",
	"move_speed",
	"jump_velocity",
	"gravity",
	"crit_chance",
	"crit_damage",
	"attack_bonus",
	"greyflame_damage_bonus",
	"elite_damage_bonus",
	"kill_life_gain",
]

func aggregate(base_stats, modifiers: Array) -> Resource:
	var result: Resource = StatBlockScript.new()
	for field in STAT_FIELDS:
		var field_name: String = String(field)
		result.set(field_name, base_stats.get(field_name))

	for modifier in modifiers:
		if not modifier is Dictionary:
			continue
		for field in modifier.keys():
			var field_name: String = String(field)
			if not STAT_FIELDS.has(field_name):
				continue

			var current_value: float = float(result.get(field_name))
			var added_value: float = float(modifier[field])
			result.set(field_name, current_value + added_value)

	return result
