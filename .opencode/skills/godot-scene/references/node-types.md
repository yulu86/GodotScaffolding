# 节点类型选择指南

## 2D 节点

| 用途 | Node Type | 备注 |
|------|-----------|------|
| 玩家、敌人、NPC | `CharacterBody2D` | 平台游戏、俯视角移动 |
| 区域触发器、传感器 | `Area2D` | 攻击判定框、受击框、检测区域 |
| 静态环境 | `StaticBody2D` | 墙壁、地板 |
| 刚体物理对象 | `RigidBody2D` | 抛射物、物理谜题 |
| 瓦片地图 | `TileMapLayer` (4.4+) | Godot 4.4+ 替代 TileMap |
| 精灵动画 | `AnimatedSprite2D` | 帧动画 |
| 单张图片 | `Sprite2D` | 静态图片 |
| 摄像机 | `Camera2D` | 跟随玩家、屏幕震动 |
| 路径跟随 | `PathFollow2D` | 巡逻路线 |

## 3D 节点

| 用途 | Node Type | 备注 |
|------|-----------|------|
| 玩家、敌人 | `CharacterBody3D` | 第一/第三人称控制器 |
| 区域触发器 | `Area3D` | 检测、交互区域 |
| 静态环境 | `StaticBody3D` | 地形、墙壁 |
| 刚体物理 | `RigidBody3D` | 物理对象 |
| 导航 | `NavigationRegion3D` | AI 寻路 |
| 3D 模型 | `Node3D` + MeshInstance3D | 静态网格 |

## UI 节点

| 用途 | Node Type | 备注 |
|------|-----------|------|
| UI 根元素 | `Control` | 所有 UI 的基类 |
| 按钮 | `Button` | 点击交互 |
| 文本标签 | `Label` | 显示文本 |
| 文本输入 | `LineEdit` | 单行输入 |
| 文本区域 | `TextEdit` | 多行输入 |
| 进度条 | `ProgressBar` | 生命值、加载进度 |
| 滑块 | `HSlider` / `VSlider` | 连续值调节 |
| 容器 | `VBoxContainer` / `HBoxContainer` | 子节点布局 |
| 边距 | `MarginContainer` | 添加内边距 |
| 滚动 | `ScrollContainer` | 可滚动内容 |
| 面板 | `PanelContainer` | 背景面板 |
| 标签页 | `TabContainer` | 标签式界面 |
| 树形视图 | `Tree` | 层级数据 |
| 项目列表 | `ItemList` | 可选择列表 |

## 工具节点

| 用途 | Node Type | 备注 |
|------|-----------|------|
| 计时器 | `Timer` | 冷却、间隔 |
| 补间动画 | `Tween` (通过代码) | 编程式动画 |
| 音频播放 | `AudioStreamPlayer` | 音效、音乐 |
| 2D 音频 | `AudioStreamPlayer2D` | 2D 位置音效 |
| 粒子 | `GPUParticles2D` / `GPUParticles3D` | 视觉特效 |
| 状态机根节点 | `Node` | State 子节点的容器 |

## 根节点选择决策树

```
是否需要物理移动？
├── 是 → CharacterBody2D/3D（受控）或 RigidBody2D/3D（物理驱动）
└── 否
    ├── 是触发区域吗？→ Area2D/3D
    ├── 是静态障碍物吗？→ StaticBody2D/3D
    ├── 是 UI 吗？→ Control 派生类
    ├── 需要位置吗？→ Node2D/3D
    └── 以上都不是？→ Node（普通节点）
```
