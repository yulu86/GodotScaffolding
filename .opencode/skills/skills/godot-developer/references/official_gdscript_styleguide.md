# GDScript 官方风格指南

> **宪法级文档** - 本文是 Godot 官方的 GDScript 编码风格指南，所有 GDScript 代码必须严格遵循本指南。

本文档提供了编写一致且可读的 GDScript 代码的推荐约定和规范，基于 Godot 官方文档（https://docs.godotengine.org/zh-cn/4.x/tutorials/scripting/gdscript/gdscript_styleguide.html）。

## 目录
- [命名规范](#命名规范)
- [格式化](#格式化)
- [类型提示](#类型提示)
- [代码组织](#代码组织)
- [最佳实践](#最佳实践)
- [注释规范](#注释规范)

---

## 命名规范

### 类名
使用 PascalCase（大驼峰命名法）：
```gdscript
class_name PlayerCharacter
extends CharacterBody2D

class_name GameDatabase
extends Resource
```

### 文件名
使用 snake_case（下划线命名法）：
```
player_character.gd
game_database.gd
```

### 变量和函数名
使用 snake_case（下划线命名法）：
```gdscript
var player_health = 100
var movement_speed = 5.0

func calculate_damage():
    pass

func update_player_position():
    pass
```

### 常量
使用 UPPER_SNAKE_CASE（大写下划线命名法）：
```gdscript
const MAX_HEALTH = 100
const GRAVITY = 980.0
const SPAWN_POSITION = Vector2(100, 100)
```

### 私有成员
使用下划线前缀表示私有成员：
```gdscript
var _private_variable = 0
var _internal_state = {}

func _private_method():
    pass
```

### 信号
使用过去时或事件描述性命名：
```gdscript
signal health_changed(new_health)
signal player_died
signal level_completed
signal item_collected(item_data)
```

### 枚举
使用 PascalCase，成员使用 UPPER_SNAKE_CASE：
```gdscript
enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

enum Element {
    FIRE,
    WATER,
    EARTH,
    AIR
}
```

---

## 格式化

### 缩进
使用制表符（Tab）进行缩进，不使用空格。这允许开发者在编辑器中设置自己喜欢的缩进宽度。

### 行长度
建议每行不超过 100 个字符。当一行过长时，在运算符后换行：

```gdscript
# 好的示例
var result = (first_variable * second_variable +
              third_variable) / fourth_variable

# 函数调用参数过多时换行
some_function(
    parameter_one,
    parameter_two,
    parameter_three
)
```

### 空行
使用空行分隔逻辑相关的代码块：
```gdscript
extends Node2D

var health = 100
var speed = 5.0


func _ready():
    setup_player()
    connect_signals()


func setup_player():
    # 初始化玩家设置
    pass


func connect_signals():
    # 连接信号
    pass
```

### 括号和空格
- 在关键字后使用空格
- 函数调用的括号前不加空格
- 运算符两侧使用空格

```gdscript
# 好的示例
if condition:
    do_something()

for i in range(10):
    print(i)

var result = a + b * c

# 不好的示例
if condition:
    do_something ( )  # 括号前有空格

var result = a+b*c    # 运算符没有空格
```

---

## 类型提示

### 使用类型提示
为变量、参数和返回值添加类型提示，提高代码可读性和 IDE 支持：

```gdscript
# 变量类型提示
var player_name: String = "Player"
var position: Vector2 = Vector2.ZERO
var inventory: Array[Item] = []
var is_active: bool = true

# 函数参数和返回值类型提示
func calculate_damage(base_damage: int, multiplier: float) -> int:
    return int(base_damage * multiplier)

func get_player_position() -> Vector2:
    return global_position

# 使用时强制转换
var item = get_node("Item") as Item
```

### 类型推断
在初始化时让 GDScript 推断类型：

```gdscript
# 好的示例 - 类型推断
var players = []  # 推断为 Array
var count = 0     # 推断为 int
var node = $Node  # 推断为 Node

# 明确指定类型
var items: Array[Dictionary] = []
var health_component: HealthComponent = get_node("HealthComponent")
```

---

## 代码组织

### 文件结构
按照以下顺序组织代码：
1. 文档注释（如果适用）
2. class_name 语句
3. extends 语句
4. 常量定义
5. 导出的变量（@export）
6. 公共变量
7. 私有变量（_前缀）
8. 信号定义
9. @onready 变量
10. 虚函数重写（_ready, _process等）
11. 公共方法
12. 私有方法

```gdscript
# Player.gd
## 玩家角色类，处理玩家输入和移动
class_name Player
extends CharacterBody2D

# 常量
const MAX_SPEED = 300.0
const JUMP_VELOCITY = -400.0

# 导出变量
@export var speed: float = 300.0
@export var jump_strength: float = 400.0

# 公共变量
var health: int = 100
var is_grounded: bool = false

# 私有变量
var _velocity: Vector2 = Vector2.ZERO
var _animation_player: AnimationPlayer

# 信号
signal health_changed(new_health: int)
signal player_died

# @onready 变量
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
    _setup_player()

func _physics_process(delta: float):
    _handle_input()
    _apply_physics(delta)

# 公共方法
func take_damage(damage: int):
    health -= damage
    health_changed.emit(health)
    if health <= 0:
        _die()

# 私有方法
func _setup_player():
    _animation_player = $AnimationPlayer
    is_grounded = true

func _handle_input():
    pass

func _apply_physics(delta: float):
    pass

func _die():
    player_died.emit()
    queue_free()
```

### 函数长度
保持函数简短，通常不超过 20-30 行。如果一个函数过长，考虑将其拆分为多个小函数。

### 单一职责
每个函数应该只做一件事。如果函数名包含"and"或"or"，考虑拆分：

```gdscript
# 不好的示例
func update_and_check_collision():
    # 更新位置
    # 检查碰撞
    # 处理伤害
    pass

# 好的示例
func update_position():
    pass

func check_collisions():
    pass

func apply_damage():
    pass
```

---

## 最佳实践

### 使用节点的引用
使用 `@onready` 或获取节点引用，避免重复查找：

```gdscript
# 好的示例
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $UI/HealthBar

func _ready():
    animation_player.play("idle")
    health_bar.value = health

# 不好的示例 - 重复查找
func some_function():
    $AnimationPlayer.play("run")

func another_function():
    $AnimationPlayer.play("jump")
```

### 使用信号
优先使用信号而不是直接调用，以减少耦合：

```gdscript
# 好的示例 - 使用信号
signal health_changed(new_health: int)

func take_damage(damage: int):
    health -= damage
    health_changed.emit(health)

# 其他节点监听
player.health_changed.connect(_on_player_health_changed)

# 不好的示例 - 直接调用
func take_damage(damage: int):
    health -= damage
    ui.update_health_bar(health)  # 直接调用UI
```

### 使用状态机
对于复杂的对象状态，使用状态机模式：

```gdscript
# 好的示例 - 使用枚举表示状态
enum State {
    IDLE,
    WALKING,
    RUNNING,
    JUMPING
}

var current_state: State = State.IDLE

func _physics_process(delta: float):
    match current_state:
        State.IDLE:
            _handle_idle_state()
        State.WALKING:
            _handle_walking_state(delta)
        State.RUNNING:
            _handle_running_state(delta)
        State.JUMPING:
            _handle_jumping_state(delta)
```

### 资源管理
使用 `preload()` 预加载常量资源，使用 `load()` 加载动态资源：

```gdscript
# 预加载常量资源
const PLAYER_SCENE = preload("res://scenes/player.tscn")
const BULLET_SCENE = preload("res://scenes/bullet.tscn")

func spawn_bullet():
    var bullet = BULLET_SCENE.instantiate()
    add_child(bullet)

# 加载动态资源
func load_level(level_path: String):
    var level = load(level_path)
    if level:
        get_tree().change_scene_to_packed(level)
```

### 错误处理
使用 `assert()` 检查开发时的假设，使用条件检查处理运行时错误：

```gdscript
func get_player_data():
    # 开发时检查
    assert(player_node != null, "Player node should be set")

    # 运行时检查
    if not player_node:
        push_error("Player node is missing")
        return null

    return player_node.get_data()
```

### 使用组
使用组来管理相关的节点：

```gdscript
# 在敌人节点中
func _ready():
    add_to_group("enemies")

# 在管理器中
func get_all_enemies() -> Array:
    return get_tree().get_nodes_in_group("enemies")

func damage_all_enemies(damage: int):
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy.has_method("take_damage"):
            enemy.take_damage(damage)
```

---

## 注释规范

### 文档注释
为类、重要函数和复杂变量使用文档注释：

```gdscript
## 玩家角色控制器
##
## 处理玩家输入、移动和动画。支持平台跳跃和战斗。
## @tutorial: https://example.com/tutorial
class_name Player
extends CharacterBody2D

## 玩家的当前生命值（0-100）
@export var health: int = 100

## 计算并施加伤害
##
## [param base_damage] 基础伤害值
## [param damage_type] 伤害类型
## [returns] 实际造成的伤害值
func calculate_damage(base_damage: int, damage_type: String) -> int:
    # 根据防御力减少伤害
    var actual_damage = base_damage - defense
    return max(0, actual_damage)
```

### 行内注释
使用行内注释解释复杂逻辑：

```gdscript
# 计算抛物线轨迹
var velocity_y = initial_velocity.y - gravity * time  # 重力影响Y轴速度
var position_y = initial_position.y + velocity_y * time  # 更新Y轴位置

# 检查是否击中目标
if ray_cast.is_colliding():
    var hit_object = ray_cast.get_collider()  # 获取碰撞对象
    if hit_object.is_in_group("enemies"):  # 确认是敌人
        deal_damage(hit_object)
```

### TODO 和 FIXME
使用 TODO 和 FIXME 标记未完成的工作：

```gdscript
# TODO: 实现双跳机制
func double_jump():
    pass

# FIXME: 这里的碰撞检测有问题，需要修复
func check_collision():
    # 临时解决方案
    pass
```

---

## 总结

遵循这些编码规范将帮助您编写：
- 更易读的代码
- 更易维护的项目
- 更好的协作体验
- 更少的 bug

记住，这些是指导原则，不是严格的规则。在特定情况下，可以根据项目需求进行调整，但保持一致性是最重要的。

### 相关资源
- [Godot官方文档 - GDScript风格指南](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot官方文档 - GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)

---

**来源**: Godot Engine 官方文档 - GDScript Style Guide
**版本**: Godot 4.x
**更新日期**: 2024