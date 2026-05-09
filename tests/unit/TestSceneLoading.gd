extends RefCounted

const PLAYER_SCENE_PATH := "res://scenes/player/Player.tscn"
const ASH_PIT_SCENE_PATH := "res://scenes/levels/AshPitPrototype.tscn"
const MAIN_SCENE_PATH := "res://scenes/main/Main.tscn"
const CHAPTER_RUN_SCENE_PATH := "res://scenes/levels/ChapterRun.tscn"

func run() -> Array[String]:
	var failures: Array[String] = []
	for path in [PLAYER_SCENE_PATH, ASH_PIT_SCENE_PATH, MAIN_SCENE_PATH, CHAPTER_RUN_SCENE_PATH]:
		if not ResourceLoader.exists(path):
			failures.append("%s should exist" % path.get_file())
			return failures

		var scene := load(path)
		if scene == null or not scene.can_instantiate():
			failures.append("%s should load and instantiate" % path.get_file())
			return failures

		var instance = scene.instantiate()
		if instance == null:
			failures.append("%s should instantiate a node" % path.get_file())
			return failures
		instance.free()

	return failures
