# MOBA Prototype (Godot)

*[中文版本请向下滚动 | Scroll down for Chinese version](#中文版)*

A fully functional, single-player MOBA game prototype built with Godot 4. This repository contains the core gameplay loop, including hero combat, minion waves, a functional economy, an item shop, and AI opponents.

## 🌟 Core Features

- **Classic MOBA Camera & Movement:** Fixed top-down isometric view with point-and-click or WASD movement. Edge-panning is disabled by default for a smoother camera experience.
- **Ranged Lock-On Combat:** Robust combat system with auto-attacking, projectile tracking, and melee slashing.
- **Dynamic Economy & Progression:** 
  - Passive XP/Gold generation.
  - Earn rewards from last-hitting minions, hero kills, destroying towers, and the enemy nexus.
  - Heroes dynamically level up, gaining stats (HP, Mana, AD, Def, Attack Speed).
- **Equipment Shop (Press `B`):** Spend gold on a variety of items to boost your stats (e.g., Attack Damage, Attack Speed, Max HP, Mana Regen). AI heroes also automatically purchase items.
- **Diverse Skill Set:**
  - **Q:** Arc Volley (Multi-projectile ranged attack)
  - **E:** Phantom Steps (Two-stage dash with landing damage)
  - **R:** Renewal Field (AoE Healing + damage pulse)
  - **1:** Crescent Slash (Close-range cone slash)
  - **2:** Thunder Field (Ranged multi-pulse AoE spell)
- **Minion & Structure Logic:** Minion waves scale up every 5 waves. Towers prioritize aggressive enemy heroes before targeting minions.
- **Rich Audio & Visuals:** Built-in VFX for hits and abilities. AudioManager handles background battle themes, kill banners, UI sounds, and combat SFX.
- **Unified UI/HUD:** Clean game HUD and a functional minimap with player ping highlights.

## 🎮 Controls

### Movement & Combat
- **WASD:** Move Hero (Alternative to mouse)
- **Left/Right Click Ground:** Move Hero
- **Left/Right Click Enemy:** Target, Chase, and Auto-Attack
- **F:** Target Nearest Enemy

### Skills
- **Q / E / R / 1 / 2:** Cast Abilities (See Skill Set above)

### UI & Camera
- **B:** Open / Close Equipment Shop
- **P:** Pause Game
- **Arrow Keys:** Pan Camera manually
- **Mouse Wheel:** Zoom In / Out
- **Space:** Center Camera on Hero
- **Y:** Toggle Camera Follow Lock

## 🛠️ Getting Started

### Prerequisites
- **Godot Engine 4.x** (Tested on recent 4.x versions)

### Running the Game
1. Clone the repository to your local machine.
2. Open Godot Engine and import the project by selecting the `project.godot` file.
3. Open `scenes/main.tscn` or `scenes/game_map.tscn`.
4. Press **F5** (or the Play button) to run the project.

## 🛡️ GitHub Safe Version
This repository is the **GitHub-safe package** of the game. It has been stripped of local-only LLM helper integrations (like `llama.cpp` hardcoded paths), generated cache files, and machine-specific launch scripts to ensure a clean open-source presence while fully retaining the gameplay logic.

## 📜 License
*Specify your license here (e.g., MIT, GPL-3.0).*

---

<h1 id="中文版">MOBA 原型 (Godot)</h1>

这是一个基于 Godot 4 开发的、功能完整的单机 MOBA 游戏原型。本仓库包含了游戏的核心循环，包括英雄战斗、兵线、经济系统、装备商店以及 AI 对手。

## 🌟 核心特性

- **经典的 MOBA 视角与移动：** 固定的等距俯视角，支持鼠标点击移动或 WASD 移动。默认关闭了边缘镜头移动，以提供更平滑的视觉体验。
- **远程锁定战斗：** 稳健的战斗系统，包含自动攻击、弹道追踪和近战斩击。
- **动态经济与成长：** 
  - 被动的经验/金币自然增长。
  - 通过补刀小兵、击杀英雄、推毁防御塔和基地来获取奖励。
  - 英雄会动态升级并获得属性成长（生命值、法力值、攻击力、防御力、攻击速度）。
- **装备商店（按 `B` 键）：** 使用金币购买各类装备来提升属性（例如：攻击力、攻击速度、最大生命值、法力回复）。AI 英雄也会自动购买装备。
- **多样的技能组合：**
  - **Q：** Arc Volley（多发远程晶弹）
  - **E：** Phantom Steps（两段位移突进，落点造成伤害）
  - **R：** Renewal Field（范围治疗自身 + 周围脉冲伤害）
  - **1：** Crescent Slash（近战扇形斩击）
  - **2：** Thunder Field（远程多段雷场范围伤害）
- **兵线与建筑逻辑：** 小兵波次每 5 波获得一次强化。防御塔在受到敌方英雄攻击时，或当敌方英雄在塔下攻击己方英雄时，会优先锁定敌方英雄。
- **丰富的音效与视觉表现：** 内置攻击与技能特效。AudioManager 统一管理背景战斗音乐、击杀播报、UI 音效和战斗音效。
- **统一的 UI/HUD：** 简洁的游戏主界面，以及带高亮提示的实用小地图。

## 🎮 操作指南

### 移动与战斗
- **WASD：** 移动英雄（鼠标点击的替代方案）
- **左键/右键 点击地面：** 移动英雄
- **左键/右键 点击敌人：** 锁定目标、追击并自动攻击
- **F：** 锁定最近的敌人

### 技能
- **Q / E / R / 1 / 2：** 施放技能（详情见上文技能组合）

### UI 与镜头
- **B：** 打开 / 关闭装备商店
- **P：** 暂停游戏
- **方向键：** 手动平移镜头
- **鼠标滚轮：** 缩放镜头
- **空格键 (Space)：** 镜头回到英雄身上
- **Y：** 锁定 / 解锁镜头跟随

## 🛠️ 如何运行

### 环境要求
- **Godot Engine 4.x** (已在最新的 4.x 版本上测试)

### 启动游戏
1. 将此仓库克隆到您的本地电脑。
2. 打开 Godot 引擎，选择 `project.godot` 文件导入项目。
3. 打开 `scenes/main.tscn` 或 `scenes/game_map.tscn` 场景。
4. 按下 **F5**（或点击运行按钮）启动项目。

## 🛡️ GitHub 开源安全版
本仓库是该游戏的 **GitHub 安全版本**。为了保证开源环境下的纯净并保留完整的核心玩法，我们移除了本地专用的 LLM 助手集成（如 `llama.cpp` 硬编码路径）、生成的缓存文件以及特定机器的启动脚本。

## 📜 许可证
*请在此处指定您的许可证（例如：MIT, GPL-3.0）。*