class_name Inventory
extends Resource

@export var items: Array = []
@export var gold: int = 0

func add_item(item: Resource) -> void:
	items.append(item)

func remove_item(item: Resource) -> bool:
	var index := items.find(item)
	if index < 0:
		return false
	items.remove_at(index)
	return true

func contains_item(item: Resource) -> bool:
	return items.has(item)
