extends RefCounted

func run() -> Array[String]:
	var failures: Array[String] = []

	_assert_scene_sprite(
		"res://scenes/player/Player.tscn",
		"VisualSprite",
		"res://assets/art/characters/lowen-idle.png",
		failures
	)
	_assert_scene_sprite(
		"res://scenes/enemies/GreyedVillager.tscn",
		"VisualSprite",
		"res://assets/art/enemies/greyed-villager-idle.png",
		failures
	)
	_assert_scene_sprite(
		"res://scenes/levels/AshPitPrototype.tscn",
		"BackgroundSprite",
		"res://assets/art/environments/ash-pit-bg.png",
		failures
	)

	return failures

func _assert_scene_sprite(scene_path: String, node_path: String, texture_path: String, failures: Array[String]) -> void:
	if not FileAccess.file_exists(texture_path):
		failures.append("%s should exist" % texture_path.get_file())
		return

	var scene := load(scene_path)
	if scene == null or not scene.can_instantiate():
		failures.append("%s should instantiate" % scene_path.get_file())
		return

	var instance = scene.instantiate()
	var sprite = instance.get_node_or_null(node_path)
	if sprite == null:
		failures.append("%s should contain %s" % [scene_path.get_file(), node_path])
		instance.free()
		return

	if sprite.texture == null or sprite.texture.resource_path != texture_path:
		failures.append("%s should use %s" % [node_path, texture_path])

	instance.free()
