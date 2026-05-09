class_name ChapterFlow
extends Node2D

const PlayerScene := preload("res://scenes/player/Player.tscn")
const HudScene := preload("res://scenes/ui/HUD.tscn")
const DialogueBoxScene := preload("res://scenes/ui/DialogueBox.tscn")
const GreyedVillagerScene := preload("res://scenes/enemies/GreyedVillager.tscn")
const FireBearerScene := preload("res://scenes/enemies/FireBearer.tscn")
const WhiteAshSlaveScene := preload("res://scenes/enemies/WhiteAshSlave.tscn")
const StitchedDogScene := preload("res://scenes/enemies/StitchedDog.tscn")
const PenitentSoldierScene := preload("res://scenes/enemies/PenitentSoldier.tscn")
const HermannBossScene := preload("res://scenes/bosses/HermannBoss.tscn")
const MiraScene := preload("res://scenes/npcs/Mira.tscn")

const AshPitBg := preload("res://assets/art/environments/ash-pit-bg.png")
const OldWheatRoadBg := preload("res://assets/art/environments/old-wheat-road-bg.png")
const RottenboneVillageBg := preload("res://assets/art/environments/rottenbone-village-bg.png")
const WhitewoodChapelBg := preload("res://assets/art/environments/whitewood-chapel-bg.png")
const VillageSquareBg := preload("res://assets/art/environments/village-square-bg.png")
const OldCampBg := preload("res://assets/art/environments/old-camp-bg.png")
const EchoRealmBg := preload("res://assets/art/environments/echo-realm-bg.png")

var areas: Array[Dictionary] = [
	{
		"id": "ash_pit",
		"title": "灰坑",
		"objective": "清理灰坑，找到通往旧麦路的出口。",
		"background": AshPitBg,
		"dialogue": "ash_pit_start",
		"enemies": [{"scene": GreyedVillagerScene, "position": Vector2(560, 612)}, {"scene": GreyedVillagerScene, "position": Vector2(760, 612)}, {"scene": GreyedVillagerScene, "position": Vector2(910, 522)}],
		"exit": "F 前往旧麦路"
	},
	{
		"id": "old_wheat_road",
		"title": "旧麦路",
		"objective": "穿过烧焦麦路，处理捧火人。",
		"background": OldWheatRoadBg,
		"dialogue": "old_wheat_road_start",
		"enemies": [{"scene": GreyedVillagerScene, "position": Vector2(510, 612)}, {"scene": FireBearerScene, "position": Vector2(760, 612)}, {"scene": WhiteAshSlaveScene, "position": Vector2(980, 522)}],
		"exit": "F 进入烂骨村"
	},
	{
		"id": "rottenbone_village",
		"title": "烂骨村",
		"objective": "寻找幸存者踪迹。",
		"background": RottenboneVillageBg,
		"dialogue": "rottenbone_village_start",
		"enemies": [{"scene": GreyedVillagerScene, "position": Vector2(460, 612)}, {"scene": StitchedDogScene, "position": Vector2(610, 612)}, {"scene": FireBearerScene, "position": Vector2(760, 612)}, {"scene": PenitentSoldierScene, "position": Vector2(960, 612)}, {"scene": GreyedVillagerScene, "position": Vector2(1060, 522)}],
		"exit": "F 前往白木礼拜堂"
	},
	{
		"id": "whitewood_chapel",
		"title": "白木礼拜堂",
		"objective": "救下米拉，读懂刻名墙。",
		"background": WhitewoodChapelBg,
		"dialogue": "mira_rescued",
		"enemies": [{"scene": WhiteAshSlaveScene, "position": Vector2(520, 612)}, {"scene": FireBearerScene, "position": Vector2(760, 612)}, {"scene": PenitentSoldierScene, "position": Vector2(980, 612)}],
		"mira": true,
		"exit": "F 前往村心广场"
	},
	{
		"id": "village_square",
		"title": "村心广场",
		"objective": "击败赫尔曼，终止名单。",
		"background": VillageSquareBg,
		"dialogue": "boss_before",
		"enemies": [{"scene": HermannBossScene, "position": Vector2(880, 585)}],
		"boss": true,
		"exit": "F 前往旧营火"
	},
	{
		"id": "old_camp",
		"title": "旧营火",
		"objective": "与米拉会合，整理装备，进入遗境。",
		"background": OldCampBg,
		"dialogue": "old_camp_start",
		"enemies": [],
		"mira": true,
		"exit": "F 进入烂骨村遗境"
	},
	{
		"id": "echo_realm",
		"title": "烂骨村遗境",
		"objective": "清理残响，获得掉落后返回旧营火。",
		"background": EchoRealmBg,
		"dialogue": "echo_realm_start",
		"enemies": [{"scene": StitchedDogScene, "position": Vector2(430, 612)}, {"scene": GreyedVillagerScene, "position": Vector2(560, 612)}, {"scene": FireBearerScene, "position": Vector2(720, 612)}, {"scene": WhiteAshSlaveScene, "position": Vector2(900, 612)}, {"scene": PenitentSoldierScene, "position": Vector2(1080, 612)}],
		"exit": "F 返回旧营火"
	}
]

var current_area_index := 0
var flags := {
	"mira_rescued": false,
	"boss_defeated": false,
	"realm_unlocked": false
}
var dialogue_data: Dictionary = {}
var player_near_exit := false
var area_clear := false
var post_boss_dialogue_shown := false

@onready var background_sprite: Sprite2D = $BackgroundSprite
@onready var player: Node = $Player
@onready var enemy_layer: Node2D = $EnemyLayer
@onready var npc_layer: Node2D = $NPCLayer
@onready var exit_area: Area2D = $ExitArea
@onready var exit_label: Label = $ExitArea/ExitLabel
@onready var objective_label: Label = $ObjectiveLayer/ObjectiveLabel
@onready var hud: Node = $HUD
@onready var dialogue_box: Node = $DialogueBox

func _ready() -> void:
	dialogue_data = _load_dialogue()
	hud.player_path = NodePath("../Player")
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	exit_area.body_entered.connect(_on_exit_body_entered)
	exit_area.body_exited.connect(_on_exit_body_exited)
	setup_current_area()

func _process(_delta: float) -> void:
	area_clear = _are_enemies_defeated()
	if get_current_area_id() == "village_square" and area_clear and not post_boss_dialogue_shown:
		post_boss_dialogue_shown = true
		flags["boss_defeated"] = true
		flags["realm_unlocked"] = true
		_show_dialogue("boss_after")
	var dialogue_active: bool = dialogue_box.has_method("is_showing") and dialogue_box.is_showing()
	exit_label.visible = player_near_exit and area_clear and not dialogue_active
	if dialogue_active:
		return
	if player_near_exit and area_clear and Input.is_action_just_pressed("interact"):
		advance_area()

func get_area_count() -> int:
	return areas.size()

func get_current_area_id() -> String:
	return String(areas[current_area_index]["id"])

func advance_area() -> void:
	if get_current_area_id() == "echo_realm":
		current_area_index = _area_index("old_camp")
	elif current_area_index < areas.size() - 1:
		current_area_index += 1
	if is_inside_tree():
		setup_current_area()

func setup_current_area() -> void:
	var area := areas[current_area_index]
	player_near_exit = false
	area_clear = false
	post_boss_dialogue_shown = false
	background_sprite.texture = area["background"]
	objective_label.text = "%s：%s" % [String(area["title"]), String(area["objective"])]
	exit_label.text = String(area["exit"])
	exit_label.visible = false
	player.global_position = Vector2(150, 615)
	if player.has_method("set_checkpoint"):
		player.set_checkpoint(Vector2(150, 615))
	if get_current_area_id() == "old_camp" and player.has_method("refill_potions"):
		player.refill_potions()
	_clear_children(enemy_layer)
	_clear_children(npc_layer)
	_spawn_area(area)
	_show_dialogue(String(area.get("dialogue", "")))

func _spawn_area(area: Dictionary) -> void:
	for enemy_config in area.get("enemies", []):
		var scene: PackedScene = enemy_config["scene"]
		var enemy = scene.instantiate()
		enemy.global_position = enemy_config["position"]
		if enemy.has_method("set_target"):
			enemy.set_target(player)
		enemy_layer.add_child(enemy)
	if area.get("mira", false):
		var mira = MiraScene.instantiate()
		mira.global_position = Vector2(330, 610)
		npc_layer.add_child(mira)

func _are_enemies_defeated() -> bool:
	for enemy in enemy_layer.get_children():
		if enemy.has_method("is_defeated") and not enemy.is_defeated():
			return false
	return true

func _show_dialogue(dialogue_id: String) -> void:
	if dialogue_id == "" or not dialogue_data.has(dialogue_id):
		return
	if player.has_method("set_input_locked"):
		player.set_input_locked(true)
	dialogue_box.show_lines(dialogue_data[dialogue_id])

func _load_dialogue() -> Dictionary:
	var text := FileAccess.get_file_as_string("res://data/dialogue/chapter_01.json")
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	return {}

func _area_index(area_id: String) -> int:
	for index in range(areas.size()):
		if areas[index]["id"] == area_id:
			return index
	return 0

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _on_exit_body_entered(body: Node) -> void:
	if body == player:
		player_near_exit = true

func _on_exit_body_exited(body: Node) -> void:
	if body == player:
		player_near_exit = false

func _on_dialogue_finished() -> void:
	if player != null and player.has_method("set_input_locked"):
		player.set_input_locked(false)
