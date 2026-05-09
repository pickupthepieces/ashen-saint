extends RefCounted

const PLAYER_CONTROLLER_PATH := "res://src/player/PlayerController.gd"
const ENEMY_BASE_PATH := "res://src/enemies/EnemyBase.gd"

func run() -> Array[String]:
	var failures: Array[String] = []

	var player_script := load(PLAYER_CONTROLLER_PATH)
	var enemy_script := load(ENEMY_BASE_PATH)
	if player_script == null or not player_script.can_instantiate():
		failures.append("PlayerController.gd should parse and instantiate")
		return failures
	if enemy_script == null or not enemy_script.can_instantiate():
		failures.append("EnemyBase.gd should parse and instantiate")
		return failures

	var player = player_script.new()
	player._ready()

	for method_name in ["use_potion", "apply_heavy_attack_to", "apply_cleave_to", "request_dash"]:
		if not player.has_method(method_name):
			failures.append("player should expose %s" % method_name)
			player.free()
			return failures

	player.current_hp = 40.0
	var starting_potions: int = player.potion_charges
	player.use_potion()
	if player.current_hp <= 40.0:
		failures.append("potion should restore player hp")
	if player.potion_charges != starting_potions - 1:
		failures.append("potion should consume one charge")

	var starting_stamina: float = player.current_stamina
	if not player.request_dodge():
		failures.append("dodge should succeed when stamina is available")
	if player.current_stamina >= starting_stamina:
		failures.append("dodge should consume stamina")

	player.current_stamina = player.max_stamina
	var enemy = enemy_script.new()
	enemy._ready()
	var before_hp: float = float(enemy.health.current_hp)
	var heavy_hits: int = player.apply_heavy_attack_to([enemy])
	if heavy_hits != 1:
		failures.append("heavy attack should hit one explicit target")
	if float(enemy.health.current_hp) > before_hp - player.basic_attack_damage:
		failures.append("heavy attack should deal more damage than a basic attack")

	player.current_stamina = player.max_stamina
	var enemy_a = enemy_script.new()
	var enemy_b = enemy_script.new()
	enemy_a._ready()
	enemy_b._ready()
	var cleave_hits: int = player.apply_cleave_to([enemy_a, enemy_b])
	if cleave_hits != 2:
		failures.append("cleave should hit multiple explicit targets")
	if float(enemy_a.health.current_hp) >= float(enemy_a.health.max_hp) or float(enemy_b.health.current_hp) >= float(enemy_b.health.max_hp):
		failures.append("cleave should damage every target it reports")

	player.current_stamina = player.max_stamina
	if not player.request_dash():
		failures.append("dash skill should succeed when stamina is available")
	if player.current_stamina >= player.max_stamina:
		failures.append("dash skill should consume stamina")

	player.current_stamina = 0.0
	if player.request_dodge():
		failures.append("dodge should fail without stamina")

	enemy.free()
	enemy_a.free()
	enemy_b.free()
	player.free()
	return failures
