extends RefCounted

const REQUIRED_SCENES := [
	"res://scenes/player/Player.tscn",
	"res://scenes/enemies/GreyedVillager.tscn",
	"res://scenes/enemies/FireBearer.tscn",
	"res://scenes/bosses/HermannBoss.tscn",
	"res://scenes/npcs/Mira.tscn",
	"res://scenes/loot/LootPickup.tscn",
	"res://scenes/ui/HUD.tscn",
	"res://scenes/levels/ChapterRun.tscn",
	"res://scenes/levels/OldWheatRoad.tscn",
	"res://scenes/levels/RottenboneVillage.tscn",
	"res://scenes/levels/WhitewoodChapel.tscn",
	"res://scenes/levels/VillageSquare.tscn",
	"res://scenes/levels/OldCamp.tscn",
	"res://scenes/levels/EchoRealm.tscn",
	"res://scenes/levels/DeepLayer.tscn",
]

const REQUIRED_ART := [
	"res://assets/art/characters/lowen-sprite-sheet-alpha-clean.png",
	"res://assets/art/enemies/greyed-villager-sprite-sheet-alpha-clean.png",
	"res://assets/art/enemies/fire-bearer-sprite-sheet-alpha-clean.png",
	"res://assets/art/bosses/hermann-sprite-sheet-alpha-clean.png",
	"res://assets/art/npcs/mira-sheet.png",
	"res://assets/art/environments/ash-pit-bg.png",
	"res://assets/art/environments/old-wheat-road-bg.png",
	"res://assets/art/environments/rottenbone-village-bg.png",
	"res://assets/art/environments/whitewood-chapel-bg.png",
	"res://assets/art/environments/village-square-bg.png",
	"res://assets/art/environments/old-camp-bg.png",
	"res://assets/art/environments/echo-realm-bg.png",
	"res://assets/art/environments/deep-layer-bg.png",
	"res://assets/art/items/loot-icons-sheet-alpha-clean.png",
]

func run() -> Array[String]:
	var failures: Array[String] = []

	for art_path in REQUIRED_ART:
		if not FileAccess.file_exists(art_path):
			failures.append("%s should exist" % art_path)

	for scene_path in REQUIRED_SCENES:
		if not ResourceLoader.exists(scene_path):
			failures.append("%s should exist" % scene_path)
			continue
		var scene := load(scene_path)
		if scene == null or not scene.can_instantiate():
			failures.append("%s should load and instantiate" % scene_path)
			continue
		var instance = scene.instantiate()
		instance.free()

	return failures
