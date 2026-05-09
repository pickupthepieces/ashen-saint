class_name HermannBoss
extends "res://src/enemies/EnemyBase.gd"

signal phase_changed(phase)

@export var phase_two_ratio: float = 0.5

var _phase := 1

func _ready() -> void:
	max_hp = 180.0
	base_attack = 14.0
	patrol_speed = 0.0
	super._ready()

func apply_damage(amount: float) -> void:
	super.apply_damage(amount)
	_update_phase()

func get_phase() -> int:
	return _phase

func _update_phase() -> void:
	if health == null or _phase != 1:
		return
	if float(health.current_hp) <= float(health.max_hp) * phase_two_ratio:
		_phase = 2
		modulate = Color(1.15, 0.86, 0.76, 1.0)
		phase_changed.emit(_phase)
