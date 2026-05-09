extends RefCounted

const DIALOGUE_BOX_PATH := "res://src/ui/DialogueBox.gd"
const DIALOGUE_BOX_SCENE_PATH := "res://scenes/ui/DialogueBox.tscn"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not FileAccess.file_exists(DIALOGUE_BOX_PATH):
		failures.append("DialogueBox.gd should exist")
		return failures
	if not ResourceLoader.exists(DIALOGUE_BOX_SCENE_PATH):
		failures.append("DialogueBox.tscn should exist")
		return failures

	var scene := load(DIALOGUE_BOX_SCENE_PATH)
	if scene == null or not scene.can_instantiate():
		failures.append("DialogueBox.tscn should load and instantiate")
		return failures

	var box = scene.instantiate()
	if not box.has_method("show_lines"):
		failures.append("dialogue box should show line arrays")
	if box.get_node_or_null("Panel/SpeakerLabel") == null:
		failures.append("dialogue box should contain SpeakerLabel")
	if box.get_node_or_null("Panel/LineLabel") == null:
		failures.append("dialogue box should contain LineLabel")
	box.free()
	return failures
