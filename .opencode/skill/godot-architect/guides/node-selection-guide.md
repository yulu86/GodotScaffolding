# Godot节点选择指导

## 🎮 2D游戏节点选择

### 角色控制器
- **CharacterBody2D**: 玩家角色、需要精确控制的角色
- **RigidBody2D**: 需要物理模拟的物体（如石头、箱子）
- **Area2D**: 触发区域、伤害区域、收集物

### 视觉效果
- **Sprite2D**: 静态或简单动画的精灵
- **AnimationPlayer + Sprite2D**: 复杂动画（推荐）
- **AnimatedSprite2D**: 简单的序列帧动画（不推荐，灵活性差）

### UI元素
- **Control**: UI根节点
- **CanvasLayer**: UI层级管理
- **Label**: 文本显示
- **Button**: 可点击按钮
- **TextureRect**: 图片显示

## 🏗️ 3D游戏节点选择

### 角色控制器
- **CharacterBody3D**: 3D角色控制器
- **RigidBody3D**: 3D物理物体
- **Area3D**: 3D触发区域

### 视觉效果
- **MeshInstance3D**: 3D模型显示
- **AnimationPlayer**: 3D动画播放（推荐）
- **Sprite3D**: 3D中的2D精灵

### 相机和光照
- **Camera3D**: 3D视角
- **DirectionalLight3D**: 平行光（太阳光）
- **OmniLight3D**: 点光源
- **SpotLight3D**: 聚光灯

## 📋 选择决策树

### 角色节点选择
```
需要玩家控制？
├─ 是 → CharacterBody2D/3D
└─ 否
   ├─ 需要物理碰撞？ → RigidBody2D/3D
   └─ 只需要检测接触？ → Area2D/3D
```

### 动画节点选择
```
需要复杂动画？
├─ 是 → AnimationPlayer + Sprite2D/AnimationPlayer + MeshInstance3D
└─ 否
   ├─ 简单帧动画？ → AnimatedSprite2D（不推荐）
   └─ 静态图片？ → Sprite2D
```

### UI节点选择
```
显示内容类型？
├─ 文本 → Label/RichTextLabel
├─ 图片 → TextureRect
├─ 可交互 → Button/Container子类
└─ 容器 → HBoxContainer/VBoxContainer/GridContainer
```