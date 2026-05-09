# Ashen Saint Godot Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first playable Godot vertical slice for 《灰圣徒》: first-chapter combat, equipment drops, inventory, one boss, and one repeatable 遗境 loop.

**Architecture:** Use Godot 4.x with focused GDScript modules. Core data, stat calculation, damage, item generation, combat actors, UI, chapter flow, and 遗境 flow stay separated so each system can be tested and tuned independently.

**Tech Stack:** Godot 4.x, GDScript, Godot Resource data files, lightweight in-project test runner, placeholder 2D art.

---

## 1. Source Documents

| Document | Purpose |
|---|---|
| `docs/ashen-saint-setting.md` | World, naming, characters, enemies, tone |
| `docs/chapter-01-rottenbone-village.md` | First chapter flow, boss, drops, dialogue |
| `docs/combat-equipment-system.md` | Combat, stats, equipment, affixes, drops |

All implementation MUST keep the current restrained naming style. Avoid adding new player-facing terms unless a document is updated first.

## 2. Project Layout

| Path | Responsibility |
|---|---|
| `project.godot` | Godot project config |
| `scenes/main/Main.tscn` | Root scene and global UI shell |
| `scenes/player/Player.tscn` | Player scene |
| `scenes/enemies/*.tscn` | Enemy scenes |
| `scenes/bosses/HermannBoss.tscn` | First boss scene |
| `scenes/levels/*.tscn` | Chapter, low-platform combat spaces, and 遗境 scenes |
| `scenes/ui/*.tscn` | HUD, inventory, tooltips, dialogue |
| `src/core/*.gd` | Event bus, game state, save service |
| `src/stats/*.gd` | Stat block and stat aggregation |
| `src/combat/*.gd` | Damage, health, hitbox, hurtbox |
| `src/items/*.gd` | Item definitions, item instances, affixes, drops |
| `src/player/*.gd` | Player controller and player actions |
| `src/enemies/*.gd` | Enemy base class and enemy AI |
| `src/bosses/*.gd` | Boss logic |
| `src/levels/*.gd` | Level flow, spawner, encounter director |
| `src/ui/*.gd` | HUD, inventory, tooltip, dialogue controllers |
| `data/items/*.tres` | Item templates |
| `data/affixes/*.tres` | Affix templates |
| `data/drop_tables/*.tres` | Drop tables |
| `tests/*.gd` | Lightweight test runner and unit tests |

## 3. Implementation Tasks

### Task 1: Project Scaffold and Test Harness

**Files:**
- Create: `project.godot`
- Create: `scenes/main/Main.tscn`
- Create: `src/core/EventBus.gd`
- Create: `tests/TestRunner.gd`
- Create: `tests/unit/TestSmoke.gd`

- [ ] **Step 1: Create Godot project skeleton**

Create `project.godot` with app name `Ashen Saint Prototype`, main scene `res://scenes/main/Main.tscn`, window size `1280x720`, and input actions for movement, jump, attacks, skills, potion, interact, inventory, and character panel.

- [ ] **Step 2: Add global event bus**

Create `src/core/EventBus.gd` with signals for `player_died`, `item_dropped`, `item_picked`, `equipment_changed`, `dialogue_started`, `dialogue_finished`, `area_completed`.

- [ ] **Step 3: Add lightweight test runner**

Create `tests/TestRunner.gd` that loads every `tests/unit/Test*.gd`, calls `run()`, counts failures, prints summary, and exits non-zero on failure.

- [ ] **Step 4: Add smoke test**

Create `tests/unit/TestSmoke.gd`:

```gdscript
extends RefCounted

func run() -> Array[String]:
	var failures: Array[String] = []
	if 1 + 1 != 2:
		failures.append("basic arithmetic failed")
	return failures
```

- [ ] **Step 5: Verify**

Run: `godot --headless --path . --script tests/TestRunner.gd`

Expected: `0 failures`.

### Task 2: Stats and Damage Core

**Files:**
- Create: `src/stats/StatBlock.gd`
- Create: `src/stats/StatAggregator.gd`
- Create: `src/combat/DamageCalculator.gd`
- Create: `tests/unit/TestDamageCalculator.gd`

- [ ] **Step 1: Write failing damage tests**

Cover base physical damage, critical damage, elite bonus, and armor reduction.

- [ ] **Step 2: Implement `StatBlock.gd`**

Store `max_hp`, `stamina_max`, `ash_max`, `base_attack`, `weapon_attack`, `armor`, `move_speed`, `jump_velocity`, `gravity`, `crit_chance`, `crit_damage`, `attack_bonus`, `greyflame_damage_bonus`, `elite_damage_bonus`, `kill_life_gain`.

- [ ] **Step 3: Implement `DamageCalculator.gd`**

Use formula from `docs/combat-equipment-system.md`:

```text
raw_damage = skill_power * (base_attack + weapon_attack) * (1 + attack_bonus)
typed_damage = raw_damage * (1 + damage_type_bonus)
crit_damage = typed_damage * crit_damage_multiplier if crit_roll succeeds
elite_damage = crit_damage * (1 + elite_damage_bonus) if target is elite_or_boss
final_damage = max(1, elite_damage - target_armor * 0.5)
```

- [ ] **Step 4: Verify**

Run: `godot --headless --path . --script tests/TestRunner.gd`

Expected: all damage tests pass.

### Task 3: Equipment, Affixes, and Item Generation

**Files:**
- Create: `src/items/ItemDefinition.gd`
- Create: `src/items/ItemInstance.gd`
- Create: `src/items/AffixDefinition.gd`
- Create: `src/items/ItemGenerator.gd`
- Create: `data/affixes/`
- Create: `data/items/`
- Create: `tests/unit/TestItemGenerator.gd`

- [ ] **Step 1: Write tests for affix generation**

Tests MUST verify rarity controls affix count: normal `0`, magic `1-2`, rare `3`, story legendary fixed effect plus `1-2`.

- [ ] **Step 2: Implement item definition resources**

Use `Resource` classes so items and affixes can later be tuned in the editor.

- [ ] **Step 3: Add first affix pool**

Create data entries for attack, crit chance, max life, armor, move speed, greyflame damage, kill life gain, elite damage.

- [ ] **Step 4: Add first item templates**

Create templates for `旧裁决剑：断刃`, `赦罪刃`, `灰骑盔`, `白焰残衣`, `旧誓戒`, `余民护符`.

- [ ] **Step 5: Verify**

Run: `godot --headless --path . --script tests/TestRunner.gd`

Expected: item generation tests pass and duplicate affixes do not appear on one item.

### Task 4: Inventory, Equipment Slots, and Stat Aggregation

**Files:**
- Create: `src/items/Inventory.gd`
- Create: `src/items/EquipmentSet.gd`
- Modify: `src/stats/StatAggregator.gd`
- Create: `tests/unit/TestEquipmentSet.gd`

- [ ] **Step 1: Write tests for equip rules**

Tests MUST cover correct slot equip, wrong slot rejection, two ring slots, stat recalculation, and full inventory rejection.

- [ ] **Step 2: Implement inventory**

Inventory MUST support at least `40` item slots and stackable currency/material entries.

- [ ] **Step 3: Implement equipment set**

Equipment slots MUST include weapon, head, chest, gloves, boots, amulet, ring_1, ring_2.

- [ ] **Step 4: Implement stat aggregation**

Base player stats plus equipment base stats plus affixes MUST produce final player stats.

- [ ] **Step 5: Verify**

Run: `godot --headless --path . --script tests/TestRunner.gd`

Expected: inventory and equipment tests pass.

### Task 5: Player Controller and Combat Actions

**Files:**
- Create: `scenes/player/Player.tscn`
- Create: `src/player/PlayerController.gd`
- Create: `src/player/PlayerCombat.gd`
- Create: `src/player/PlayerResources.gd`
- Create: `src/combat/Health.gd`
- Create: `src/combat/Hitbox.gd`
- Create: `src/combat/Hurtbox.gd`

- [ ] **Step 1: Create placeholder player scene**

Use simple 2D shapes first. The silhouette MUST reserve room for a large two-handed sword.

- [ ] **Step 2: Implement movement**

Support left/right movement, facing direction, gravity, ground detection, and single jump. Do not add complex platforming mechanics.

- [ ] **Step 3: Implement actions**

Implement jump, basic attack, heavy attack, dodge, potion, `横斩`, `突进`, and simplified `回击`.

- [ ] **Step 4: Wire resources**

Stamina MUST gate dodge/heavy attack. Ash meter MUST trigger the temporary strengthened state.

- [ ] **Step 5: Manual verify**

Run: `godot --path .`

Expected: player can move, jump, attack, dodge, use skills, spend stamina, and recover stamina.

### Task 6: Enemy Base and First Enemy Set

**Files:**
- Create: `src/enemies/EnemyBase.gd`
- Create: `src/enemies/EnemyMelee.gd`
- Create: `src/enemies/EnemyCaster.gd`
- Create: `src/enemies/EnemyHeavy.gd`
- Create: `src/enemies/EnemyPouncer.gd`
- Create: `src/enemies/EnemyEliteSoldier.gd`
- Create: `scenes/enemies/GreyVillager.tscn`
- Create: `scenes/enemies/FireBearer.tscn`
- Create: `scenes/enemies/WhiteAshSlave.tscn`
- Create: `scenes/enemies/StitchedDog.tscn`
- Create: `scenes/enemies/PenitentSoldier.tscn`

- [ ] **Step 1: Implement shared enemy base**

Enemy base MUST support health, armor, hit reaction, death, drop trigger, and target acquisition.

- [ ] **Step 2: Implement grey villager**

Basic melee walk and attack with visible windup.

- [ ] **Step 3: Implement fire bearer**

Maintains distance and throws greyflame projectile.

- [ ] **Step 4: Implement white ash slave**

Slow heavy unit with defense state that heavy attack can break.

- [ ] **Step 5: Implement stitched dog**

Fast pounce, then recovery delay.

- [ ] **Step 6: Implement penitent soldier**

Elite enemy with shield, charge, and better drop table.

- [ ] **Step 7: Manual verify**

Create a temporary test arena. Player MUST be able to kill every enemy type and receive drops.

### Task 7: Drop Tables and Pickup Flow

**Files:**
- Create: `src/items/DropTable.gd`
- Create: `src/items/DropService.gd`
- Create: `src/items/Pickup.gd`
- Create: `scenes/items/Pickup.tscn`
- Create: `data/drop_tables/chapter_01_common.tres`
- Create: `data/drop_tables/chapter_01_elite.tres`
- Create: `data/drop_tables/chapter_01_boss.tres`
- Create: `data/drop_tables/realm_01_reward.tres`

- [ ] **Step 1: Write drop table tests**

Tests MUST verify rarity probability ranges and fixed story legendary reward for boss table.

- [ ] **Step 2: Implement drop service**

Drop service MUST generate equipment, gold, materials, and裂片 from a table.

- [ ] **Step 3: Implement pickup scene**

Equipment requires manual pickup. Gold and materials SHOULD auto-pickup.

- [ ] **Step 4: Verify**

Run tests and a manual arena kill. Expected: drops appear with correct labels and can enter inventory.

### Task 8: UI Shell, HUD, Inventory, and Tooltip

**Files:**
- Create: `scenes/ui/Hud.tscn`
- Create: `scenes/ui/InventoryPanel.tscn`
- Create: `scenes/ui/ItemTooltip.tscn`
- Create: `src/ui/Hud.gd`
- Create: `src/ui/InventoryPanel.gd`
- Create: `src/ui/ItemTooltip.gd`

- [ ] **Step 1: Build HUD**

HUD MUST show health, stamina, ash meter, potion count, and skill cooldowns.

- [ ] **Step 2: Build inventory panel**

Inventory MUST show item list/grid, equipped slots, and selected item details.

- [ ] **Step 3: Build item tooltip**

Tooltip MUST show item name, rarity color, slot, base stats, affixes, and legendary effect if present.

- [ ] **Step 4: Manual verify**

Pick up and equip items. Expected: stats and tooltip update immediately.

### Task 9: Dialogue and Chapter Flow

**Files:**
- Create: `src/ui/DialogueBox.gd`
- Create: `scenes/ui/DialogueBox.tscn`
- Create: `src/levels/ChapterFlow.gd`
- Create: `src/levels/AreaTransition.gd`
- Create: `data/dialogue/chapter_01.json`

- [ ] **Step 1: Add dialogue data**

Use the restrained text from `docs/chapter-01-rottenbone-village.md`. Do not add florid dialogue.

- [ ] **Step 2: Implement dialogue box**

Dialogue box MUST support speaker name, line text, advance input, and lock player combat during dialogue.

- [ ] **Step 3: Implement chapter flags**

Track flags for weapon picked, 米拉 rescued, boss defeated, 遗境 unlocked.

- [ ] **Step 4: Manual verify**

Expected: first chapter scenes can trigger dialogue in order without breaking combat state.

### Task 10: First Chapter Levels

**Files:**
- Create: `scenes/levels/AshPit.tscn`
- Create: `scenes/levels/OldWheatRoad.tscn`
- Create: `scenes/levels/RottenboneVillage.tscn`
- Create: `scenes/levels/WhitewoodChapel.tscn`
- Create: `scenes/levels/VillageSquare.tscn`
- Create: `src/levels/EncounterSpawner.gd`

- [ ] **Step 1: Build placeholder level geometry**

Use simple 2D collision shapes, ground platforms, a few low ledges, and background blocks. No final art required.

- [ ] **Step 2: Add encounter spawns**

Each scene MUST follow the enemy pacing in the chapter design document.

- [ ] **Step 3: Add transitions**

Player MUST move and occasionally jump from 灰坑 to 旧麦路 to 烂骨村 to 白木礼拜堂 to 村心广场.

- [ ] **Step 4: Add checkpoints**

Boss failure MUST respawn at the safe point before 村心广场.

- [ ] **Step 5: Manual verify**

Expected: first chapter can be played from start to boss gate.

### Task 11: Hermann Boss

**Files:**
- Create: `scenes/bosses/HermannBoss.tscn`
- Create: `src/bosses/HermannBoss.gd`
- Create: `src/bosses/HermannBossPhase.gd`

- [ ] **Step 1: Implement phase one**

Add heavy sweep, ground grab, naming summon, defensive kneel.

- [ ] **Step 2: Implement phase transition**

At 50% health, switch to phase two and change visuals.

- [ ] **Step 3: Implement phase two**

Add greyflame cone, side hazard, fire bearer summon, continuous naming.

- [ ] **Step 4: Add defeat event**

Defeat MUST spawn `旧裁决剑：断刃`, unlock裂口, and trigger post-boss dialogue.

- [ ] **Step 5: Manual verify**

Expected: boss can kill player, can be killed, drops reward, unlocks 遗境.

### Task 12: Old Camp Hub and Realm Loop

**Files:**
- Create: `scenes/levels/OldCamp.tscn`
- Create: `scenes/levels/RottenboneRealm.tscn`
- Create: `src/levels/RealmDirector.gd`
- Create: `src/levels/RealmReward.gd`

- [ ] **Step 1: Build old camp**

Old camp MUST include 米拉, optional 奥德里克/瑟温 placeholders, inventory access, and裂口.

- [ ] **Step 2: Implement realm entry**

After boss defeat,裂口 enters 烂骨村遗境.

- [ ] **Step 3: Implement realm encounters**

Generate 3-5 waves plus 1 elite, using first chapter enemy pool.

- [ ] **Step 4: Implement realm reward**

Elite death MUST trigger extra reward drops.

- [ ] **Step 5: Manual verify**

Expected: player can enter遗境, clear, loot, return, equip upgrades, and repeat.

### Task 13: Save and Load

**Files:**
- Create: `src/core/SaveService.gd`
- Create: `src/core/GameState.gd`
- Create: `tests/unit/TestSaveService.gd`

- [ ] **Step 1: Write save tests**

Tests MUST cover inventory, equipment, gold,裂片, story flags, and unlocked systems.

- [ ] **Step 2: Implement game state**

Store player inventory, equipment, currencies, story flags, unlocked systems.

- [ ] **Step 3: Implement save service**

Use JSON save file in Godot user data path.

- [ ] **Step 4: Verify**

Run: `godot --headless --path . --script tests/TestRunner.gd`

Expected: save/load tests pass.

### Task 14: Full Demo Verification

**Files:**
- Modify only files needed for bug fixes from prior tasks.

- [ ] **Step 1: Run unit tests**

Run: `godot --headless --path . --script tests/TestRunner.gd`

Expected: `0 failures`.

- [ ] **Step 2: Run import check**

Run: `godot --headless --path . --quit`

Expected: no script parse errors and no missing resource errors.

- [ ] **Step 3: Manual playthrough**

Play from 灰坑 through 赫尔曼 defeat.

Expected:
- Player can complete chapter.
- Equipment drops and can be equipped.
- Boss unlocks裂口.
- Old camp opens.
- 遗境 can be repeated.

- [ ] **Step 4: Record known issues**

Create `docs/demo-known-issues.md` for tuning items, missing art, placeholder animations, and balance notes.

## 4. Commit Plan

If this becomes a Git repository, commit after each task:

| Task | Commit Message |
|---|---|
| 1 | `chore: scaffold godot project and tests` |
| 2 | `feat: add stats and damage core` |
| 3 | `feat: add item generation and affixes` |
| 4 | `feat: add inventory and equipment slots` |
| 5 | `feat: add player combat controller` |
| 6 | `feat: add first enemy set` |
| 7 | `feat: add drop tables and pickups` |
| 8 | `feat: add hud and inventory ui` |
| 9 | `feat: add dialogue and chapter flow` |
| 10 | `feat: add chapter one levels` |
| 11 | `feat: add hermann boss fight` |
| 12 | `feat: add old camp and realm loop` |
| 13 | `feat: add save and load` |
| 14 | `test: verify full demo loop` |

## 5. Acceptance Criteria

| Criterion | Required Result |
|---|---|
| First chapter playable | Player can start at 灰坑 and defeat 赫尔曼 |
| Combat functional | Movement, jump, attack, heavy attack, dodge, skills, potion, death, respawn work |
| Equipment functional | Items drop, can be picked up, inspected, equipped, and affect stats |
| Boss functional | 赫尔曼 has two phases, summons, hazards, defeat reward |
| Realm loop functional | Player can enter 遗境, clear waves, receive rewards, return, repeat |
| Save functional | Inventory, equipment, currencies, and unlocks persist |
| Tone preserved | Player-facing names remain restrained and consistent with docs |
