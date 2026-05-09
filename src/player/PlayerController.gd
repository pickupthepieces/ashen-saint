class_name PlayerController
extends CharacterBody2D

const StatBlockScript := preload("res://src/stats/StatBlock.gd")
const InventoryScript := preload("res://src/items/Inventory.gd")
const EquipmentSlotsScript := preload("res://src/items/EquipmentSlots.gd")

@export var stats: Resource
@export var inventory: Resource
@export var equipment: Resource
@export var basic_attack_damage: float = 18.0
@export var attack_feedback_duration: float = 0.16
@export var max_hp: float = 100.0
@export var current_hp: float = 100.0
@export var max_stamina: float = 100.0
@export var current_stamina: float = 100.0
@export var stamina_recovery_per_second: float = 25.0
@export var potion_charges: int = 2
@export var max_potion_charges: int = 2
@export var potion_heal_ratio: float = 0.45
@export var dodge_stamina_cost: float = 35.0
@export var heavy_attack_stamina_cost: float = 25.0
@export var cleave_stamina_cost: float = 15.0
@export var dash_stamina_cost: float = 20.0
@export var heavy_attack_multiplier: float = 1.8
@export var cleave_multiplier: float = 1.3
@export var counter_multiplier: float = 2.2

var base_basic_attack_damage := 18.0
var checkpoint_position := Vector2(150, 615)
var input_locked := false
var _facing_direction := 1
var _basic_attack_requested := false
var _heavy_attack_requested := false
var _dodge_requested := false
var _attack_feedback_time := 0.0
var _forced_move_time := 0.0
var _forced_move_speed := 0.0
var _invulnerable_time := 0.0

func _ready() -> void:
	add_to_group("player")
	if stats == null:
		stats = StatBlockScript.new()
	if inventory == null:
		inventory = InventoryScript.new()
	if equipment == null:
		equipment = EquipmentSlotsScript.new()
	if current_hp <= 0.0:
		current_hp = max_hp
	max_stamina = float(stats.stamina_max)
	if current_stamina <= 0.0:
		current_stamina = max_stamina
	checkpoint_position = global_position
	base_basic_attack_damage = basic_attack_damage
	_refresh_equipment_stats()
	_update_attack_area()

func _physics_process(delta: float) -> void:
	if stats == null:
		stats = StatBlockScript.new()

	_recover_resources(delta)
	_forced_move_time = maxf(0.0, _forced_move_time - delta)
	_invulnerable_time = maxf(0.0, _invulnerable_time - delta)
	if not is_on_floor():
		velocity.y += float(stats.gravity) * delta

	var input_axis := 0.0
	if not input_locked:
		input_axis = Input.get_axis("move_left", "move_right")
	if _forced_move_time > 0.0:
		velocity.x = _forced_move_speed
	else:
		velocity.x = input_axis * float(stats.move_speed)
	if input_axis > 0.0:
		_facing_direction = 1
	elif input_axis < 0.0:
		_facing_direction = -1
	_update_attack_area()

	if not input_locked and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = float(stats.jump_velocity)
	if not input_locked and Input.is_action_just_pressed("basic_attack"):
		request_basic_attack()
	if not input_locked and Input.is_action_just_pressed("heavy_attack"):
		request_heavy_attack()
	if not input_locked and Input.is_action_just_pressed("dodge"):
		request_dodge()
	if not input_locked and Input.is_action_just_pressed("skill_1"):
		request_cleave()
	if not input_locked and Input.is_action_just_pressed("skill_2"):
		request_dash()
	if not input_locked and Input.is_action_just_pressed("skill_3"):
		request_counter()
	if not input_locked and Input.is_action_just_pressed("potion"):
		use_potion()

	_update_attack_feedback(delta)
	move_and_slide()

func request_basic_attack() -> void:
	_basic_attack_requested = true
	_attack_feedback_time = attack_feedback_duration
	_apply_attack_visual(true)
	apply_basic_attack_to(_collect_attack_targets())

func request_heavy_attack() -> bool:
	if not _spend_stamina(heavy_attack_stamina_cost):
		return false
	_heavy_attack_requested = true
	_attack_feedback_time = attack_feedback_duration * 1.35
	_apply_attack_visual(true)
	_apply_damage_to_targets(_collect_attack_targets(), basic_attack_damage * heavy_attack_multiplier)
	return true

func request_dodge() -> bool:
	if not _spend_stamina(dodge_stamina_cost):
		return false
	_dodge_requested = true
	_forced_move_time = 0.18
	_forced_move_speed = 330.0 * float(_facing_direction)
	_invulnerable_time = 0.22
	return true

func request_cleave() -> bool:
	if not _spend_stamina(cleave_stamina_cost):
		return false
	_attack_feedback_time = attack_feedback_duration * 1.15
	_apply_attack_visual(true)
	_apply_damage_to_targets(_collect_attack_targets(), basic_attack_damage * cleave_multiplier)
	return true

func request_dash() -> bool:
	if not _spend_stamina(dash_stamina_cost):
		return false
	_forced_move_time = 0.24
	_forced_move_speed = 470.0 * float(_facing_direction)
	_invulnerable_time = 0.16
	return true

func request_counter() -> bool:
	var self_cost := maxf(1.0, max_hp * 0.08)
	if current_hp <= self_cost + 1.0:
		return false
	current_hp -= self_cost
	_attack_feedback_time = attack_feedback_duration * 1.5
	_apply_attack_visual(true)
	_apply_damage_to_targets(_collect_attack_targets(), basic_attack_damage * counter_multiplier)
	return true

func consume_basic_attack_request() -> bool:
	var was_requested := _basic_attack_requested
	_basic_attack_requested = false
	return was_requested

func consume_heavy_attack_request() -> bool:
	var was_requested := _heavy_attack_requested
	_heavy_attack_requested = false
	return was_requested

func consume_dodge_request() -> bool:
	var was_requested := _dodge_requested
	_dodge_requested = false
	return was_requested

func get_facing_direction() -> int:
	return _facing_direction

func is_attack_feedback_active() -> bool:
	return _attack_feedback_time > 0.0

func apply_basic_attack_to(targets: Array) -> int:
	return _apply_damage_to_targets(targets, basic_attack_damage)

func apply_heavy_attack_to(targets: Array) -> int:
	if not _spend_stamina(heavy_attack_stamina_cost):
		return 0
	_heavy_attack_requested = true
	_attack_feedback_time = attack_feedback_duration * 1.35
	_apply_attack_visual(true)
	return _apply_damage_to_targets(targets, basic_attack_damage * heavy_attack_multiplier)

func apply_cleave_to(targets: Array) -> int:
	if not _spend_stamina(cleave_stamina_cost):
		return 0
	_attack_feedback_time = attack_feedback_duration * 1.15
	_apply_attack_visual(true)
	return _apply_damage_to_targets(targets, basic_attack_damage * cleave_multiplier)

func use_potion() -> bool:
	if potion_charges <= 0 or current_hp >= max_hp:
		return false
	potion_charges -= 1
	current_hp = minf(max_hp, current_hp + max_hp * potion_heal_ratio)
	return true

func refill_potions() -> void:
	potion_charges = max_potion_charges

func _apply_damage_to_targets(targets: Array, damage: float) -> int:
	var hit_count := 0
	for target in targets:
		if target == null or target == self:
			continue
		if not target.has_method("apply_damage"):
			continue
		target.apply_damage(damage)
		hit_count += 1
	return hit_count

func pickup_item(item: Resource) -> void:
	if item == null:
		return
	if inventory == null:
		inventory = InventoryScript.new()
	if equipment == null:
		equipment = EquipmentSlotsScript.new()

	inventory.add_item(item)
	if item.definition != null and String(item.definition.slot) == "two_hand_sword":
		equipment.equip(item)
		_refresh_equipment_stats()

func get_inventory_count() -> int:
	if inventory == null:
		return 0
	return inventory.items.size()

func get_inventory_items() -> Array:
	if inventory == null:
		return []
	return inventory.items

func get_equipped_weapon_name() -> String:
	if equipment == null or not equipment.equipped.has("two_hand_sword"):
		return "无"
	var item = equipment.equipped["two_hand_sword"]
	if item == null or item.definition == null:
		return "无"
	return String(item.definition.display_name)

func get_attack_power() -> float:
	return basic_attack_damage

func get_hp_text() -> String:
	return "%.0f/%.0f" % [current_hp, max_hp]

func get_stamina_text() -> String:
	return "%.0f/%.0f" % [current_stamina, max_stamina]

func get_potion_text() -> String:
	return "%d/%d" % [potion_charges, max_potion_charges]

func set_checkpoint(position: Vector2) -> void:
	checkpoint_position = position

func set_input_locked(is_locked: bool) -> void:
	input_locked = is_locked
	if is_locked:
		velocity.x = 0.0

func apply_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	if _invulnerable_time > 0.0:
		return
	current_hp = maxf(0.0, current_hp - amount)
	if current_hp <= 0.0:
		_respawn()

func is_dead() -> bool:
	return current_hp <= 0.0

func _respawn() -> void:
	global_position = checkpoint_position
	current_hp = max_hp
	current_stamina = max_stamina
	velocity = Vector2.ZERO

func _collect_attack_targets() -> Array:
	var attack_area = get_node_or_null("AttackArea")
	if attack_area == null:
		return []
	return attack_area.get_overlapping_bodies()

func _update_attack_area() -> void:
	var attack_area = get_node_or_null("AttackArea")
	if attack_area == null:
		return
	attack_area.position.x = absf(float(attack_area.position.x)) * float(_facing_direction)

func _update_attack_feedback(delta: float) -> void:
	if _attack_feedback_time <= 0.0:
		return

	_attack_feedback_time = maxf(0.0, _attack_feedback_time - delta)
	if _attack_feedback_time <= 0.0:
		_apply_attack_visual(false)

func _apply_attack_visual(active: bool) -> void:
	var visual_sprite = get_node_or_null("VisualSprite")
	if visual_sprite != null:
		if active:
			visual_sprite.modulate = Color(1.28, 1.14, 0.96, 1.0)
			visual_sprite.scale = Vector2(0.58, 0.58)
		else:
			visual_sprite.modulate = Color(1, 1, 1, 1)
			visual_sprite.scale = Vector2(0.55, 0.55)

	var sword = get_node_or_null("Greatsword")
	if sword == null:
		return

	if active:
		sword.rotation = 0.9 * float(_facing_direction)
		sword.modulate = Color(1.35, 1.16, 0.95, 1.0)
	else:
		sword.rotation = 0.45 * float(_facing_direction)
		sword.modulate = Color(1, 1, 1, 1)

func _refresh_equipment_stats() -> void:
	if equipment == null or stats == null:
		return
	var final_stats = equipment.calculate_stats(stats)
	basic_attack_damage = base_basic_attack_damage + float(final_stats.weapon_attack) * 0.5
	max_hp = float(final_stats.max_hp)
	max_stamina = float(final_stats.stamina_max)
	current_hp = minf(current_hp, max_hp)
	current_stamina = minf(current_stamina, max_stamina)

func _recover_resources(delta: float) -> void:
	if input_locked:
		return
	current_stamina = minf(max_stamina, current_stamina + stamina_recovery_per_second * delta)

func _spend_stamina(amount: float) -> bool:
	if amount <= 0.0:
		return true
	if current_stamina < amount:
		return false
	current_stamina -= amount
	return true
