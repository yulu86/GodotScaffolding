---
name: godot-scene
description: Godot 4.x 场景创建和修改的标准化流程 Skill。指导场景树设计、节点选择、场景组织、组件化拆分和信号连接。当需要创建新场景、修改场景结构、添加节点、组织场景层级、创建可复用组件场景、设计场景间交互、选择节点类型或连接信号时触发此技能。
---

# Godot 场景构建器

创建和修改 Godot 4.x 场景的标准化工作流。采用 **AI 创建基本框架 + 用户可视化操作** 的协作模式。

## 适用场景

- 创建新场景（Actor、UI、关卡、组件）
- 修改现有场景树结构
- 设计可复用的组件场景
- 设置节点间的信号连接
- 选择合适的节点类型

## ⚠️ 核心协作原则

### AI 职责（可执行）
- 通过 MCP 工具创建场景的**基本框架**（节点树骨架、基本节点类型）
- 设计场景架构（节点层级、通信模式）
- 输出详细操作指导文档到 `tmp/` 目录

### 用户职责（AI 禁止执行）
- 所有需要**可视化确认**的操作，包括但不限于：
  - 加载图片/纹理等资源
  - 设置精确位置、锚点、偏移等布局属性
  - 微调 Container 的间距、边距等参数
  - 配置动画关键帧
  - 任何需要"看到效果才能确定"的操作

### 执行规则
- 场景创建/编辑**不需要**暂停其他并行任务
- AI 创建场景基本框架后，可继续执行 Story 中的脚本编写、测试等任务
- 当 Story 中的所有任务都执行完成后，AI **必须暂停执行**，等待用户在编辑器中编辑场景
- 用户显式确认场景编辑完成后，AI **必须**检视场景并执行测试用例验证
- 场景开发任务**禁止**在子agent 中执行

## 场景创建工作流

### 第 1 步：设计场景架构

在操作任何文件之前：

1. **确定场景类型**：Actor / Component / UI / Level
2. **选择根节点类型**：参见 [references/node-types.md](references/node-types.md)
3. **规划子节点层级**：最多 3-4 层深度
4. **定义信号**：此场景会发出哪些事件？
5. **定义 @exports**：哪些参数需要在检查器中可调？

复杂的场景架构决策请参考 `godot-architect` 技能。

### 第 2 步：AI 创建基本框架

通过 MCP 工具创建场景的节点树骨架（**禁止设置可视化属性**）：

```
1. godot-mcp_create_scene(projectPath, scenePath, rootNodeType)
2. godot-mcp_add_node(projectPath, scenePath, parentNodePath, nodeType, nodeName)
   — 仅添加节点，不设置位置/尺寸/纹理等可视化属性
3. 对每个子节点重复第 2 步
4. godot-mcp_save_scene(projectPath, scenePath)
```

**命名规范**：
- 场景文件：`snake_case.tscn`（如 `health_component.tscn`）
- 根节点名称：`PascalCase`（如 `HealthComponent`）
- 子节点名称：`PascalCase` 加描述性后缀（如 `HealthBar`、`DamageLabel`）

**AI 禁止执行的操作**：
- ❌ 设置精确位置（`position`）、锚点（`anchor`）、偏移（`offset`）等
- ❌ 加载图片/纹理资源（`texture` 属性）
- ❌ 设置 Container 的 `gap`、`padding` 等微调参数
- ❌ 配置动画关键帧

### 第 3 步：输出操作指导文档

将所有需要用户可视化操作的内容整理为操作指导文档，输出到 `tmp/` 目录。

**文件命名格式**：`tmp/{序号}_{场景名称}_scene_guide.md`

**操作指导文档模板**：

```markdown
# {场景名称} 场景操作指导

## 目标说明
本次场景操作要达成的目的和设计意图。

## 前置准备
- 需要准备的资源列表（图片、TileSet、字体等）
- 资源放置路径

## 节点树结构
（使用缩进表示层级）
- ActorRoot (CharacterBody2D)
  - Sprite (AnimatedSprite2D)
  - Collision (CollisionShape2D)

## 详细操作步骤

### 步骤 1：{操作名称}
- **操作对象**：选中 {节点路径}
- **操作面板**：Inspector → {属性区域}
- **具体值**：{属性的精确值}
- **设计意图**：为什么要这样设置

### 步骤 2：...

## 复杂操作专项说明
（锚点、TileSet、动画、碰撞、信号等专项说明，按需添加）

## 验证方法
- 操作完成后的验证步骤

## 常见问题
- 该操作中容易出错的地方及解决方法
```

### 第 4 步：继续执行 Story 其他任务

**场景创建不暂停其他任务**：
1. 输出操作指导后，AI 继续执行 Story 中的其他任务（脚本编写、测试等）
2. 当 Story 中所有任务完成后，AI 暂停执行，告知用户操作指导已输出到 `tmp/` 目录
3. 显示等待提示，等待用户在编辑器中完成可视化操作
4. 用户确认"完成"后，AI 检视场景（节点树、信号连接、脚本挂载）并执行测试用例验证

### 第 5 步：挂载脚本

参见 [templates/component.gd](templates/component.gd) 和 [templates/actor.gd](templates/actor.gd) 获取即用型脚本模板。

### 第 6 步：配置唯一节点名称

对于需要被脚本访问的节点：

```
1. 在场景编辑器中，右键点击节点 -> "Access as Unique Name"
2. 这会在 .tscn 中创建 %NodeName 语法
3. 在脚本中：@onready var _sprite: AnimatedSprite2D = %PlayerSprite
```

### 第 7 步：连接信号

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
- **禁止** AI 设置需要可视化确认的属性（位置、锚点、纹理等）
- **禁止**在 UI 场景脚本中放置业务逻辑 — 委托给 autoload 或组件
- **禁止**在子agent 中执行场景开发任务
- **必须**通过操作指导文档（`tmp/` 目录）指导用户完成可视化操作
- **可以**在创建场景框架后继续执行 Story 中的其他任务（脚本编写、测试等）
- **必须**在 Story 所有任务完成后暂停，等待用户编辑场景
- **必须**在用户确认后检视场景并执行测试用例
- **必须**对新增/修改的 .gd 文件运行 `minimal-godot_get_diagnostics`
