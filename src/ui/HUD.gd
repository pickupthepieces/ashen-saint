class_name HUD
extends CanvasLayer

@export var player_path: NodePath

func _ready() -> void:
	var hint_label = _hint_label()
	hint_label.text = "A/D 移动  W/Space 跳跃  左键攻击  F 拾取  I 背包"
	set_inventory_visible(false)

func _process(_delta: float) -> void:
	var player = get_node_or_null(player_path)
	if Input.is_action_just_pressed("inventory"):
		set_inventory_visible(not is_inventory_visible())
		render_inventory(player)

	var stats_label = _stats_label()
	if player == null:
		stats_label.text = "攻击 --  背包 --"
		return

	var attack := 0.0
	var count := 0
	var hp_text := "--"
	var stamina_text := "--"
	var potion_text := "--"
	if player.has_method("get_attack_power"):
		attack = player.get_attack_power()
	if player.has_method("get_inventory_count"):
		count = player.get_inventory_count()
	if player.has_method("get_hp_text"):
		hp_text = player.get_hp_text()
	if player.has_method("get_stamina_text"):
		stamina_text = player.get_stamina_text()
	if player.has_method("get_potion_text"):
		potion_text = player.get_potion_text()
	stats_label.text = "生命 %s  精力 %s  药剂 %s  攻击 %.0f  背包 %d" % [hp_text, stamina_text, potion_text, attack, count]
	if is_inventory_visible():
		render_inventory(player)

func set_inventory_visible(is_visible: bool) -> void:
	var panel = _inventory_panel()
	if panel != null:
		panel.visible = is_visible

func is_inventory_visible() -> bool:
	var panel = _inventory_panel()
	return panel != null and panel.visible

func render_inventory(player: Node) -> void:
	var item_list = _item_list()
	var detail_label = _detail_label()
	if item_list == null or detail_label == null:
		return

	if player == null:
		item_list.text = "背包为空"
		detail_label.text = "已装备：无"
		return

	var lines: Array[String] = []
	if player.has_method("get_inventory_items"):
		for item in player.get_inventory_items():
			if item == null or item.definition == null:
				continue
			var rarity := String(item.rarity)
			var weapon_attack := 0.0
			if item.definition.base_modifiers.has("weapon_attack"):
				weapon_attack = float(item.definition.base_modifiers["weapon_attack"])
			var affix_names: Array[String] = []
			for affix in item.affixes:
				if affix != null and String(affix.display_name) != "":
					affix_names.append(String(affix.display_name))
			var affix_text := ""
			if not affix_names.is_empty():
				affix_text = "  " + " / ".join(affix_names)
			lines.append("%s  [%s]  攻击 +%.0f%s" % [String(item.definition.display_name), rarity, weapon_attack, affix_text])

	if lines.is_empty():
		item_list.text = "背包为空"
	else:
		item_list.text = "\n".join(lines)

	var weapon_name := "无"
	if player.has_method("get_equipped_weapon_name"):
		weapon_name = player.get_equipped_weapon_name()
	detail_label.text = "已装备：%s\nI 关闭背包" % weapon_name

func _stats_label() -> Label:
	return get_node("Root/StatsLabel")

func _hint_label() -> Label:
	return get_node("Root/HintLabel")

func _inventory_panel() -> Control:
	return get_node_or_null("Root/InventoryPanel")

func _item_list() -> Label:
	return get_node_or_null("Root/InventoryPanel/ItemList")

func _detail_label() -> Label:
	return get_node_or_null("Root/InventoryPanel/DetailLabel")
