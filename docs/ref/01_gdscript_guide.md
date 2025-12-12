# GDScript语言完整指南

GDScript是Godot引擎的高级、动态类型编程语言，针对Godot的API进行了优化，语法类似于Python，专门为游戏开发设计。

## 目录

1. [基础语法](#基础语法)
2. [语言特性](#语言特性)
3. [数据类型](#数据类型)
4. [控制流程](#控制流程)
5. [函数](#函数)
6. [面向对象编程](#面向对象编程)
7. [静态类型](#静态类型)
8. [导出属性](#导出属性)
9. [注释与文档](#注释与文档)
10. [编码规范](#编码规范)
11. [字符串格式化](#字符串格式化)
12. [高级特性](#高级特性)

## 基础语法

### 注释
```gdscript
# 这是单行注释
"""
这是多行注释
可以跨越多行
"""
```

### 变量声明
```gdscript
# 动态类型
var name = "Player"
var score = 100
var is_active = true

# 静态类型
var player_name: String = "Hero"
var health: int = 100
var position: Vector2 = Vector2(0, 0)
```

### 常量
```gdscript
const MAX_HEALTH = 100
const GAME_VERSION = "1.0"
const GRAVITY = 9.81
```

## 语言特性

### 强类型转换
GDScript会自动进行类型转换，也可以手动转换：

```gdscript
var string_number = "42"
var number = int(string_number)  # 手动转换
var result = "Value: " + str(42)  # 自动转换
```

### 装饰器（Annotations）
```gdscript
extends Node2D

# 导出变量到编辑器
@export var speed: float = 200.0
@export var sprite_texture: Texture2D

# 在编辑器运行
@tool
func _ready():
    pass

# 就绪时初始化
@onready var animated_sprite = $AnimatedSprite2D
```

## 数据类型

### 基础类型
- **int**: 整数
- **float**: 浮点数
- **bool**: 布尔值
- **String**: 字符串

### 容器类型
```gdscript
# 数组
var numbers = [1, 2, 3, 4, 5]
var mixed_array = [1, "hello", true, 3.14]
var typed_array: Array[int] = [1, 2, 3]

# 字典
var player_data = {
    "name": "Hero",
    "level": 5,
    "inventory": ["sword", "potion"]
}

# 集合和字典（键只能是字符串）
var inventory: Dictionary = {}
inventory["sword"] = 1
inventory["potion"] = 3
```

### Vector类型
```gdscript
var pos2d: Vector2 = Vector2(100, 50)
var pos3d: Vector3 = Vector3(0, 1, 2)
var color: Color = Color(1, 0, 0)  # 红色
```

### Godot内置类型
```gdscript
var node: Node = Node.new()
var sprite: Sprite2D = Sprite2D.new()
var timer: Timer = Timer.new()
```

## 控制流程

### 条件语句
```gdscript
if health > 50:
    print("健康状态良好")
elif health > 0:
    print("需要治疗")
else:
    print("游戏结束")
```

### 循环
```gdscript
# for循环
for i in range(10):
    print(i)

for item in inventory:
    print("物品:", item)

# while循环
while health > 0:
    take_damage(1)

# 遍历字典
for key in player_data:
    print(key, ": ", player_data[key])
```

### 匹配语句（GDScript 2.0+）
```gdscript
match action:
    "move":
        move_player()
    "attack":
        attack_enemy()
    5:
        print("特殊值5")
    _:
        print("默认情况")
```

## 函数

### 基本函数定义
```gdscript
func greet(name: String) -> String:
    return "Hello, " + name + "!"

func calculate_damage(base_damage: int, multiplier: float) -> int:
    return int(base_damage * multiplier)

# 无返回值函数
func apply_damage():
    health -= 10
```

### 参数默认值
```gdscript
func create_bullet(speed: float = 300.0, damage: int = 10):
    var bullet = Bullet.instantiate()
    bullet.speed = speed
    bullet.damage = damage
    return bullet
```

### 可变参数
```gdscript
func sum_numbers(numbers: Array) -> int:
    var total = 0
    for number in numbers:
        total += number
    return total

# 调用
var result = sum_numbers([1, 2, 3, 4, 5])
```

### Lambda函数
```gdscript
var numbers = [1, 2, 3, 4, 5]
var doubled = numbers.map(func(x): return x * 2)
var filtered = numbers.filter(func(x): return x > 3)
```

## 面向对象编程

### 类定义
```gdscript
# 脚本文件中的类（隐式类名基于文件名）
extends Node2D

var health: int = 100
var max_health: int = 100

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        die()

func heal(amount: int):
    health = min(health + amount, max_health)
```

### 内部类
```gdscript
extends Node

# 内部类定义
class Character:
    var name: String
    var level: int

    func _init(n: String, l: int):
        name = n
        level = l

func create_character():
    return Character.new("Hero", 1)
```

### 命名类（class_name）
```gdscript
class_name PlayerCharacter
extends CharacterBody2D

var experience: int = 0

func gain_exp(amount: int):
    experience += amount
    if experience >= 100:
        level_up()
```

### 继承
```gdscript
# 父类
extends Node

var name: String = ""

func get_name() -> String:
    return name

# 子类
extends "res://scripts/parent.gd"

func _ready():
    super._ready()  # 调用父类方法
    name = "Child"
```

## 静态类型

### 类型提示
```gdscript
# 基本类型
var health: int = 100
var speed: float = 200.0
var is_alive: bool = true

# 复杂类型
var position: Vector2 = Vector2.ZERO
var children: Array[Node] = []
var stats: Dictionary = {}

# Godot类型
var sprite: Sprite2D
var timer: Timer
```

### 函数类型提示
```gdscript
func process_input(input_vector: Vector2) -> void:
    velocity = input_vector * speed

func get_player_stats() -> Dictionary:
    return {
        "health": health,
        "score": score,
        "level": level
    }

func create_enemy(enemy_type: String) -> Enemy:
    var enemy = enemy_scenes[enemy_type].instantiate()
    add_child(enemy)
    return enemy
```

### 泛型
```gdscript
# 使用泛型的Array和Dictionary
var string_list: Array[String] = ["a", "b", "c"]
var int_to_string: Dictionary[int, String] = {1: "one", 2: "two"}

# 自定义泛型方法（需要工具模式）
@tool
static func create_typed_array[T](type: Variant) -> Array:
    var result: Array = []
    result.set_typed(type)
    return result
```

## 导出属性

### 基本导出
```gdscript
extends Node

# 基础导出
@export var player_name: String = "Player"
@export var max_health: int = 100
@export var move_speed: float = 200.0

# 范围限制
@export_range(0, 100) var health: int = 50
@export_range(0.0, 1.0, 0.1) var opacity: float = 1.0

# 枚举
@export var character_class: String = "warrior"  # 下拉菜单

# 文件路径
@export var texture_path: String = "res://assets/textures/player.png"
@export var scene_file: PackedScene

# 多选
@export var abilities: Array[String] = ["jump", "attack"]
```

### 条件导出
```gdscript
@export var use_custom_color: bool = false
@export var custom_color: Color = Color.WHITE  # 只有use_custom_color为true时显示
```

### 分组导出
```gdscript
@export_group("Player Stats")
@export var health: int = 100
@export var mana: int = 50
@export var strength: int = 10

@export_group("Equipment", "equipment_")
@export var equipment_weapon: String = "sword"
@export var equipment_armor: String = "leather"

@export_subgroup("Magic Equipment", "magic_")
@export var magic_staff: String = "basic"
@export var magic_spell: String = "fireball"

@export_group("")  # 结束分组
```

## 注释与文档

### 文档注释
```gdscript
## 玩家角色类
##
## 管理玩家的状态和行为，包括移动、攻击和生命值管理。
class_name Player
extends CharacterBody2D

## 玩家当前生命值 (0-100)
var health: int = 100

## 移动速度（单位：像素/秒）
@export var speed: float = 200.0

## 对敌人造成伤害
##
## @param damage: 伤害值
## @param enemy: 敌人节点
## @return: 是否成功造成伤害
func deal_damage(damage: int, enemy: Enemy) -> bool:
    if not enemy:
        return false

    enemy.take_damage(damage)
    return true

## 治疗玩家
##
## 根据治疗量增加生命值，但不会超过最大生命值。
## 使用公式: min(current_health + amount, max_health)
func heal(amount: int) -> void:
    health = min(health + amount, max_health)
```

### 内联文档
```gdscript
func calculate_damage(base: int, multiplier: float):
    # 强制转为整数，避免浮点精度问题
    var final_damage: int = int(base * multiplier)

    # 确保最小伤害为1
    return max(1, final_damage)  # ## 这行确保游戏平衡性
```

## 编码规范

### 命名约定
```gdscript
# 变量和函数：snake_case
var player_position: Vector2
var current_health: int

func update_animation():
    pass

# 常量：UPPER_CASE
const MAX_PLAYERS = 4
const GRAVITY = 9.81

# 类名：PascalCase
class_name Player
extends Node

# 文件名：snake_case.gd
# player.gd
# enemy_spawner.gd
```

### 代码组织
```gdscript
# 1. 类声明和继承
class_name Enemy
extends CharacterBody2D

# 2. 信号声明
signal died(exp_value: int)
signal health_changed(new_health: int)

# 3. 导出变量
@export var max_health: int = 100
@export var move_speed: float = 150.0

# 4. 公共变量
var health: int = 100
var is_alive: bool = true

# 5. 私有变量（以_开头）
var _attack_cooldown: float = 0.0
var _target_player: Player = null

# 6. 虚函数重写
func _ready():
    pass

func _process(delta):
    pass

# 7. 公共方法
func take_damage(amount: int):
    pass

func move_to_target(target_position: Vector2):
    pass

# 8. 私有方法
func _update_animation():
    pass

func _find_nearest_player():
    pass
```

### 代码格式化
```gdscript
# 缩进：使用制表符，不要用空格
# 行长度：建议不超过100字符

# 好的示例
func calculate_distance(from: Vector2, to: Vector2) -> float:
    var direction = to - from
    return direction.length()

# 避免过长的行
func complex_calculation(param1: int, param2: float, param3: String) -> Dictionary:
    var result = {
        "value": param1 * param2,
        "description": param3 + " completed"
    }
    return result
```

## 字符串格式化

### 基本格式化
```gdscript
var name = "Hero"
var level = 5
var health = 100

# 使用%操作符
var message = "玩家 %s 等级 %d，生命值 %d" % [name, level, health]

# 字符串插值（GDScript 2.0+）
var message2 = "玩家 {name} 等级 {level}，生命值 {health}".format({
    "name": name,
    "level": level,
    "health": health
})

# 使用str()函数
var message3 = "玩家" + name + "等级" + str(level)
```

### 数值格式化
```gdscript
var pi = 3.14159

# 保留小数位数
var formatted = "%.2f" % pi  # "3.14"

# 宽度和对齐
var padded = "[%10s]" % "hello"    # "[     hello]"
var left_padded = "[%-10s]" % "hello"  # "[hello     ]"

# 十六进制
var hex_value = "0x%X" % 255  # "0xFF"
```

### 安全格式化
```gdscript
# 使用字符串模板避免格式化错误
func format_score(score: int, name: String) -> String:
    return tr("SCORE_FORMAT") % {"score": score, "name": name}

# 本地化支持
var localized = tr("PLAYER_JOINED") % [name]
```

## 高级特性

### 协程（Yield）
```gdscript
func play_animation_sequence():
    play_animation("idle")
    await get_tree().create_timer(1.0).timeout  # 等待1秒

    play_animation("attack")
    await animation_player.animation_finished  # 等待动画完成

    play_animation("walk")
```

### 信号连接
```gdscript
# 信号定义
signal health_changed(new_value: int)
signal died

# 信号连接
func _ready():
    health_changed.connect(_on_health_changed)
    died.connect(_on_died)

# 信号发射
func take_damage(amount: int):
    health -= amount
    health_changed.emit(health)

    if health <= 0:
        died.emit()

# 信号处理
func _on_health_changed(new_value: int):
    health_bar.value = new_value

func _on_died():
    play_death_animation()
    set_process(false)
```

### 反射
```gdscript
func get_all_properties():
    var properties = []

    for property in get_property_list():
        if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            properties.append(property.name)

    return properties

func call_method_by_name(method_name: String, args: Array):
    if has_method(method_name):
        callv(method_name, args)
```

### 工具模式
```gdscript
@tool
extends EditorScript

func _run():
    # 在编辑器中执行的代码
    var node = get_scene().instantiate()
    node.position = Vector2(100, 100)
    get_scene().add_child(node)
```

## 性能优化建议

### 1. 使用适当的数据类型
```gdscript
# 使用float而不是Vector2进行简单计算
var distance: float = 100.0  # 而不是 Vector2(100, 0)

# 使用基本类型而不是对象当可能时
var is_active: bool = true  # 而不是创建对象
```

### 2. 缓存频繁访问的节点
```gdscript
# 缓存节点引用
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

func _process(delta):
    # 使用缓存的引用
    animated_sprite.play("run")
```

### 3. 批量操作
```gdscript
# 好的做法：批量更新
func update_all_enemies():
    for enemy in enemies:
        enemy.update_ai()  # 在一个循环中完成所有更新

# 避免：分散的更新
# func update_enemy1(): enemy1.update_ai()
# func update_enemy2(): enemy2.update_ai()
```

### 4. 使用对象池
```gdscript
class BulletPool:
    var available_bullets: Array[Bullet] = []
    var active_bullets: Array[Bullet] = []

    func get_bullet() -> Bullet:
        var bullet: Bullet
        if available_bullets.size() > 0:
            bullet = available_bullets.pop_back()
        else:
            bullet = Bullet.instantiate()

        active_bullets.append(bullet)
        return bullet

    func return_bullet(bullet: Bullet):
        active_bullets.erase(bullet)
        available_bullets.append(bullet)
```

## 调试技巧

### 断点调试
```gdscript
func debug_function():
    # 断点在这里
    var value = complex_calculation()
    print("计算结果:", value)
```

### 断言
```gdscript
func validate_input(input: String):
    assert(not input.is_empty(), "输入不能为空")
    assert(input.length() <= 20, "输入太长")
    process_input(input)
```

### 调试绘制
```gdscript
func _draw():
    if Engine.is_editor_hint() or debug_mode:
        # 绘制调试信息
        draw_circle(Vector2.ZERO, 50, Color.RED)
        draw_line(Vector2(-100, 0), Vector2(100, 0), Color.GREEN)
```

## 常见错误和解决方案

### 1. 空引用错误
```gdscript
# 错误做法
var node = get_node("NonExistentPath")
node.do_something()  # 会崩溃

# 正确做法
var node = get_node_or_null("NonExistentPath")
if node:
    node.do_something()
```

### 2. 类型转换错误
```gdscript
# 错误做法
var num = int("not_a_number")  # 返回0，可能不是期望的结果

# 正确做法
var text = "123"
if text.is_valid_int():
    var num = int(text)
```

### 3. 数组越界
```gdscript
var items = [1, 2, 3]

# 错误做法
var item = items[5]  # 会崩溃

# 正确做法
var index = 5
if index < items.size():
    var item = items[index]
```

## 最佳实践总结

1. **使用静态类型**：提高代码可读性和性能
2. **合理使用@export**：暴露必要的属性到编辑器
3. **编写文档注释**：提高代码可维护性
4. **遵循命名约定**：保持代码一致性
5. **缓存节点引用**：避免重复的get_node调用
6. **使用信号**：实现松耦合的组件通信
7. **编写测试**：确保代码质量
8. **性能优化**：注意避免不必要的计算和内存分配

GDScript是一门专门为游戏开发设计的语言，理解其特性和最佳实践将帮助你更有效地开发Godot游戏项目。记住，好的代码不仅需要运行正确，还需要易于理解和维护。