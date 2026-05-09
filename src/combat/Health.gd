class_name Health
extends Node

signal damaged(amount)
signal healed(amount)
signal died

@export var max_hp: float = 100.0
@export var current_hp: float = 100.0

var _death_emitted := false

func apply_damage(amount: float) -> void:
	if amount <= 0.0:
		return

	current_hp = maxf(0.0, current_hp - amount)
	damaged.emit(amount)
	if current_hp <= 0.0 and not _death_emitted:
		_death_emitted = true
		died.emit()

func heal(amount: float) -> void:
	if amount <= 0.0:
		return

	current_hp = minf(max_hp, current_hp + amount)
	if current_hp > 0.0:
		_death_emitted = false
	healed.emit(amount)

func is_dead() -> bool:
	return current_hp <= 0.0
