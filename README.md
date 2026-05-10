# MOBA Prototype (Godot)

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