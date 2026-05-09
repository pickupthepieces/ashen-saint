# 《灰圣徒》第一章 Demo 状态

状态：可玩纵切  
日期：2026-05-09  
入口：`scenes/main/Main.tscn`

## 已实现范围

| 模块 | 当前状态 |
|---|---|
| 主线章节 | 灰坑、旧麦路、烂骨村、白木礼拜堂、村心广场、旧营火、烂骨村遗境 |
| 剧情 | 开场、米拉登场、Boss 前、Boss 后、旧营火、遗境入口对白 |
| 玩家 | 横版移动、跳跃、普攻、重击、闪避、横斩、突进、回击、药剂、死亡回检查点 |
| 敌人 | 灰化村民、捧火人、白灰奴、缝犬、赦罪残兵、赫尔曼 |
| Boss | 赫尔曼两阶段、半血变相、接触伤害、击败后解锁遗境 |
| 掉落 | 怪物掉落装备，稀有装备会滚词缀 |
| 背包 | F 拾取、I 打开背包、装备双手剑自动提升攻击 |
| 刷装循环 | 第一章通关后进入烂骨村遗境，清理后返回旧营火，可重复进入 |
| 美术 | 已接入主角、敌人、Boss、米拉、道具、章节背景资产 |

## 操作

| 输入 | 功能 |
|---|---|
| A / D | 左右移动 |
| W / Space | 跳跃 |
| 鼠标左键 | 普攻 |
| 鼠标右键 | 重击 |
| Shift | 闪避 |
| Q | 横斩 |
| E | 突进 |
| R | 回击 |
| 1 | 药剂 |
| F | 拾取、对白推进、区域出口 |
| I | 背包 |

## 当前限制

| 项目 | 说明 |
|---|---|
| 动画 | 当前以稳定单帧 sprite 和战斗闪烁反馈为主，后续需要完整 idle/run/attack/hit/death 动画条并做逐帧校验 |
| Boss 技能 | 已有两阶段和压迫感，但地面预警、召唤、横扫硬直窗口还需要做成完整技能时间轴 |
| 掉落筛选 | 已有品质与词缀，尚未做装备对比、丢弃、锁定、过滤和角色面板 |
| 遗境 | 已能重复刷，暂未做随机词条、计时、层数奖励和深层爬塔 |
| 存档 | Demo 暂不保存进度和装备 |

## 验收命令

```powershell
& 'D:\CodexProject\game\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe' --headless --path 'D:\CodexProject\game' --script 'res://tests/TestRunner.gd'
```

```powershell
& 'D:\CodexProject\game\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe' --headless --path 'D:\CodexProject\game' --quit-after 1
```
