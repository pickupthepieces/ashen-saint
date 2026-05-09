class_name ItemGenerator
extends RefCounted

const ItemInstanceScript := preload("res://src/items/ItemInstance.gd")

func generate(definition: Resource, rarity: String, affix_pool: Array, seed: int = -1) -> Resource:
	var rng := RandomNumberGenerator.new()
	if seed >= 0:
		rng.seed = seed
	else:
		rng.randomize()

	var item: Resource = ItemInstanceScript.new()
	item.definition = definition
	item.rarity = rarity
	item.affixes = _roll_affixes(rarity, affix_pool, rng)
	if rarity == "story_legendary":
		item.fixed_effect_id = "%s_story_effect" % String(definition.id)

	return item

func _roll_affixes(rarity: String, affix_pool: Array, rng: RandomNumberGenerator) -> Array:
	var count := _affix_count(rarity, affix_pool.size(), rng)
	var available := affix_pool.duplicate()
	var rolled: Array = []

	for _i in range(count):
		if available.is_empty():
			break
		var index := rng.randi_range(0, available.size() - 1)
		rolled.append(available[index])
		available.remove_at(index)

	return rolled

func _affix_count(rarity: String, pool_size: int, rng: RandomNumberGenerator) -> int:
	if pool_size <= 0:
		return 0
	match rarity:
		"normal":
			return 0
		"magic":
			return rng.randi_range(1, min(2, pool_size))
		"rare":
			return min(3, pool_size)
		"story_legendary":
			return rng.randi_range(1, min(2, pool_size))
		_:
			return 0
