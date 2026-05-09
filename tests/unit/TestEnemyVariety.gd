extends RefCounted

const ENEMY_SCENES := {
	"WhiteAshSlave": "res://scenes/enemies/WhiteAshSlave.tscn",
	"StitchedDog": "res://scenes/enemies/StitchedDog.tscn",
	"PenitentSoldier": "res://scenes/enemies/PenitentSoldier.tscn",
}

func run() -> Array[String]:
	var failures: Array[String] = []

	for enemy_name in ENEMY_SCENES.keys():
		var path: String = ENEMY_SCENES[enemy_name]
		if not ResourceLoader.exists(path):
			failures.append("%s scene should exist for first chapter enemy variety" % enemy_name)
			continue
		var scene := load(path)
		if scene == null or not scene.can_instantiate():
			failures.append("%s scene should load and instantiate" % enemy_name)
			continue
		var enemy = scene.instantiate()
		enemy._ready()
		if enemy.health == null:
			failures.append("%s should create health on ready" % enemy_name)
		if enemy_name == "WhiteAshSlave" and enemy.max_hp < 80.0:
			failures.append("WhiteAshSlave should be a durable heavy enemy")
		if enemy_name == "StitchedDog" and enemy.patrol_speed < 90.0:
			failures.append("StitchedDog should be a fast pressure enemy")
		if enemy_name == "PenitentSoldier" and enemy.max_hp < 120.0:
			failures.append("PenitentSoldier should be an elite enemy")
		enemy.free()

	return failures
