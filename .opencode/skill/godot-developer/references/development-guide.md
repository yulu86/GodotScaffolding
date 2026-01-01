# Godot开发指导

## 场景创建步骤

### 1. 基本场景创建流程
1. 确定场景根节点类型
   - Node: 用于逻辑容器
   - Node2D: 2D场景根节点
   - Node3D: 3D场景根节点
   - Control: UI场景根节点

2. 添加必要的子节点
   - CanvasLayer: UI层管理
   - Camera2D/Camera3D: 视角控制
   - TileMap: 2D关卡地图
   - AudioStreamPlayer: 音频播放

### 2. 节点命名规范
- 使用PascalCase命名节点
- 功能性节点添加前缀：
  - UI节点: UI_ 前缀
  - 碰撞节点: Collision_ 前缀
  - 动画节点: Animation_ 前缀

## 代码实现流程

### 1. 脚本结构
```gdscript
# 文件: scripts/player/player_controller.gd
extends CharacterBody2D
class_name PlayerController

# 导出变量（可在编辑器设置）
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

# 私有变量
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# 信号定义
signal health_changed(new_health: int)
signal player_died

# 节点引用
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _sprite: Sprite2D = $Sprite2D
```

### 2. 生命周期方法
```gdscript
func _ready():
    # 初始化代码
    pass

func _process(delta: float):
    # 每帧处理逻辑
    pass

func _physics_process(delta: float):
    # 物理相关处理
    pass
```

### 3. 信号连接
```gdscript
# 在_ready方法中连接信号
func _ready():
    # 连接内部信号
    _animation_player.animation_finished.connect(_on_animation_finished)

    # 连接外部信号（如果需要）
    # GameState.coin_collected.connect(_on_coin_collected)

func _on_animation_finished(anim_name: String):
    # 处理动画完成事件
    pass
```

## 测试驱动开发

> **重要提示**：详细的 GUT 框架使用指南请参考 [gut-testing-framework.md](./gut-testing-framework.md)，TDD 工作流程请参考 [tdd-workflow-guide.md](./tdd-workflow-guide.md)

### 1. GUT测试框架基础设置

#### 测试文件结构
```gdscript
# 文件: test/unit/test_player_controller.gd
extends GutTest

var player: PlayerController

func before_each():
    # 测试前准备：创建测试对象
    player = PlayerController.new()
    add_child_autofree(player)

func after_each():
    # 测试后清理：重置状态
    if player:
        player.queue_free()
```

#### AAA 测试模式（Arrange-Act-Assert）
```gdscript
func test_player_moves_right_with_correct_velocity():
    # Arrange - 准备测试环境
    player.position = Vector2.ZERO
    player.movement_speed = 200.0

    # Act - 执行被测试的操作
    player.handle_input("move_right", true)
    player._physics_process(0.016)  # 模拟一帧

    # Assert - 验证结果
    assert_gt(player.position.x, 0.0, "Player should move right")
    assert_eq(player.velocity.x, player.movement_speed, "Velocity should match movement speed")
```

### 2. 测试场景和组件测试

#### 场景测试模板
```gdscript
func test_player_scene_initialization():
    # Arrange - 加载场景
    var player_scene = preload("res://scenes/player/player.tscn")
    var player_instance = player_scene.instantiate()
    add_child_autofree(player_instance)

    # Act - 场景已经实例化

    # Assert - 验证场景设置
    assert_not_null(player_instance, "Player scene should instantiate correctly")
    assert_true(player_instance.has_method("take_damage"), "Player should have take_damage method")
    assert_has_method(player_instance, "_physics_process", "Player should have physics processing")
```

#### 组件交互测试
```gdscript
func test_player_weapon_integration():
    # Arrange - 创建玩家和武器
    var player = PlayerController.new()
    var weapon = Weapon.new()
    weapon.damage = 25

    add_child_autofree(player)
    add_child_autofree(weapon)

    # 设置装备关系
    player.equip_weapon(weapon)

    # Act - 玩家攻击
    var test_target = TestTarget.new()
    player.attack(test_target)

    # Assert - 验证武器交互
    assert_eq(test_target.health, 75, "Target should take damage from player's weapon")
    assert_signal_emitted(weapon, "fired")
```

### 3. Mock 和 Double 对象使用

#### 使用 Double 测试组件依赖
```gdscript
func test_player_with_mocked_input():
    # Arrange - 创建带有模拟输入的玩家
    var PlayerClass = preload("res://scripts/PlayerController.gd")
    var player = double(PlayerClass).new()

    # 模拟输入系统
    stub(player, "is_action_pressed").to_return(true, ["move_right"])
    stub(player, "get_action_strength").to_return(1.0, ["move_right"])

    add_child_autofree(player)

    # Act - 执行物理更新
    player._physics_process(0.016)

    # Assert - 验证基于模拟输入的行为
    assert_called(player, "is_action_pressed", ["move_right"])
    assert_gt(player.velocity.x, 0, "Player should move right when input is pressed")
```

#### Partial Double 保留关键行为
```gdscript
func test_weapon_with_partial_double():
    # Arrange - 创建部分双倍的武器
    var WeaponClass = preload("res://scripts/Weapon.gd")
    var weapon = partial_double(WeaponClass).new()

    # 保留原始的 calculate_damage 方法
    # 只模拟 fire 方法的视觉效果
    stub(weapon, "create_muzzle_flash").to_do_nothing()

    add_child_autofree(weapon)

    # Act - 发射武器
    weapon.fire()

    # Assert - 验证原始方法工作，模拟方法被调用
    assert_called(weapon, "create_muzzle_flash")
    assert_true(weapon.is_firing, "Weapon should be in firing state")
```

### 4. 信号测试模式

#### 基础信号测试
```gdscript
func test_health_changed_signal():
    # Arrange - 设置信号监听
    var health_component = HealthComponent.new()
    var signal_received = false
    var received_health = 0

    health_component.health_changed.connect(func(health):
        signal_received = true
        received_health = health
    )

    add_child_autofree(health_component)

    # Act - 改变健康值
    health_component.take_damage(30)

    # Assert - 验证信号发射
    assert_true(signal_received, "Health changed signal should be emitted")
    assert_eq(received_health, 70, "Signal should carry correct health value")
    assert_signal_emitted(health_component, "health_changed", [70])
```

#### 带参数的复杂信号测试
```gdscript
func test_inventory_item_added_signal():
    # Arrange
    var inventory = Inventory.new()
    var item = Item.new()
    item.name = "Health Potion"
    item.quantity = 5

    var signal_data = null
    inventory.item_added.connect(func(item_data, slot):
        signal_data = {item = item_data, slot = slot}
    )

    add_child_autofree(inventory)

    # Act
    var success = inventory.add_item(item)

    # Assert
    assert_true(success, "Item should be added successfully")
    assert_not_null(signal_data, "Signal data should be received")
    assert_eq(signal_data.item.name, "Health Potion")
    assert_eq(signal_data.item.quantity, 5)
    assert_signal_emitted_with_parameters(inventory, "item_added", [item, 0])
```

### 5. 参数化测试和数据驱动测试

#### 使用参数数组测试多种情况
```gdscript
# 测试数据：[输入伤害, 预期剩余健康, 是否应该死亡]
var damage_test_params = [
    [10, 90, false],  # 小额伤害
    [50, 50, false],  # 中等伤害
    [100, 0, true],   # 致命伤害
    [150, 0, true]    # 过额伤害
]

func test_player_takes_damage(params = use_parameters(damage_test_params)):
    # Arrange
    var player = PlayerController.new()
    player.health = 100
    var damage = params[0]
    var expected_health = params[1]
    var should_die = params[2]

    add_child_autofree(player)

    # Act
    player.take_damage(damage)

    # Assert
    assert_eq(player.health, expected_health, "Health should be %d after %d damage" % [expected_health, damage])
    assert_eq(player.is_dead(), should_die, "Player death state should be %s" % should_die)

    if should_die:
        assert_signal_emitted(player, "player_died")
```

#### 命名参数提高可读性
```gdscript
var movement_params = ParameterFactory.named_parameters(
    ['direction', 'expected_x_change', 'expected_y_change'],
    [
        [Vector2.RIGHT, 10.0, 0.0],
        [Vector2.LEFT, -10.0, 0.0],
        [Vector2.UP, 0.0, -10.0],
        [Vector2.DOWN, 0.0, 10.0]
    ]
)

func test_player_movement_in_directions(params = use_parameters(movement_params)):
    # Arrange
    var player = PlayerController.new()
    player.position = Vector2.ZERO
    player.movement_speed = 10.0

    add_child_autofree(player)

    # Act
    player.move_in_direction(params.direction)
    player._process(1.0)

    # Assert
    assert_eq(player.position.x, params.expected_x_change)
    assert_eq(player.position.y, params.expected_y_change)
```

### 6. 异步测试和时间相关测试

#### 使用 wait_for_signal 测试异步操作
```gdscript
func test_async_level_loading():
    # Arrange
    var level_loader = LevelLoader.new()
    add_child(level_loader)

    var level_path = "res://scenes/test_level.tscn"

    # Act - 开始异步加载
    level_loader.load_level_async(level_path)

    # Assert - 等待加载完成
    await wait_for_signal(level_loader, "level_loaded", 5.0)

    assert_true(level_loader.is_level_loaded, "Level should be loaded")
    assert_not_null(level_loader.get_loaded_scene(), "Loaded scene should not be null")
```

#### 时间相关的测试
```gdscript
func test_timer_functionality():
    # Arrange
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.one_shot = true

    var timer_expired = false
    timer.timeout.connect(func(): timer_expired = true)

    add_child_autofree(timer)

    # Act
    timer.start()

    # 模拟时间流逝
    await get_tree().create_timer(1.1).timeout

    # Assert
    assert_true(timer_expired, "Timer should expire after wait time")
    assert_false(timer.time_left > 0, "Timer should be stopped")
```

### 7. 性能测试和基准测试

#### 简单性能测试
```gdscript
func test_pathfinding_performance():
    # Arrange
    var pathfinder = Pathfinder.new()
    var grid_size = 100
    var start_pos = Vector2i(0, 0)
    var end_pos = Vector2i(grid_size - 1, grid_size - 1)

    # 设置测试网格
    pathfinder.setup_grid(grid_size, grid_size)

    # Act & Measure
    reset_start_times()
    var path = pathfinder.find_path(start_pos, end_pos)
    var elapsed_time = get_elapsed_test_time()

    # Assert
    assert_not_null(path, "Path should be found")
    assert_lt(elapsed_time, 0.1, "Pathfinding should complete within 100ms")
    assert_true(path.size() > 0, "Path should contain waypoints")
```

### 8. 错误处理和边界条件测试

#### 测试异常情况处理
```gdscript
func test_inventory_full_error_handling():
    # Arrange
    var inventory = Inventory.new()
    inventory.capacity = 2

    # 添加物品直到满容量
    inventory.add_item(Item.new())
    inventory.add_item(Item.new())

    var extra_item = Item.new()

    # Act
    var result = inventory.add_item(extra_item)

    # Assert
    assert_false(result.success, "Adding to full inventory should fail")
    assert_eq(result.error_code, "INVENTORY_FULL", "Should return appropriate error")
    assert_eq(inventory.get_item_count(), 2, "Inventory size should remain unchanged")
```

#### 数值边界测试
```gdscript
func test_health_clamping():
    # Arrange
    var player = PlayerController.new()
    player.max_health = 100

    # Test lower boundary
    player.health = -50
    player.take_damage(100)
    assert_eq(player.health, 0, "Health should not go below 0")

    # Test upper boundary
    player.health = 200
    player.heal(50)
    assert_eq(player.health, player.max_health, "Health should not exceed maximum")
```

这些详细的测试示例展示了如何使用 GUT 框架进行全面的 TDD 开发，覆盖了从基础功能测试到复杂交互测试的各种场景。

## 最佳实践

### 1. 性能优化
- 使用 `_process` 处理每帧更新
- 使用 `_physics_process` 处理物理相关
- 避免在 `_process` 中进行重量级计算
- 使用对象池管理频繁创建销毁的对象

### 2. 代码组织
- 按功能模块划分脚本
- 使用自动加载（Singleton）管理全局状态
- 通过信号解耦模块间依赖
- 使用组（groups）管理同类型节点

### 3. 调试技巧
- 使用 `print()` 输出调试信息
- 使用 `assert()` 进行断言检查
- 利用Godot的调试器进行断点调试
- 使用远程调试查看运行时状态