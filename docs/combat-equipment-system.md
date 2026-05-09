# 《灰圣徒》战斗与装备系统设计

状态：草案  
版本：0.2  
日期：2026-05-09  
依赖文档：`docs/ashen-saint-setting.md` v0.4、`docs/chapter-01-rottenbone-village.md` v0.2  
用途：定义第一版 Demo 的战斗、属性、技能、装备、词缀、掉落、背包和刷装循环。本文档用于后续 Godot 工程实现。

## 1. 范围

| 内容 | 第一版要求 |
|---|---|
| 玩家职业 | 洛温·阿什，双手剑近战职业 |
| 战斗视角 | 带跳跃的横版 2D，不做复杂跳台关卡 |
| 核心输入 | 左右移动、跳跃、普攻、重击、闪避、3 个主动技能、药剂、拾取、背包 |
| 资源 | 生命、精力、灰烬值 |
| 装备品质 | 普通、魔法、稀有、剧情传奇 |
| 装备部位 | 武器、头盔、胸甲、手套、靴子、项链、戒指 1、戒指 2 |
| 词缀 | 第一版 MUST 支持至少 8 个可生效词缀 |
| 掉落 | 第一章和遗境 MUST 掉落装备、金币、裂片、材料 |
| 终局原型 | 第一版 MUST 支持遗境刷装；深层挑战 MAY 只实现 5 层原型 |

## 2. 非目标

| 非目标 | 说明 |
|---|---|
| 多职业 | 第一版不做其他职业 |
| 武器切换 | 第一版只支持双手剑 |
| 套装系统 | 第一版预留数据字段，但不实现套装效果 |
| 联机同步 | 第一版只做本地单机 |
| 复杂交易 | 第一版不做交易、拍卖、共享市场 |
| 无限词缀池 | 第一版只实现小词缀池，保证可测和可调 |
| 完整技能树 | 第一版只实现技能槽和固定技能，技能树后续扩展 |

## 3. 设计原则

| 原则 | 要求 |
|---|---|
| 构筑优先 | 装备词缀 MUST 明显改变伤害、生存或刷图效率 |
| 前期克制 | 第一章剧情阶段 SHOULD 有压力，不能一开始割草 |
| 成型爽快 | 遗境阶段 SHOULD 允许玩家通过装备成长获得明显清怪速度提升 |
| 数值可读 | 所有核心属性 MUST 在角色面板或装备面板中可见 |
| 掉落可筛 | 魔法和稀有装备 MUST 有词缀差异，玩家需要做取舍 |
| 第一版可调 | 所有数值 SHOULD 通过数据表或 Godot Resource 调整，避免硬编码 |

## 4. 操作映射

| 输入 | 动作 | 第一版要求 |
|---|---|---|
| A / D | 左右移动 | MUST 支持 |
| W / Space | 跳跃 | MUST 支持，用于躲避和少量高低差 |
| Shift | 闪避 | MUST 支持，消耗精力 |
| 鼠标左键 / J | 普攻 | MUST 支持 |
| 鼠标右键 / K | 重击 | MUST 支持，消耗精力，可破防 |
| Q | 技能 1：横斩 | MUST 支持 |
| E | 技能 2：突进 | MUST 支持 |
| R | 技能 3：回击 | SHOULD 支持 |
| 1 | 药剂 | MUST 支持 |
| F | 拾取/交互 | MUST 支持 |
| I | 背包 | MUST 支持 |
| C | 角色面板 | SHOULD 支持 |
| Esc | 暂停菜单 | SHOULD 支持 |

第一版 SHOULD 同时支持键鼠和纯键盘操作。手柄映射 MAY 后续补充。

## 5. 玩家状态

| 状态 | 含义 | 允许转换 |
|---|---|---|
| Idle | 待机 | Move、Jump、Attack、Skill、Dodge、Interact |
| Move | 移动 | Idle、Jump、Attack、Skill、Dodge、Hit |
| Jump | 跳跃/下落 | Idle、Move、Attack、Skill、Dodge、Hit |
| Attack | 普攻中 | Idle、Move、Hit |
| HeavyAttack | 重击中 | Idle、Move、Hit |
| Skill | 技能释放中 | Idle、Move、Hit |
| Dodge | 闪避中 | Idle、Move |
| Hit | 受击硬直 | Idle、Dead |
| Dead | 死亡 | Respawn |
| Interact | 交互/对白 | Idle |

状态机 MUST 防止玩家在死亡、对白、背包锁定状态下继续攻击。闪避 SHOULD 允许打断移动，但不打断已释放的重击。

## 6. 属性模型

### 6.1 基础属性

| 属性 | 类型 | 说明 |
|---|---|---|
| level | int | 玩家等级 |
| max_hp | int | 最大生命 |
| hp | int | 当前生命 |
| stamina_max | int | 最大精力 |
| stamina | int | 当前精力 |
| ash_max | int | 最大灰烬值 |
| ash | int | 当前灰烬值 |
| base_attack | int | 基础攻击力 |
| armor | int | 护甲 |
| move_speed | float | 移动速度 |
| jump_velocity | float | 跳跃初速度 |
| gravity | float | 重力 |
| crit_chance | float | 暴击率 |
| crit_damage | float | 暴击伤害倍率 |
| cooldown_reduction | float | 冷却缩减 |
| elite_damage_bonus | float | 对精英伤害提高 |
| greyflame_damage_bonus | float | 灰焰伤害提高 |
| kill_life_gain | int | 击杀恢复生命 |

### 6.2 第一版初始值

| 属性 | 初始值 | 说明 |
|---|---|---|
| level | 1 | 第一章从 1 级开始 |
| max_hp | 120 | 允许 4-6 次普通受击 |
| stamina_max | 100 | 支持连续 2 次闪避或多次普攻 |
| ash_max | 100 | 满后触发短时强化 |
| base_attack | 12 | 普攻基础伤害 |
| armor | 5 | 初始减伤很低 |
| move_speed | 180 | Godot 像素单位可后续调 |
| jump_velocity | -360 | Godot 2D 向上为负值 |
| gravity | 980 | Godot 像素单位可后续调 |
| crit_chance | 0.05 | 5% |
| crit_damage | 1.5 | 暴击 150% 伤害 |
| cooldown_reduction | 0 | 初始无冷却缩减 |

## 7. 资源规则

| 资源 | 获得 | 消耗 | 第一版规则 |
|---|---|---|---|
| 生命 | 药剂、击杀回血、据点治疗 | 受击、回击技能 | 生命归零进入死亡 |
| 精力 | 自动恢复 | 闪避、重击 | 精力不足时不能释放对应动作 |
| 灰烬值 | 命中、击杀、受击少量获得 | 强化状态 | 满值后可进入短时强化 |

精力恢复：
- 每秒恢复 25 点。
- 受击后 0.5 s 内 SHOULD 暂停恢复。
- 闪避消耗 35 点，重击消耗 25 点。

强化状态：
- 第一版 MAY 自动触发，满值后持续 6 s。
- 强化期间攻击力提高 20%，灰焰伤害提高 20%。
- 后续版本 MAY 改为手动释放。

## 8. 伤害公式

### 8.1 基础伤害

第一版使用简单公式，便于调试。

```text
raw_damage = skill_power * (base_attack + weapon_attack) * (1 + attack_bonus)
typed_damage = raw_damage * (1 + damage_type_bonus)
crit_damage = typed_damage * crit_damage_multiplier if crit_roll succeeds
elite_damage = crit_damage * (1 + elite_damage_bonus) if target is elite_or_boss
final_damage = max(1, elite_damage - target_armor * armor_factor)
```

| 参数 | 第一版值 |
|---|---|
| armor_factor | 0.5 |
| 普攻 skill_power | 1.0 |
| 重击 skill_power | 1.8 |
| 横斩 skill_power | 1.3 |
| 回击 skill_power | 2.2 |

### 8.2 伤害类型

| 类型 | 用途 |
|---|---|
| physical | 普攻、重击、处决、普通敌人攻击 |
| greyflame | 横斩、捧火人、灰焰场地 |
| bleed | 后续流血构筑，第一版 MAY 不实现 |
| true | 少量剧情或场地伤害，第一版 SHOULD 少用 |

## 9. 玩家动作

| 动作 | 伤害/效果 | 消耗 | 冷却 | 备注 |
|---|---|---|---|---|
| 普攻 | 100% 物理伤害 | 无 | 无 | 三段循环，第三击轻微击退 |
| 重击 | 180% 物理伤害，破防 | 25 精力 | 无 | 有前摇，命中白灰奴和 Boss 防御时破防 |
| 跳跃 | 向上位移 | 无 | 落地后可再次跳 | 用于躲避地面攻击和通过低台阶 |
| 闪避 | 位移 + 短暂无敌 | 35 精力 | 0.4 s | 不造成伤害 |
| 药剂 | 恢复 45% 最大生命 | 药剂次数 | 8 s | 第一章初始 2 次 |
| 强化状态 | 攻击和灰焰伤害提高 | 100 灰烬值 | 无 | 持续 6 s |

普攻手感：
- 第一击 MUST 快，方便玩家起手。
- 第二击 SHOULD 稍慢但范围更宽。
- 第三击 SHOULD 有更强命中反馈和轻微击退。

跳跃手感：
- 第一版 MUST 支持单段跳。
- 空中 SHOULD 允许轻微左右修正。
- 空中 MAY 允许普攻和横斩，但重击 SHOULD 只在地面释放。
- 关卡 MUST 使用跳跃制造空间层次，但不能要求精密连跳。

重击手感：
- 必须有清晰前摇和挥动重量。
- 命中精英防御或 Boss 下跪状态时 MUST 产生破防反馈。

## 10. 主动技能

| 技能 | 键位 | 定位 | 第一版要求 |
|---|---|---|---|
| 横斩 | Q | 中距离范围清怪 | MUST 实现 |
| 突进 | E | 位移/保命 | MUST 实现 |
| 回击 | R | 高风险爆发 | SHOULD 实现 |

### 10.1 横斩

| 项目 | 规则 |
|---|---|
| 效果 | 向前斩出短距离灰焰 |
| 伤害 | 130% greyflame |
| 冷却 | 5 s |
| 消耗 | 15 精力 |
| 范围 | 前方中距离矩形或扇形 |
| 构筑价值 | 受灰焰伤害、冷却缩减、技能伤害影响 |

横斩 MUST 是第一版最主要的清怪技能。装备变强后，它 SHOULD 能从“补伤害技能”成长为“刷图核心技能”。

### 10.2 突进

| 项目 | 规则 |
|---|---|
| 效果 | 向当前方向快速突进 |
| 伤害 | 无或极低 |
| 冷却 | 6 s |
| 消耗 | 20 精力 |
| 防御 | 位移前半段短暂无敌 |
| 构筑价值 | 受移动速度、冷却缩减影响 |

突进 MUST 与普通闪避区分：闪避是短保命，突进是拉开距离或穿过危险区域。

### 10.3 回击

| 项目 | 规则 |
|---|---|
| 效果 | 消耗当前生命，释放一次近身重斩 |
| 伤害 | 220% physical |
| 冷却 | 10 s |
| 消耗 | 当前生命 8%，最低不会直接致死 |
| 额外效果 | 命中后恢复造成伤害的 5% 生命 |
| 构筑价值 | 受低生命伤害、击杀回血、暴击影响 |

回击 SHOULD 让玩家感受到苦修构筑雏形，但第一版不应把低生命玩法做得太复杂。

## 11. 敌人属性模板

| 敌人 | HP | 攻击 | 护甲 | 速度 | 特点 |
|---|---:|---:|---:|---:|---|
| 灰化村民 | 35 | 8 | 1 | 80 | 基础近战 |
| 捧火人 | 28 | 10 | 0 | 60 | 远程灰焰，死亡可爆燃 |
| 白灰奴 | 90 | 14 | 8 | 45 | 慢速重甲，可破防 |
| 缝犬 | 32 | 9 | 1 | 150 | 快速扑击 |
| 赦罪残兵 | 160 | 18 | 10 | 85 | 精英，带防御和冲锋 |
| 赫尔曼 | 1200 | 22 | 8 | 40 | Boss，两阶段 |

敌人生命和攻击 MAY 根据区域等级乘以缩放系数。

## 12. 敌人行为

| 敌人 | 行为要求 |
|---|---|
| 灰化村民 | MUST 靠近玩家并进行单次挥击；SHOULD 有短前摇 |
| 捧火人 | MUST 保持距离并投掷灰焰；死亡 MAY 留下短暂灰焰区域 |
| 白灰奴 | MUST 慢速推进；进入防御时需要重击破防 |
| 缝犬 | MUST 快速突进；突进后有短硬直 |
| 赦罪残兵 | MUST 有普通攻击、盾击、防御；SHOULD 掉落更高品质装备 |
| Boss | MUST 使用第一章文档定义的两阶段机制 |

所有敌人 MUST 有命中反馈、死亡反馈和掉落触发。普通敌人死亡动画 MAY 使用占位效果。

## 13. 装备数据模型

| 字段 | 类型 | 必填 | 规则 |
|---|---|---|---|
| id | string | 是 | 全局唯一，如 `weapon_ash_judgement_broken` |
| display_name | string | 是 | 玩家可见名称 |
| slot | enum | 是 | weapon/head/chest/gloves/boots/amulet/ring |
| rarity | enum | 是 | normal/magic/rare/legendary/story_legendary |
| item_level | int | 是 | 决定基础数值和词缀范围 |
| base_stats | map | 是 | 装备自带属性 |
| affixes | array | 否 | 随机词缀列表 |
| legendary_effect | string | 否 | 传奇效果 id |
| flavor_text | string | 否 | 文本描述 |
| stackable | bool | 是 | 装备为 false，材料为 true |
| icon | string | 否 | 图标资源路径 |

装备实例 MUST 保存实际词缀数值。装备模板 SHOULD 保存可生成范围。

## 14. 装备部位

| 部位 | 可提供基础属性 | 词缀倾向 |
|---|---|---|
| 武器 | weapon_attack | 攻击、暴击、灰焰伤害、对精英伤害 |
| 头盔 | armor、max_hp | 冷却缩减、暴击率、防御 |
| 胸甲 | armor、max_hp | 最大生命、护甲、减伤 |
| 手套 | armor | 攻击、暴击率、击杀回血 |
| 靴子 | armor、move_speed | 移动速度、闪避相关、生命 |
| 项链 | 无固定 | 技能伤害、灰焰伤害、冷却缩减 |
| 戒指 | 无固定 | 暴击、击杀回血、对精英伤害 |

第一版武器 MUST 对伤害有最大影响。饰品 SHOULD 对构筑方向有明显影响。

## 15. 品质规则

| 品质 | 颜色 | 词缀数量 | 第一版来源 |
|---|---|---:|---|
| 普通 | 白 | 0 | 灰坑、普通怪 |
| 魔法 | 蓝 | 1-2 | 旧麦路后掉落 |
| 稀有 | 黄 | 3 | 白木礼拜堂后掉落 |
| 剧情传奇 | 橙 | 固定效果 + 1-2 | Boss 或剧情奖励 |

第一版不实现随机传奇池，只实现剧情传奇或少量固定传奇效果。

## 16. 词缀数据模型

| 字段 | 类型 | 必填 | 规则 |
|---|---|---|---|
| id | string | 是 | 全局唯一 |
| display_name | string | 是 | 玩家可见名称 |
| stat | enum | 是 | 影响的属性 |
| value_type | enum | 是 | percent/flat |
| min_value | number | 是 | 最小值 |
| max_value | number | 是 | 最大值 |
| allowed_slots | array | 是 | 可出现部位 |
| min_item_level | int | 是 | 最低物品等级 |
| weight | int | 是 | 掉落权重 |

词缀生成 MUST 避免同一装备上出现重复 id。百分比词缀 MUST 在 UI 中显示为百分号。

## 17. 第一版词缀池

| id | 显示名 | 属性 | 类型 | 范围 | 部位 |
|---|---|---|---|---|---|
| atk_percent | 攻击力提高 | attack_bonus | percent | 3-10 | weapon/gloves/amulet/ring |
| crit_chance | 暴击率提高 | crit_chance | percent | 2-6 | weapon/head/gloves/ring |
| crit_damage | 暴击伤害提高 | crit_damage | percent | 8-20 | weapon/gloves/amulet/ring |
| max_hp_percent | 最大生命提高 | max_hp | percent | 4-12 | head/chest/boots/amulet |
| armor_percent | 护甲提高 | armor | percent | 4-12 | head/chest/gloves/boots |
| move_speed | 移动速度提高 | move_speed | percent | 2-6 | boots/amulet |
| greyflame_damage | 灰焰伤害提高 | greyflame_damage_bonus | percent | 4-10 | weapon/amulet/ring |
| kill_life_gain | 击杀恢复生命 | kill_life_gain | flat | 1-5 | gloves/ring/amulet |
| elite_damage | 对精英伤害提高 | elite_damage_bonus | percent | 5-12 | weapon/amulet/ring |
| cooldown_reduction | 冷却缩减 | cooldown_reduction | percent | 3-8 | head/amulet/ring |

第一版 MUST 至少实现前 8 个词缀。后 2 个 SHOULD 实现。

## 18. 传奇效果

| id | 名称 | 效果 | 第一版要求 |
|---|---|---|---|
| old_judgement_broken | 旧裁决剑：断刃 | 重击命中精英或 Boss 后，下一次横斩伤害提高 35% | MUST 实现 |
| grave_gate_edge | 墓门重剑 | 击杀敌人后，下一次普攻第三击范围提高 30% | MAY 实现 |
| penitent_ring | 亡者戒 | 生命低于 35% 时，击杀恢复生命翻倍 | MAY 实现 |

剧情传奇效果 MUST 明显改变打法，但不能在第一章直接破坏难度。传奇效果 SHOULD 作为后续 build 的第一颗种子。

## 19. 掉落规则

### 19.1 掉落流程

```text
enemy_dead
  -> roll_drop_table(enemy_type, area_level)
  -> choose_item_type_or_currency
  -> if equipment: choose_slot
  -> choose_rarity
  -> create_item_instance
  -> roll_affixes
  -> spawn_pickup
```

### 19.2 品质概率

| 来源 | 普通 | 魔法 | 稀有 | 剧情传奇 |
|---|---:|---:|---:|---:|
| 灰坑普通怪 | 80% | 20% | 0% | 0% |
| 旧麦路普通怪 | 55% | 43% | 2% | 0% |
| 烂骨村普通怪 | 45% | 50% | 5% | 0% |
| 精英怪 | 10% | 65% | 25% | 0% |
| Boss | 0% | 30% | 69% | 固定 1 件剧情奖励 |
| 遗境结算 | 10% | 65% | 25% | 0% |

第一版 SHOULD 偏慷慨，让玩家在 15 min 遗境刷装里能明显换装。

### 19.3 掉落表现

| 要素 | 要求 |
|---|---|
| 掉落光柱 | SHOULD 按品质显示颜色 |
| 掉落文本 | MUST 显示装备名和品质颜色 |
| 自动拾取 | 金币和材料 SHOULD 自动拾取 |
| 手动拾取 | 装备 MUST 手动拾取 |
| 地面上限 | SHOULD 限制同屏掉落数量，避免 UI 混乱 |

## 20. 背包与穿戴

| 功能 | 第一版要求 |
|---|---|
| 背包容量 | MUST 支持至少 40 格 |
| 装备查看 | MUST 显示名称、品质、部位、基础属性、词缀 |
| 穿戴装备 | MUST 支持替换对应部位 |
| 双戒指 | MUST 支持两个戒指槽 |
| 属性重算 | 装备变化后 MUST 立即重算角色属性 |
| 丢弃装备 | SHOULD 支持 |
| 出售装备 | MAY 延后 |
| 分解装备 | MAY 延后 |

装备穿戴 MUST 不允许部位错误。戒指装备 SHOULD 默认填入空槽；两个槽都满时让玩家选择替换。

## 21. 角色面板

| 显示项 | 第一版要求 |
|---|---|
| 生命 | MUST 显示当前/最大 |
| 攻击力 | MUST 显示 |
| 护甲 | MUST 显示 |
| 暴击率 | SHOULD 显示 |
| 暴击伤害 | SHOULD 显示 |
| 移动速度 | SHOULD 显示 |
| 灰焰伤害 | SHOULD 显示 |
| 对精英伤害 | SHOULD 显示 |

角色面板不需要复杂，但必须让玩家理解装备是否变强。

## 22. 遗境刷装循环

| 阶段 | 行为 |
|---|---|
| 进入 | 玩家从旧营火裂口进入遗境 |
| 清怪 | 随机生成 3-5 波普通怪和 1 个精英 |
| 掉落 | 怪物直接掉落装备、材料和金币 |
| 结算 | 精英死亡后额外生成结算掉落 |
| 返回 | 玩家返回旧营火整理装备 |

遗境单次时长 SHOULD 控制在 3-6 min。遗境必须比剧情关更密集，强调刷装效率和成型后的清怪爽感。

## 23. 深层挑战原型

深层挑战是爬层玩法，不是第一章通关后立即完整开放的系统。第一版 MAY 做 5 层原型，用于验证构筑强度。

| 层数 | 怪物强度 | 目标 |
|---|---:|---|
| 1 | 100% | 熟悉规则 |
| 2 | 115% | 装备初筛 |
| 3 | 130% | 需要较好伤害 |
| 4 | 150% | 需要生存和伤害兼顾 |
| 5 | 175% | 小 Boss 或精英组 |

深层挑战 SHOULD 有计时，但第一版 MAY 不做排行榜。

## 24. 存档数据

| 字段 | 类型 | 规则 |
|---|---|---|
| player_level | int | 玩家等级 |
| current_hp | int | 当前生命 |
| inventory | array | 装备和材料实例 |
| equipped_items | map | 当前穿戴装备 |
| unlocked_systems | map | 是否解锁遗境、深层挑战、据点 |
| story_flags | map | 第一章剧情节点 |
| currency_gold | int | 金币 |
| material_shards | int | 裂片数量 |

第一版 MUST 支持本地保存和读取。存档格式 SHOULD 使用 JSON 或 Godot Resource，具体由工程实现文档决定。

## 25. 错误处理

| 情况 | 必须处理 |
|---|---|
| 词缀生成失败 | 回退为无词缀普通装备，并记录日志 |
| 装备模板缺失 | 不生成该装备，并记录模板 id |
| 背包满 | 阻止拾取装备，显示提示 |
| 属性低于 0 | 属性重算时 clamp 到合法范围 |
| 存档读取失败 | 回退新档或提示玩家重新开始 |
| 掉落表为空 | 不生成掉落，但不能崩溃 |

## 26. 实现验收

| 验收项 | 标准 |
|---|---|
| 战斗可玩 | 玩家能移动、跳跃、普攻、重击、闪避、释放技能、喝药 |
| 属性生效 | 装备变化后生命、攻击、护甲、暴击、灰焰伤害等属性能变化 |
| 伤害可测 | 同一技能在不同装备下伤害变化符合公式 |
| 掉落可用 | 怪物和 Boss 能按掉落表生成装备 |
| 装备可筛 | 至少普通、魔法、稀有三类装备有明显差异 |
| 背包可用 | 玩家能拾取、查看、穿戴、替换装备 |
| 遗境可刷 | 玩家能进入遗境，清怪，拿掉落，返回据点 |
| 存档可恢复 | 重启后保留装备、金币、裂片和系统解锁 |

## 27. 待确认问题

| 问题 | 当前建议 |
|---|---|
| 强化状态是否手动释放 | 第一版自动触发，后续再改手动 |
| 回击是否第一版实现 | 建议实现一个简化版，突出苦修构筑雏形 |
| 深层挑战是否第一版同步做 | 建议先做遗境，深层挑战作为后续 5 层原型 |
| 装备是否需要耐久 | 不建议第一版实现 |
| 是否做装备鉴定 | 第一版可由奥德里克做 UI 入口，但装备拾取后直接可见词缀 |
