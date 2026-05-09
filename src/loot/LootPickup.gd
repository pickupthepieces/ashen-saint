class_name LootPickup
extends Area2D

const ItemDefinitionScript := preload("res://src/items/ItemDefinition.gd")
const ItemInstanceScript := preload("res://src/items/ItemInstance.gd")
const AffixDefinitionScript := preload("res://src/items/AffixDefinition.gd")
const ItemGeneratorScript := preload("res://src/items/ItemGenerator.gd")

@export var display_name: String = "旧裁决剑"
@export var rarity: String = "magic"
@export var slot: String = "two_hand_sword"
@export var weapon_attack: float = 18.0
@export var icon_texture: Texture2D

var _nearby_player: Node

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var sprite = get_node_or_null("Icon")
	if sprite != null and icon_texture != null:
		sprite.texture = icon_texture
	_update_prompt(false)

func _process(_delta: float) -> void:
	if _nearby_player != null and Input.is_action_just_pressed("interact"):
		_pick_up(_nearby_player)

func create_item_instance() -> Resource:
	var definition = ItemDefinitionScript.new()
	definition.id = display_name.to_snake_case()
	definition.display_name = display_name
	definition.slot = slot
	definition.base_modifiers = {"weapon_attack": weapon_attack}

	var generator = ItemGeneratorScript.new()
	return generator.generate(definition, rarity, _default_affix_pool())

func _pick_up(player: Node) -> void:
	if player == null or not player.has_method("pickup_item"):
		return
	player.pickup_item(create_item_instance())
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("pickup_item"):
		_nearby_player = body
		_update_prompt(true)

func _on_body_exited(body: Node) -> void:
	if body == _nearby_player:
		_nearby_player = null
		_update_prompt(false)

func _update_prompt(is_visible: bool) -> void:
	var prompt = get_node_or_null("PromptLabel")
	if prompt != null:
		prompt.visible = is_visible

func _default_affix_pool() -> Array:
	return [
		_make_affix("tempered_edge", "锻刃", {"weapon_attack": 4.0}),
		_make_affix("quiet_hand", "稳手", {"crit_chance": 0.04}),
		_make_affix("old_oath", "旧誓", {"attack_bonus": 0.08}),
		_make_affix("white_ash", "白灰", {"armor": 3.0}),
		_make_affix("greyflame_mark", "灰焰痕", {"greyflame_damage_bonus": 0.10}),
		_make_affix("last_breath", "余息", {"kill_life_gain": 2.0}),
		_make_affix("walker", "行路", {"move_speed": 8.0}),
		_make_affix("executioner", "裁罪", {"elite_damage_bonus": 0.12}),
	]

func _make_affix(id: String, affix_name: String, modifiers: Dictionary) -> Resource:
	var affix = AffixDefinitionScript.new()
	affix.id = id
	affix.display_name = affix_name
	affix.modifiers = modifiers
	return affix
