# TDD 工作流程详细指南

> **重要提示**：本文档是 godot-developer 技能的核心宪法级文档，所有 TDD 开发活动必须严格遵循本指南的流程和方法。

## 🎯 TDD 核心理念

测试驱动开发（TDD）是一种软件开发方法论，它要求在编写功能代码之前先编写测试。这种方法确保代码具有高质量、可测试性和清晰的接口设计。

### 核心原则
1. **测试先行**：先写测试，定义接口和预期行为
2. **小步前进**：一次只解决一个问题
3. **持续重构**：保持代码简洁和可维护性
4. **设计驱动**：通过测试引导良好的架构设计

## 🔄 Red-Green-Refactor 循环详细指导

### Red 阶段：编写失败的测试

#### 目标
- 明确功能需求
- 定义接口和行为
- 验证理解的正确性
- 确保测试确实会失败

#### 具体步骤

**1. 分析需求**
```text
需求示例：玩家可以向四个方向移动
- 玩家有位置属性
- 可以设置移动方向
- 移动速度可配置
- 支持上下左右四个方向
```

**2. 设计测试用例**
```gdscript
# test/unit/test_player_movement.gd
extends GutTest

var player: Player

func before_each():
    player = Player.new()
    add_child_autofree(player)

func test_player_can_move_right():
    # Red 阶段：这个测试会失败，因为 Player 类还不存在
    player.position = Vector2.ZERO
    player.movement_speed = 100.0

    player.move_direction(Vector2.RIGHT)
    player._process(1.0)  # 模拟1秒

    assert_eq(player.position.x, 100.0, "Player should move 100 units right in 1 second")
    assert_eq(player.position.y, 0.0, "Player should not move vertically")
```

**3. 运行测试确认失败**
```bash
# 运行测试确保失败
godot -s addons/gut/gut_cmdln.gd -gtest=res://test/unit/test_player_movement.gd -gexit
```

**Red 阶段检查清单：**
- [ ] 测试用例清晰描述了预期行为
- [ ] 测试确实失败（不是编译错误）
- [ ] 失败原因明确（缺少类、缺少方法等）
- [ ] 测试用例覆盖了核心功能
- [ ] 测试名称清晰描述被测试的功能

### Green 阶段：最小实现

#### 目标
- 用最少的代码让测试通过
- 专注功能性而非完美性
- 避免过度设计和过早优化

#### 具体步骤

**1. 创建最小实现**
```gdscript
# scripts/Player.gd
extends Node2D
class_name Player

var position: Vector2 = Vector2.ZERO
var movement_speed: float = 100.0

func move_direction(direction: Vector2):
    position += direction * movement_speed

func _process(delta: float):
    pass  # 最小实现，暂时不处理帧率
```

**2. 修正实现使测试通过**
```gdscript
# scripts/Player.gd - 修正版
extends Node2D
class_name Player

var position: Vector2 = Vector2.ZERO
var movement_speed: float = 100.0

func move_direction(direction: Vector2):
    pass  # 需要在 _process 中处理

func _process(delta: float):
    pass
```

**3. 完善最小实现**
```gdscript
# scripts/Player.gd - 通过版本
extends Node2D
class_name Player

var position: Vector2 = Vector2.ZERO
var movement_speed: float = 100.0
var _current_direction: Vector2 = Vector2.ZERO

func move_direction(direction: Vector2):
    _current_direction = direction
    position += direction * movement_speed  # 简单实现让测试通过

func _process(delta: float):
    # 简化版本，只让当前测试通过
    pass
```

**Green 阶段检查清单：**
- [ ] 测试通过
- [ ] 实现代码最小且简单
- [ ] 没有添加不必要的功能
- [ ] 代码符合基本规范
- [ ] 没有引入复杂的设计模式

### Refactor 阶段：重构优化

#### 目标
- 在保持测试通过的前提下优化代码
- 提高代码可读性和可维护性
- 消除代码重复
- 改善设计

#### 具体步骤

**1. 分析当前实现的问题**
```text
问题分析：
- move_direction 直接修改位置，不考虑帧率
- _process 方法空实现
- 缺少物理相关的处理
- 移动逻辑不够清晰
```

**2. 重构代码结构**
```gdscript
# scripts/Player.gd - 重构版本
extends Node2D
class_name Player

@export var movement_speed: float = 100.0
var position: Vector2 = Vector2.ZERO:
    set = set_position
var _velocity: Vector2 = Vector2.ZERO
var _input_direction: Vector2 = Vector2.ZERO

func set_position(new_position: Vector2):
    position = new_position
    # 触发位置变化信号等

func move_direction(direction: Vector2):
    """设置移动方向"""
    _input_direction = direction.normalized()

func _process(delta: float):
    """处理移动逻辑"""
    _update_velocity()
    _apply_movement(delta)

func _update_velocity():
    """更新速度"""
    if _input_direction.length() > 0:
        _velocity = _input_direction * movement_speed
    else:
        _velocity = Vector2.ZERO

func _apply_movement(delta: float):
    """应用移动"""
    position += _velocity * delta
```

**3. 验证重构结果**
```bash
# 重新运行测试确保仍然通过
godot -s addons/gut/gut_cmdln.gd -gtest=res://test/unit/test_player_movement.gd -gexit
```

**Refactor 阶段检查清单：**
- [ ] 所有测试仍然通过
- [ ] 代码结构更清晰
- [ ] 消除了代码重复
- [ ] 提高了可读性
- [ ] 没有改变外部行为

## 🧪 测试用例设计原则和方法

### 测试金字塔原则

#### 单元测试 (70%)
**目标**：测试单个函数或类的行为
**特点**：快速、独立、隔离

```gdscript
# 单元测试示例
func test_player_health_initialization():
    # 测试单个属性
    var player = Player.new()
    assert_eq(player.health, 100, "Player should start with 100 health")

func test_player_take_damage_calculation():
    # 测试单个方法
    var player = Player.new()
    player.health = 100
    player.take_damage(30)
    assert_eq(player.health, 70, "Health should decrease by damage amount")
```

#### 集成测试 (20%)
**目标**：测试多个组件的协作
**特点**：测试真实交互、发现接口问题

```gdscript
# 集成测试示例
func test_player_weapon_integration():
    # 测试玩家和武器的协作
    var player = Player.new()
    var weapon = Weapon.new()
    weapon.damage = 25

    player.equip_weapon(weapon)
    player.attack()

    assert_called(weapon, "fire")
    assert_signal_emitted(weapon, "fired")
```

#### 端到端测试 (10%)
**目标**：测试完整的功能流程
**特点**：高成本、高价值、用户视角

```gdscript
# 端到端测试示例
func test_complete_gameplay_flow():
    # 测试完整的游戏流程
    var game_scene = preload("res://scenes/game.tscn").instantiate()
    add_child_autofree(game_scene)

    var player = game_scene.get_node("Player")
    var enemy = game_scene.get_node("Enemy")

    # 模拟完整交互
    player.move_to(enemy.position)
    wait_for_signal(player, "reached_target", 2.0)
    player.attack()

    assert_lt(enemy.health, enemy.max_health, "Enemy should take damage")
    assert_signal_emitted(enemy, "health_changed")
```

### 测试用例设计方法

#### 边界值分析
```gdscript
# 测试边界值：0, 1, 最大值-1, 最大值, 最大值+1
func test_inventory_capacity_boundaries():
    var inventory = Inventory.new()
    inventory.capacity = 10

    # 测试空容量
    var empty_inventory = Inventory.new()
    empty_inventory.capacity = 0
    var result = empty_inventory.add_item(Item.new())
    assert_false(result.success, "Cannot add item to empty inventory")

    # 测试满容量
    for i in range(10):
        inventory.add_item(Item.new())

    result = inventory.add_item(Item.new())
    assert_false(result.success, "Cannot add item to full inventory")

    # 测试边界值 9 -> 10
    inventory.remove_item(0)  # 移除一个物品
    result = inventory.add_item(Item.new())
    assert_true(result.success, "Should add item when not full")
```

#### 等价类划分
```gdscript
# 将输入划分为不同类别，每个类别测试一个代表
func test_player_name_validation():
    var player = Player.new()

    # 有效名称类别
    var valid_names = ["Player", "Hero", "Test123"]
    for name in valid_names:
        var result = player.set_name(name)
        assert_true(result.success, "Valid name should be accepted: %s" % name)

    # 无效名称类别：空字符串
    var result = player.set_name("")
    assert_false(result.success, "Empty name should be rejected")

    # 无效名称类别：特殊字符
    var invalid_names = ["Player@#", "Hero$", "Test!"]
    for name in invalid_names:
        result = player.set_name(name)
        assert_false(result.success, "Special characters should be rejected: %s" % name)
```

#### 错误推测法
```gdscript
# 基于经验推测可能的错误情况
func test_player_movement_edge_cases():
    var player = Player.new()
    player.movement_speed = 100.0

    # 测试零速度
    player.movement_speed = 0.0
    player.move_direction(Vector2.RIGHT)
    player._process(1.0)
    assert_eq(player.position, Vector2.ZERO, "Zero speed should not move player")

    # 测试负速度
    player.movement_speed = -100.0
    player.position = Vector2.ZERO
    player.move_direction(Vector2.RIGHT)
    player._process(1.0)
    assert_eq(player.position.x, -100.0, "Negative speed should move in opposite direction")

    # 测试极大速度
    player.movement_speed = 1e6
    player.position = Vector2.ZERO
    player.move_direction(Vector2.RIGHT)
    player._process(0.016)  # 一帧时间
    # 检查是否合理，避免溢出
    assert_lt(player.position.x, 1e5, "Very large speed should be handled reasonably")
```

## 🔧 测试重构和维护策略

### 测试重构模式

#### 提取测试公共代码
```gdscript
# 重构前：重复的测试设置
func test_player_move_right():
    var player = Player.new()
    player.health = 100
    player.position = Vector2.ZERO
    player.movement_speed = 100.0
    add_child_autofree(player)
    # 测试逻辑...

func test_player_move_left():
    var player = Player.new()
    player.health = 100
    player.position = Vector2.ZERO
    player.movement_speed = 100.0
    add_child_autofree(player)
    # 测试逻辑...

# 重构后：提取公共设置
func before_each():
    player = Player.new()
    player.health = 100
    player.position = Vector2.ZERO
    player.movement_speed = 100.0
    add_child_autofree(player)

func test_player_move_right():
    # 直接使用 player，无需重复设置
    # 测试逻辑...

func test_player_move_left():
    # 直接使用 player，无需重复设置
    # 测试逻辑...
```

#### 创建测试辅助函数
```gdscript
# 测试辅助函数
func create_test_player(health: int = 100, position: Vector2 = Vector2.ZERO) -> Player:
    var player = Player.new()
    player.health = health
    player.position = position
    return player

func assert_player_at_position(player: Player, expected: Vector2, tolerance: float = 0.1):
    var distance = player.position.distance_to(expected)
    assert_lt(distance, tolerance, "Player should be at position %s, got %s" % [expected, player.position])

# 使用辅助函数的测试
func test_player_movement_to_target():
    var player = create_test_player(100, Vector2.ZERO)
    add_child_autofree(player)

    var target = Vector2(100, 0)
    player.move_to(target)

    assert_player_at_position(player, target)
```

#### 参数化测试重构
```gdscript
# 重构前：多个相似的测试方法
func test_player_move_right():
    var player = create_test_player()
    player.move_direction(Vector2.RIGHT)
    assert_player_at_position(player, Vector2(100, 0))

func test_player_move_left():
    var player = create_test_player()
    player.move_direction(Vector2.LEFT)
    assert_player_at_position(player, Vector2(-100, 0))

# 重构后：参数化测试
var movement_test_params = [
    [Vector2.RIGHT, Vector2(100, 0)],
    [Vector2.LEFT, Vector2(-100, 0)],
    [Vector2.UP, Vector2(0, -100)],
    [Vector2.DOWN, Vector2(0, 100)]
]

func test_player_movement_in_directions(params = use_parameters(movement_test_params)):
    var direction = params[0]
    var expected_position = params[1]

    var player = create_test_player()
    add_child_autofree(player)

    player.move_direction(direction)
    assert_player_at_position(player, expected_position)
```

### 测试维护最佳实践

#### 保持测试独立性
```gdscript
# ❌ 反模式：测试间依赖
var shared_player: Player

func test_player_initialization():
    shared_player = Player.new()
    shared_player.health = 50  # 影响其他测试

func test_player_full_health():
    # 依赖前一个测试的状态，危险！
    assert_eq(shared_player.health, 100)  # 会失败

# ✅ 正确模式：测试独立
func test_player_initialization():
    var player = Player.new()
    player.health = 50
    assert_eq(player.health, 50)

func test_player_full_health():
    var player = Player.new()  # 创建新的实例
    assert_eq(player.health, 100)
```

#### 测试命名规范
```gdscript
# 好的测试命名：清晰描述测试场景和预期结果
func test_player_takes_damage_and_health_decreases()
func test_player_health_never_goes_below_zero()
func test_player_heals_to_maximum_health_limit()

func test_inventory_adds_item_when_space_available()
func test_inventory_rejects_item_when_full()
func test_inventory_stacks_items_of_same_type()

# 坏的测试命名：模糊不清
func test_player_1()
func test_health_test()
func test_inventory_stuff()
```

## 📊 代码覆盖率分析和质量保证

### 覆盖率目标设定

#### 功能覆盖率
```text
覆盖率分层目标：
- 核心游戏逻辑：100%
- 工具类和辅助函数：95%
- UI 交互逻辑：90%
- 配置和设置：85%
- 错误处理：80%
```

#### 测试类型分布
```text
测试类型比例：
- 单元测试：70% (快速反馈)
- 集成测试：20% (交互验证)
- 端到端测试：10% (完整流程)
```

### 覆盖率分析方法

#### 手动覆盖率检查
```gdscript
# 在测试中添加覆盖率标记注释
func test_player_basic_functionality():
    # 覆盖：Player.__new, Player._ready, Player.set_health
    var player = Player.new()
    assert_eq(player.health, 100)

    # 覆盖：Player.take_damage, Player.health_changed signal
    player.take_damage(30)
    assert_eq(player.health, 70)

    # 覆盖：边界情况 Player.take_damage
    player.take_damage(100)  # 过额伤害
    assert_eq(player.health, 0)  # 不应该为负数

    # 覆盖：Player.heal, Player.is_dead
    player.heal(50)
    assert_eq(player.health, 50)
    assert_false(player.is_dead())
```

#### 覆盖率工具使用
```bash
# 生成覆盖率报告
godot -s addons/gut/gut_cmdln.gd -ginclude_subdirs -gdir=res://test -gjunit_xml_file=test_results.xml -gexit

# 分析覆盖率结果
# 查看哪些函数/分支没有被测试覆盖
# 重点增加缺失的测试用例
```

### 质量保证检查清单

#### 测试质量标准
- [ ] 每个测试只验证一个功能点
- [ ] 测试名称清晰描述测试目的
- [ ] 使用 AAA 模式（Arrange-Act-Assert）
- [ ] 测试数据有代表性
- [ ] 包含边界条件测试
- [ ] 包含错误情况测试
- [ ] 测试快速且稳定
- [ ] 测试间相互独立

#### 代码质量标准
- [ ] 所有分支都有测试覆盖
- [ ] 所有公共接口都有测试
- [ ] 关键算法有充分的测试
- [ ] 错误路径有测试覆盖
- [ ] 性能关键路径有基准测试
- [ ] 内存泄漏有测试检查

## 🚀 TDD 实施建议和常见陷阱

### TDD 实施建议

#### 从小功能开始
1. **选择简单功能**：先从工具类、数据结构开始
2. **建立信心**：通过简单的成功建立 TDD 信心
3. **逐步扩展**：逐步应用到复杂的业务逻辑

#### 保持测试简单
```gdscript
# ✅ 好的测试：简单直接
func test_calculator_addition():
    var calc = Calculator.new()
    var result = calc.add(2, 3)
    assert_eq(result, 5)

# ❌ 复杂的测试：太多逻辑
func test_calculator_comprehensive():
    var calc = Calculator.new()

    # 测试加法
    assert_eq(calc.add(2, 3), 5)

    # 测试减法
    assert_eq(calc.subtract(5, 2), 3)

    # 测试乘法
    assert_eq(calc.multiply(2, 3), 6)

    # 测试除法
    assert_eq(calc.divide(6, 2), 3)

    # 这个测试做了太多事，应该拆分为多个测试
```

#### 定期重构测试
```gdscript
# 定期检查测试是否有重复代码
# 定期检查测试是否仍然相关
# 定期优化测试的可读性
```

### 常见陷阱和解决方案

#### 过度设计
```text
陷阱：在 Green 阶段就开始过度设计
解决：坚持最小实现，在 Refactor 阶段再优化
```

#### 测试覆盖实现细节
```gdscript
# ❌ 测试实现细节（脆弱）
func test_player_internal_velocity():
    var player = Player.new()
    player._velocity = Vector2(100, 0)  # 直接访问内部状态
    player._process(1.0)
    assert_eq(player.position.x, 100)

# ✅ 测试公共接口（稳定）
func test_player_moves_right():
    var player = Player.new()
    player.move_direction(Vector2.RIGHT)
    player._process(1.0)
    assert_eq(player.position.x, 100)
```

#### 测试运行缓慢
```text
陷阱：测试包含大量耗时操作
解决：使用 Double 对象模拟耗时操作，使用轻量级测试数据
```

#### 测试不稳定
```text
陷阱：测试依赖外部状态、网络、文件系统等
解决：使用 Mock 和 Double 隔离外部依赖
```

这个 TDD 工作流程指南提供了完整的 TDD 实施方法论，确保开发者能够系统地进行测试驱动开发，同时保持代码质量和开发效率。