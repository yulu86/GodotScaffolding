# Godot 脚本类命名规范

## 核心原则

### 1. 场景脚本命名（最重要）
场景附加的脚本类名必须与场景文件名保持完全一致：

```
场景文件          脚本类名        ✓ 正确        ✗ 错误
player.tscn      Player         ✓             PlayerController
enemy.tscn       Enemy          ✓             EnemyManager
ui_menu.tscn     UiMenu         ✓             MenuController
game_world.tscn  GameWorld      ✓             WorldManager
```

### 2. 命名约定

#### 2.1 基本规则
- 使用 PascalCase（首字母大写）
- 类名简洁明了，直接反映功能
- 脚本文件名与类名一致（扩展名不同）

#### 2.2 避免的后缀
除非真正需要，否则避免使用以下后缀：
- Controller（控制器）
- Manager（管理器）
- Handler（处理器）
- System（系统）

#### 2.3 合理使用后缀的情况

**Manager 后缀**
```gdscript
# ✓ 正确：真正管理多个对象
class_name AudioManager
class_name SaveManager
class_name PoolManager

# ✗ 错误：仅管理单个对象
class_name PlayerManager  # 应该是 Player
```

**Controller 后缀**
```gdscript
# ✓ 正确：复杂输入控制
class_name InputController
class_name NetworkController

# ✗ 错误：简单的场景脚本
class_name PlayerController  # 应该是 Player
```

## 具体示例

### 游戏对象
```gdscript
# 场景: player.tscn
class_name Player
extends CharacterBody2D

# 场景: enemy_robot.tscn
class_name EnemyRobot
extends CharacterBody2D

# 场景: projectile.tscn
class_name Projectile
extends Area2D
```

### UI 元素
```gdscript
# 场景: ui_health_bar.tscn
class_name UiHealthBar
extends Control

# 场景: ui_button.tscn
class_name UiButton
extends Button

# 场景: ui_inventory_slot.tscn
class_name UiInventorySlot
extends Panel
```

### 工具类（非场景附加）
```gdscript
# 文件: math_utils.gd
class_name MathUtils

# 文件: game_events.gd
class_name GameEvents

# 文件: dialog_parser.gd
class_name DialogParser
```

### 单例（Singleton）
```gdscript
# 文件: game.gd (project.gdofiles 中配置为 AutoLoad)
extends Node
# 禁止使用 class_name，直接通过文件名访问

# 文件: audio_manager.gd (project.gdofiles 中配置为 AutoLoad)
extends Node
# 禁止使用 class_name
```

### 特殊系统
```gdscript
# 场景: state_machine.tscn
class_name StateMachine
extends Node

# 场景: dialog_system.tscn
class_name DialogSystem
extends Node
```

## 常见错误对照表

| 场景文件 | 错误类名 | 正确类名 | 原因 |
|---------|---------|---------|------|
| player.tscn | PlayerController | Player | 过度使用Controller后缀 |
| enemy.tscn | EnemyManager | Enemy | 仅管理单个对象 |
| ui_menu.tscn | MenuHandler | UiMenu | Handler后缀不必要 |
| game_world.tscn | WorldSystem | GameWorld | System后缀不必要 |
| inventory.tscn | InventoryManager | Inventory | Manager后缀不必要 |

## 记忆口诀

1. **场景名叫啥，类名就叫啥**
2. **能不加后缀，就别加后缀**
3. **真正需要再加，不是所有都加**
4. **Singleton特殊，禁止class_name**

## 业界最佳实践

1. **一致性**：整个项目保持统一的命名风格
2. **简洁性**：类名越短越好，但要有意义
3. **可读性**：其他开发者看到类名就知道其用途
4. **维护性**：避免重构时的命名混乱

这套规范参考了 Godot 官方示例、知名开源项目和业界专家的建议，旨在提高代码的可维护性和团队协作效率。