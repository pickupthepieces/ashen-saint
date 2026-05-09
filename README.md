# Ashen Saint / 灰圣徒

《灰圣徒》是一个使用 Godot 4 制作的横版 2D 暗黑风刷装 ARPG 原型。项目当前目标是做出第一章剧情 Demo、基础战斗手感、装备词缀掉落，以及通关后的遗境刷装循环。

玩家扮演洛温·阿什，一名从灰坑复活的前赦罪庭骑士。他背负未愈之伤与旧罪，在被灰疫吞噬的维尔霍恩中寻找复活真相，并阻止“王国之伤”继续吞噬活人。

## 当前状态

当前版本是可玩的第一章纵切 Demo。

已实现内容：

| 模块 | 内容 |
|---|---|
| 主线场景 | 灰坑、旧麦路、烂骨村、白木礼拜堂、村心广场、旧营火、烂骨村遗境 |
| 玩家动作 | 横版移动、跳跃、普攻、重击、闪避、横斩、突进、回击、药剂、死亡回检查点 |
| 敌人与 Boss | 灰化村民、捧火人、白灰奴、缝犬、赦罪残兵、赫尔曼 |
| 剧情 | 开场、米拉登场、Boss 前后对白、旧营火与遗境入口对白 |
| 装备 | 怪物掉落装备，魔法/稀有装备会生成词缀 |
| 背包 | 拾取、打开背包、装备双手剑并提升攻击力 |
| 刷装循环 | 第一章通关后进入烂骨村遗境，清理后返回旧营火，可重复刷装 |
| 美术 | 已接入主角、敌人、Boss、米拉、道具与章节背景资源 |

## 运行方式

### 需求

- Godot 4.6.x
- Windows、Linux 或 macOS 均可，当前开发环境主要在 Windows 上验证

本仓库不提交本地 Godot 编辑器目录。请自行安装 Godot，然后用 Godot 打开仓库根目录下的 `project.godot`。

### 从 Godot 编辑器运行

1. 打开 Godot。
2. Import/Open 项目根目录。
3. 选择 `project.godot`。
4. 运行主场景 `scenes/main/Main.tscn`。

### Windows 命令行运行

如果你本地有 Godot 控制台版本，可以类似这样运行：

```powershell
& 'D:\Path\To\Godot_v4.6.2-stable_win64_console.exe' --path 'D:\CodexProject\game'
```

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
| 1 | 使用药剂 |
| F | 拾取、交互、推进对白、区域出口 |
| I | 背包 |

## 项目结构

```text
assets/   美术资源、角色、敌人、Boss、道具和场景背景
data/     剧情对白等数据
docs/     世界观、章节、战斗装备系统和 Demo 状态文档
scenes/   Godot 场景文件
src/      GDScript 源码
tests/    Godot 内的测试脚本
scripts/  本地开发辅助脚本
```

关键文档：

- `docs/ashen-saint-setting.md`：世界观、角色、阵营、敌人、装备命名基准
- `docs/chapter-01-rottenbone-village.md`：第一章“烂骨村”剧情与关卡设计
- `docs/combat-equipment-system.md`：战斗、属性、装备、词缀和掉落设计
- `docs/first-chapter-demo-status.md`：当前 Demo 实现状态

## 测试

项目包含一个 Godot 测试入口：

```powershell
& 'D:\Path\To\Godot_v4.6.2-stable_win64_console.exe' --headless --path 'D:\CodexProject\game' --script 'res://tests/TestRunner.gd'
```

也可以做一次无界面加载检查：

```powershell
& 'D:\Path\To\Godot_v4.6.2-stable_win64_console.exe' --headless --path 'D:\CodexProject\game' --quit-after 1
```

## 当前限制

- 动画仍以稳定单帧 sprite 和战斗闪烁反馈为主，完整逐帧动作还在补充中。
- Boss 已有两阶段压力，但地面预警、召唤和硬直窗口还需要继续打磨。
- 掉落已有品质和词缀，尚未实现装备对比、丢弃、锁定、过滤和完整角色面板。
- 遗境可以重复刷，但暂未实现随机词条、计时、层数奖励和深层爬塔。
- Demo 暂不保存进度和装备。

## 开发与同步

普通 Git 工作流：

```powershell
git status
git add README.md
git commit -m "Update README"
git push
```

仓库内也提供了一个半自动同步脚本，会先列出准备提交的文件并询问确认：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\git-sync.ps1 -Message "Update project"
```

如需跳过确认：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\git-sync.ps1 -Message "Update project" -Yes
```

注意：`git-sync.ps1` 会执行 `git add -A`，会提交所有未忽略的改动。运行前请确认 `git status` 里没有临时文件或半成品内容。

## 许可证

暂未指定许可证。公开使用、二次分发或商用前，请先补充明确的 LICENSE 文件。
