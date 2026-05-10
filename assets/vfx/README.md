# 特效资源目录

本目录存放游戏粒子特效、着色器特效等视觉资源。

## 当前状态

**占位阶段** — 暂无自定义特效资源。

## 目录规划

```
vfx/
├── particles/     # 粒子系统资源（GPUParticles2D/3D）
│   ├── attack/    # 攻击特效
│   ├── skill/     # 技能特效
│   └── damage/    # 受击特效
├── shaders/       # 自定义着色器（.gdshader / .gdshaderinc）
└── sprites/       # 特效序列帧精灵图
```

## 后续计划

- [ ] 使用 ComfyUI 生成特效序列帧（爆炸、魔法、攻击等）
- [ ] 编写 Godot 着色器实现特殊效果（护盾光环、火焰等）
- [ ] 使用 GPUParticles3D 实现连续粒子特效
- [ ] 优化特效性能（LOD、粒子数量控制）
