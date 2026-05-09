extends RefCounted

const SPRITE_ANIMATOR_PATH := "res://src/visual/SpriteAnimator.gd"
const PLAYER_SCENE_PATH := "res://scenes/player/Player.tscn"
const HUD_SCENE_PATH := "res://scenes/ui/HUD.tscn"
const DIALOGUE_SCENE_PATH := "res://scenes/ui/DialogueBox.tscn"

func run() -> Array[String]:
	var failures: Array[String] = []

	if not FileAccess.file_exists(SPRITE_ANIMATOR_PATH):
		failures.append("SpriteAnimator.gd should exist for non-placeholder animation")
	else:
		var animator_script := load(SPRITE_ANIMATOR_PATH)
		if animator_script == null or not animator_script.can_instantiate():
			failures.append("SpriteAnimator.gd should parse and instantiate")

	var player_scene := load(PLAYER_SCENE_PATH)
	if player_scene == null or not player_scene.can_instantiate():
		failures.append("Player.tscn should load")
	else:
		var player = player_scene.instantiate()
		var visual = player.get_node_or_null("VisualSprite")
		if visual == null or visual.get_script() == null:
			failures.append("player VisualSprite should use SpriteAnimator")
		player.free()

	var dialogue_scene := load(DIALOGUE_SCENE_PATH)
	if dialogue_scene == null or not dialogue_scene.can_instantiate():
		failures.append("DialogueBox.tscn should load")
	else:
		var dialogue = dialogue_scene.instantiate()
		if dialogue.get_node_or_null("Panel/PortraitPanel") == null:
			failures.append("dialogue box should include a portrait panel")
		if dialogue.get_node_or_null("Panel/ProgressMark") == null:
			failures.append("dialogue box should include a progress mark")
		dialogue.free()

	var hud_scene := load(HUD_SCENE_PATH)
	if hud_scene == null or not hud_scene.can_instantiate():
		failures.append("HUD.tscn should load")
	else:
		var hud = hud_scene.instantiate()
		if hud.get_node_or_null("Root/InventoryPanel/ItemListPanel") == null:
			failures.append("inventory should have a dedicated item list panel")
		if hud.get_node_or_null("Root/InventoryPanel/DetailPanel") == null:
			failures.append("inventory should have a dedicated detail panel")
		if hud.get_node_or_null("Root/InventoryPanel/HintStrip") == null:
			failures.append("inventory should have a bottom hint strip")
		hud.free()

	return failures
