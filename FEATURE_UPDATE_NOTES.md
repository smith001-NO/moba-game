# Gameplay Economy / Shop / Audio / Skills Update

This package fixes mouse attack targeting and expands the prototype into a more MOBA-like playable loop.

## Controls
- WASD: move hero
- Left/right click ground: move hero
- Left/right click enemy: target and basic attack / chase
- Q: Arc Volley, multi-projectile ranged attack
- W: Crescent Slash, close-range cone slash
- E: Phantom Steps, two-stage dash with landing damage
- R: Renewal Field, heal + close-range pulse
- T: Thunder Field, ranged multi-pulse area spell
- B: open / close equipment shop
- Arrow keys: pan camera
- Mouse wheel: zoom
- Space: center camera on hero
- Y: lock/unlock camera follow
- F: target nearest enemy
- P: pause

## Changes
- Mouse attack now has fallback target picking around the click location, so clicking near enemies, towers, or the base is much more reliable.
- Camera is detached from the hero and uses a fixed PC MOBA view with no mouse-orbit capture. Edge pan stays disabled by default to avoid flicker.
- Heroes gain passive XP/gold over time. Kills grant additional XP and gold.
- Both player and AI heroes level up and gain attributes over time.
- Minion kills, hero kills, towers, and nexus destruction grant rewards.
- Minion waves scale every 5 waves.
- AI heroes periodically buy equipment.
- Unified HUD only uses `game_hud.gd` and `minimap_view.gd`; old HUD/minimap scripts were removed.
- Shop is integrated into `game_hud.gd`; purchases directly modify HeroBase stats.
- AudioManager now plays a looping xuanhuan-style battle theme and louder SFX for hits, skills, kills, purchases, levels, death, and objectives.
