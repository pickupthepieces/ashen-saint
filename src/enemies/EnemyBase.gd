class_name EnemyBase
extends CharacterBody2D

const StatBlockScript := preload("res://src/stats/StatBlock.gd")
const HealthScript := preload("res://src/combat/Health.gd")

@export var stats: Resource
@export var patrol_speed: float = 45.0
@export var hit_flash_duration: float = 0.12
@export var loot_scene: PackedScene
@export var max_hp: float = 35.0
@export var base_attack: float = 6.0
@export var contact_damage: float = 8.0
@export var contact_damage_interval: float = 1.0
@export var aggro_range: float = 560.0
@export var preferred_distance: float = 30.0

var health: Node
var target: Node2D
var _defeated := false
var _direction := -1.0
var _hit_flash_time := 0.0
var _contact_damage_cooldown := 0.0
var _spawn_position := Vector2.ZERO

func _ready() -> void:
	_spawn_position = global_position
	if stats == null:
		stats = StatBlockScript.new()
	stats.max_hp = max_hp
	stats.base_attack = base_attack
	stats.move_speed = patrol_speed

	health = get_node_or_null("Health")
	if health == null:
		health = HealthScript.new()
		health.name = "Health"
		add_child(health)
	health.max_hp = float(stats.max_hp)
	health.current_hp = float(stats.max_hp)
	health.died.connect(_on_died)
	_acquire_target()

func _physics_process(delta: float) -> void:
	if _defeated:
		velocity = Vector2.ZERO
		return

	if target == null or not is_instance_valid(target):
		_acquire_target()
	_contact_damage_cooldown = maxf(0.0, _contact_damage_cooldown - delta)
	_update_hit_flash(delta)
	if not is_on_floor():
		velocity.y += float(stats.gravity) * delta
	_update_direction()
	if target != null and is_instance_valid(target) and absf(target.global_position.x - global_position.x) <= preferred_distance:
		velocity.x = 0.0
	else:
		velocity.x = _direction * float(stats.move_speed)
	move_and_slide()
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		if collision != null:
			try_contact_damage(collision.get_collider())

func apply_damage(amount: float) -> void:
	if health != null:
		health.apply_damage(amount)
		if not _defeated:
			_hit_flash_time = hit_flash_duration
			modulate = Color(1.35, 0.82, 0.72, 1.0)

func is_defeated() -> bool:
	return _defeated

func set_target(new_target: Node2D) -> void:
	target = new_target

func try_contact_damage(target: Object) -> bool:
	if _defeated or _contact_damage_cooldown > 0.0:
		return false
	if target == null or not target.has_method("apply_damage"):
		return false
	target.apply_damage(contact_damage)
	_contact_damage_cooldown = contact_damage_interval
	return true

func get_drop_scene_path() -> String:
	if loot_scene == null:
		return ""
	return loot_scene.resource_path

func _on_died() -> void:
	_defeated = true
	velocity = Vector2.ZERO
	_drop_loot()
	visible = false
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)

func _update_hit_flash(delta: float) -> void:
	if _hit_flash_time <= 0.0:
		return

	_hit_flash_time = maxf(0.0, _hit_flash_time - delta)
	if _hit_flash_time <= 0.0:
		modulate = Color(1, 1, 1, 1)

func _acquire_target() -> void:
	if not is_inside_tree():
		return
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is Node2D:
		target = players[0]

func _update_direction() -> void:
	if target != null and is_instance_valid(target):
		var offset := target.global_position.x - global_position.x
		if absf(offset) <= aggro_range:
			_direction = signf(offset)
	if is_zero_approx(_direction):
		_direction = -1.0
	var visual = get_node_or_null("VisualSprite")
	if visual != null:
		visual.flip_h = _direction > 0.0

func _drop_loot() -> void:
	if loot_scene == null or get_parent() == null:
		return
	var loot = loot_scene.instantiate()
	loot.global_position = global_position + Vector2(0, -24)
	get_parent().add_child(loot)
