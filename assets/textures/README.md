# 纹理资源目录

本目录存放游戏所有纹理贴图资源。

## 当前状态

**占位阶段** — 所有模型均使用 Godot 内置 SpatialMaterial 默认颜色，暂无自定义纹理。

## 目录规划

```
textures/
├── heroes/        # 英雄角色贴图（漫反射、法线、粗糙度等）
├── structures/    # 防御塔等建筑贴图
├── minions/       # 小兵单位贴图
├── environment/   # 场景环境贴图（地面、天空等）
└── ui/            # UI 元素贴图
```

## 后续计划

- [ ] 使用 ComfyUI 生成纹理贴图（漫反射/Albedo）
- [ ] 使用 ComfyUI 或外部工具生成法线贴图（Normal Map）
- [ ] 调整粗糙度（Roughness）/金属度（Metallic）贴图
- [ ] 优化纹理尺寸以适应移动端/低端设备
