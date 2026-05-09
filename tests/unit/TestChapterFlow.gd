extends RefCounted

const CHAPTER_FLOW_PATH := "res://src/levels/ChapterFlow.gd"
const CHAPTER_RUN_SCENE_PATH := "res://scenes/levels/ChapterRun.tscn"
const DIALOGUE_PATH := "res://data/dialogue/chapter_01.json"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not FileAccess.file_exists(CHAPTER_FLOW_PATH):
		failures.append("ChapterFlow.gd should exist")
		return failures
	if not ResourceLoader.exists(CHAPTER_RUN_SCENE_PATH):
		failures.append("ChapterRun.tscn should exist")
		return failures
	if not FileAccess.file_exists(DIALOGUE_PATH):
		failures.append("chapter_01.json should exist")
		return failures

	var script := load(CHAPTER_FLOW_PATH)
	if script == null or not script.can_instantiate():
		failures.append("ChapterFlow.gd should parse and instantiate")
		return failures

	var flow = script.new()
	if not flow.has_method("get_area_count") or flow.get_area_count() < 7:
		failures.append("chapter flow should define first chapter, hub, and realm areas")
	if not flow.has_method("get_current_area_id") or flow.get_current_area_id() != "ash_pit":
		failures.append("chapter flow should start at ash_pit")
	if not flow.has_method("advance_area"):
		failures.append("chapter flow should advance areas")
	else:
		flow.advance_area()
		if flow.get_current_area_id() != "old_wheat_road":
			failures.append("chapter flow should advance to old_wheat_road")
		for _i in range(4):
			flow.advance_area()
		if flow.get_current_area_id() != "old_camp":
			failures.append("chapter flow should reach old camp after village square")
		flow.advance_area()
		if flow.get_current_area_id() != "echo_realm":
			failures.append("old camp should enter echo realm")
		flow.advance_area()
		if flow.get_current_area_id() != "old_camp":
			failures.append("echo realm should return to old camp")

	var text := FileAccess.get_file_as_string(DIALOGUE_PATH)
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		failures.append("chapter dialogue should parse as JSON object")
	elif not parsed.has("boss_before") or not parsed.has("boss_after") or not parsed.has("mira_rescued"):
		failures.append("chapter dialogue should include key first chapter beats")

	flow.free()
	return failures
