---
name: godot-scene
description: Godot 4.x 场景创建和修改的标准化流程 Skill。指导场景树设计、节点选择、场景组织、组件化拆分和信号连接。当需要创建新场景、修改场景结构、添加节点、组织场景层级、创建可复用组件场景、设计场景间交互、选择节点类型或连接信号时触发此技能。
---

# Godot 场景构建器

创建和修改 Godot 4.x 场景的标准化工作流。

## 适用场景

- 创建新场景（Actor、UI、关卡、组件）
- 修改现有场景树结构
- 通过 MCP 工具添加/移除节点
- 设计可复用的组件场景
- 设置节点间的信号连接
- 选择合适的节点类型

## 场景创建工作流

### 第 1 步：设计场景架构

在操作任何文件之前：

1. **确定场景类型**：Actor / Component / UI / Level
2. **选择根节点类型**：参见 [references/node-types.md](references/node-types.md)
3. **规划子节点层级**：最多 3-4 层深度
4. **定义信号**：此场景会发出哪些事件？
5. **定义 @exports**：哪些参数需要在检查器中可调？

复杂的场景架构决策请参考 `godot-architect` 技能。

### 第 2 步：通过 MCP 创建场景

按以下顺序使用 Godot MCP 工具：

```
1. godot-mcp_create_scene(projectPath, scenePath, rootNodeType)
2. godot-mcp_add_node(projectPath, scenePath, parentNodePath, nodeType, nodeName, properties)
3. 对每个子节点重复第 2 步
4. godot-mcp_save_scene(projectPath, scenePath)
```

**命名规范**：
- 场景文件：`snake_case.tscn`（如 `health_component.tscn`）
- 根节点名称：`PascalCase`（如 `HealthComponent`）
- 子节点名称：`PascalCase` 加描述性后缀（如 `HealthBar`、`DamageLabel`）

### 第 3 步：挂载脚本

参见 [templates/component.gd](templates/component.gd) 和 [templates/actor.gd](templates/actor.gd) 获取即用型脚本模板。

### 第 4 步：配置唯一节点名称

对于需要被脚本访问的节点：

```
1. 在场景编辑器中，右键点击节点 -> "Access as Unique Name"
2. 这会在 .tscn 中创建 %NodeName 语法
3. 在脚本中：@onready var _sprite: AnimatedSprite2D = %PlayerSprite
```

### 第 5 步：连接信号

参见 [references/signal-connection-guide.md](references/signal-connection-guide.md) 获取详细的信号连接模式。

模式 A — 通过脚本（推荐用于 AI 工作流）：
```gdscript
func _ready() -> void:
	%HealthComponent.died.connect(_on_died)
	%HealthComponent.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: int) -> void:
	%HealthBar.value = new_health

func _on_died() -> void:
	died.emit()  # 向上传播信号
```

## 参考资料（按需加载）

### 节点与场景指南
- **节点类型参考**：[references/node-types.md](references/node-types.md) — 完整的 2D/3D/UI 节点选择指南及决策树
- **场景创建步骤**：[references/scene-creation-steps.md](references/scene-creation-steps.md) — 来自开发者技能的分步场景创建指南
- **节点选择指南**：[references/node-selection-guide.md](references/node-selection-guide.md) — 详细的节点类型选择标准
- **信号连接指南**：[references/signal-connection-guide.md](references/signal-connection-guide.md) — 信号模式与连接工作流

## 场景类型模板

### Actor 场景（玩家、敌人、NPC）

```
ActorRoot (CharacterBody2D/Area2D)
├── Sprite (AnimatedSprite2D / Sprite2D)
├── Collision (CollisionShape2D / CollisionPolygon2D)
├── StateMachine (Node)
│   ├── IdleState (State)
│   └── MoveState (State)
├── HitboxComponent (Area2D)
│   └── CollisionShape2D
└── HurtboxComponent (Area2D)
    └── CollisionShape2D
```

### Component 场景（可复用）

关键规则：
- 组件场景必须是**自包含的**
- 仅通过**信号**进行通信
- 禁止使用 `get_parent()` 调用 — 使用信号代替

### UI 场景（HUD、菜单、对话框）

关键规则：
- 使用 Container 节点进行布局（禁止手动定位）
- 使用 Theme 资源保持样式一致
- 通过 autoload 将 UI 信号连接到游戏逻辑

### 关卡场景

```
LevelRoot (Node2D / Node3D)
├── TileMapLayer / GridMap
├── Props (StaticBody 集合)
├── SpawnPoints (Marker2D 集合)
├── Triggers (Area2D 集合)
├── NavigationRegion2D/3D
└── Environment (Light, Sky, Particles)
```

## 场景组织规则

### 文件放置
- 场景与脚本放在同一目录：`src/actors/player/player.tscn` + `player.gd`
- 每个文件一个场景，禁止嵌套场景定义
- 调试/测试场景放在 `_debug/` 子目录中

### 通信模式

| 方向 | 方法 |
|------|------|
| 父 → 子 | 直接方法调用 |
| 子 → 父 | 信号发射 |
| 兄弟 → 兄弟 | 通过共同父节点的信号 |
| 跨场景 | Autoload 信号总线 |

### 组合优于继承

```
✅ 推荐：
Player Scene → 包含 HealthComponent, MovementComponent, CombatComponent

❌ 不推荐：
BaseEntity → MovingEntity → CombatEntity → PlayerEntity（深层继承）
```

## 约束

- **禁止**硬编码节点路径（`$Parent/Child/Node`）— 使用 `%UniqueName`
- **禁止**场景树嵌套超过 4 层
- **必须**在修改后通过 `godot-mcp_save_scene` 保存场景
- **必须**对新增/修改的 .gd 文件运行 `minimal-godot_get_diagnostics`
- **禁止**在 UI 场景脚本中放置业务逻辑 — 委托给 autoload 或组件
- 场景文件（.tscn）应仅通过 MCP 工具修改，禁止直接文本编辑
