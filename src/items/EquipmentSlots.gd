class_name EquipmentSlots
extends Resource

const StatAggregatorScript := preload("res://src/stats/StatAggregator.gd")
const SUPPORTED_SLOTS := [
	"two_hand_sword",
	"head",
	"chest",
	"hands",
	"legs",
	"feet",
	"ring_1",
	"ring_2",
	"amulet",
]

@export var equipped: Dictionary = {}

func equip(item: Resource) -> bool:
	if item == null or item.definition == null:
		return false

	var slot := String(item.definition.slot)
	if not SUPPORTED_SLOTS.has(slot):
		return false

	equipped[slot] = item
	return true

func unequip(slot: String) -> Resource:
	if not equipped.has(slot):
		return null

	var item: Resource = equipped[slot]
	equipped.erase(slot)
	return item

func get_stat_modifiers() -> Array:
	var modifiers: Array = []
	for item in equipped.values():
		for modifier in item.get_stat_modifiers():
			modifiers.append(modifier)
	return modifiers

func calculate_stats(base_stats: Resource) -> Resource:
	var aggregator = StatAggregatorScript.new()
	return aggregator.aggregate(base_stats, get_stat_modifiers())
