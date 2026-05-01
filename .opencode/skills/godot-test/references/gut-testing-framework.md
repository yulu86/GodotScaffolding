# GUT 测试框架完整指南

> **重要提示**：本文档专注于 GUT 框架的使用方法和最佳实践，不包含安装配置指导。如需安装指南，请参考项目文档。

## 📋 GUT 框架概述

GUT (Godot Unit Test) 是 Godot 的官方单元测试框架，允许开发者用 GDScript 编写和运行测试。它是 TDD 开发流程的核心工具。

### 核心特性
- **纯 GDScript 语法**：无需学习新语言，使用熟悉的 GDScript 编写测试
- **完整的断言库**：提供丰富的断言方法验证预期结果
- **Mock 和 Double 支持**：强大的对象模拟功能，支持依赖注入和隔离测试
- **参数化测试**：支持多组数据驱动的测试用例
- **信号测试**：专门针对 Godot 信号系统的测试支持
- **性能测试**：内置性能分析和基准测试功能

## 🏗️ 测试项目结构规范

### 推荐的测试目录组织
```
res://test/
├── unit/                    # 单元测试 (70%)
│   ├── components/         # 组件测试
│   ├── systems/           # 系统逻辑测试
│   ├── utilities/         # 工具类测试
│   └── data/              # 数据模型测试
├── integration/            # 集成测试 (20%)
│   ├── scenes/            # 场景集成测试
│   ├── workflows/         # 工作流测试
│   └── systems/           # 系统间集成测试
├── test_helper.gd          # 测试辅助类和工具函数
├── test_data/              # 测试数据和资源
└── mocks/                  # Mock 对象定义
```

### 测试文件命名规范
- **测试文件**: 使用 `test_` 前缀，如 `test_player_controller.gd`
- **测试类**: 继承 `GutTest`，使用描述性命名
- **测试方法**: 使用 `test_` 前缀，描述被测试的功能和预期结果

## 🔧 核心断言方法参考

### 基础断言
```gdscript
# 相等性断言
assert_eq(actual, expected, [optional_message])
assert_ne(actual, unexpected, [optional_message])

# 数值比较断言
assert_gt(actual, expected, [optional_message])  # greater than
assert_gte(actual, expected, [optional_message]) # greater than or equal
assert_lt(actual, expected, [optional_message])  # less than
assert_lte(actual, expected, [optional_message]) # less than or equal

# 布尔断言
assert_true(condition, [optional_message])
assert_false(condition, [optional_message])

# 空值断言
assert_null(value, [optional_message])
assert_not_null(value, [optional_message])
```

### 字符串和文本断言
```gdscript
# 字符串包含
assert_string_contains(text, substring, [optional_message])
assert_string_does_not_contain(text, substring, [optional_message])

# 字符串开始和结束
assert_string_starts_with(text, prefix, [optional_message])
assert_string_ends_with(text, suffix, [optional_message])
```

### 数组和集合断言
```gdscript
# 数组包含
assert_array_has(array, element, [optional_message])
assert_array_does_not_have(array, element, [optional_message])

# 数组大小
assert_array_size(array, expected_size, [optional_message])

# 字典键值
assert_dict_has_key(dictionary, key, [optional_message])
assert_dict_has_value(dictionary, value, [optional_message])
```

### 对象和方法断言
```gdscript
# 类型检查
assert_typeof(value, expected_type, [optional_message])

# 方法存在性
assert_has_method(object, method_name, [optional_message])

# 信号存在性
assert_has_signal(object, signal_name, [optional_message])
```

## 🎭 Mock 和 Double 对象使用

### 完整 Double (Full Double)
完全模拟一个对象，所有方法都被替换为桩代码：

```gdscript
func test_player_with_full_double():
    var PlayerClass = preload("res://scripts/Player.gd")
    var double_player = double(PlayerClass).new()

    # 模拟方法返回值
    stub(double_player, "get_health").to_return(150)
    assert_eq(double_player.get_health(), 150)

    # 验证方法调用
    double_player.take_damage(50)
    assert_called(double_player, "take_damage", [50])

    # 检查调用次数
    assert_call_count(double_player, "get_health", 1)
```

### 部分 Double (Partial Double)
保留原始方法的实现，只模拟特定方法：

```gdscript
func test_weapon_with_partial_double():
    var WeaponClass = preload("res://scripts/Weapon.gd")
    var partial_double = partial_double(WeaponClass).new()

    # 保留原始 calculate_damage 方法
    # 只模拟 fire 方法
    stub(partial_double, "fire").to_do_nothing()

    # 原始方法仍然正常工作
    var damage = partial_double.calculate_damage()
    assert_gt(damage, 0)

    # 模拟方法按预期工作
    partial_double.fire()
    assert_called(partial_double, "fire")
```

### 方法存根 (Method Stubs)
```gdscript
# 返回固定值
stub(double_obj, "get_status").to_return("ready")

# 返回序列值
stub(double_obj, "get_next_id").to_return([1, 2, 3])

# 抛出错误
stub(double_obj, "validate").to_call_super()

# 执行自定义逻辑
stub(double_obj, "calculate").to_call(func(x, y): return x * y)
```

## 📊 参数化测试和性能测试

### 参数化测试
使用多组数据运行同一个测试逻辑：

```gdscript
extends GutTest

# 简单参数数组
var add_params = [
    [1, 2, 3],      # 1 + 2 = 3
    [5, 10, 15],    # 5 + 10 = 15
    [-1, 1, 0],     # -1 + 1 = 0
    [0, 0, 0]       # 0 + 0 = 0
]

func test_addition(params = use_parameters(add_params)):
    var calc = Calculator.new()
    var result = calc.add(params[0], params[1])
    assert_eq(result, params[2], "Addition should work correctly")

# 命名参数（更清晰）
var calc_params = ParameterFactory.named_parameters(
    ['a', 'b', 'expected'],
    [
        [2, 3, 6],      # 2 * 3 = 6
        [4, 5, 20],     # 4 * 5 = 20
        [0, 7, 0],      # 0 * 7 = 0
        [-2, 3, -6]     # -2 * 3 = -6
    ]
)

func test_multiplication(params = use_parameters(calc_params)):
    var calc = Calculator.new()
    var result = calc.multiply(params.a, params.b)
    assert_eq(result, params.expected, "Multiplication should work correctly")
```

### 性能测试
```gdscript
func test_algorithm_performance():
    var array_size = 1000
    var test_array = []

    # 生成测试数据
    for i in range(array_size):
        test_array.append(randf())

    # 重置时间追踪
    reset_start_times()

    # 执行被测试的算法
    var result = some_sorting_algorithm(test_array)

    # 检查执行时间（假设排序应该在100ms内完成）
    assert_lt(get_elapsed_test_time(), 0.1, "Sorting should complete within 100ms")

    # 验证结果正确性
    assert_true(is_array_sorted(result), "Array should be sorted")
    assert_eq(result.size(), array_size, "Array size should be preserved")
```

## 📡 信号测试方法

### 基础信号测试
```gdscript
extends GutTest

var signal_received: bool = false
var signal_data: Variant = null

func before_each():
    signal_received = false
    signal_data = null

func test_signal_emission():
    var button = Button.new()
    add_child(button)

    # 连接信号监听器
    button.pressed.connect(_on_button_pressed)

    # 模拟按钮点击
    button.emit_signal("pressed")

    # 验证信号发射
    assert_signal_emitted(button, "pressed")
    assert_signal_emit_count(button, "pressed", 1)
    assert_true(signal_received, "Signal callback should be called")

func _on_button_pressed():
    signal_received = true
```

### 带参数的信号测试
```gdscript
func test_health_changed_signal():
    var health_component = preload("res://scripts/HealthComponent.gd").new()
    add_child(health_component)

    # 连接信号监听器
    health_component.health_changed.connect(_on_health_changed)

    # 触发信号
    health_component.take_damage(25)

    # 验证信号和参数
    assert_signal_emitted_with_parameters(health_component, "health_changed", [75, 100])
    assert_eq(signal_data.current, 75)
    assert_eq(signal_data.maximum, 100)

func _on_health_changed(current, maximum):
    signal_data = {current = current, maximum = maximum}
```

### 信号连接测试
```gdscript
func test_signal_connections():
    var emitter = SignalEmitter.new()
    var receiver = SignalReceiver.new()

    add_child(emitter)
    add_child(receiver)

    # 验证信号存在
    assert_has_signal(emitter, "data_updated")

    # 连接信号
    emitter.data_updated.connect(receiver.handle_data)

    # 验证信号连接
    assert_signal_is_connected(emitter, "data_updated", receiver, "handle_data")

    # 发射信号并验证接收者收到
    var test_data = {"value": 42}
    emitter.emit_signal("data_updated", test_data)

    assert_eq(receiver.last_received_data, test_data)
```

## 🔄 测试生命周期管理

### 生命周期方法
GUT 提供了完整的测试生命周期钩子：

```gdscript
extends GutTest

var test_resources: Array[Node] = []
var shared_data: Dictionary = {}

func before_all():
    """在整个测试套件运行前执行一次"""
    shared_data["config"] = load_test_config()
    print("Setting up test suite")

func before_each():
    """在每个测试方法前执行"""
    setup_test_environment()
    test_resources.clear()

func after_each():
    """在每个测试方法后执行"""
    cleanup_test_resources()
    reset_test_state()

func after_all():
    """在整个测试套件运行后执行一次"""
    shared_data.clear()
    print("Cleaning up test suite")
```

### 资源管理技巧
```gdscript
# 自动清理资源
func before_each():
    var test_node = Node.new()
    add_child_autofree(test_node)  # 测试结束后自动释放

    var test_object = TestClass.new()
    autofree(test_object)          # 对象自动释放

# 使用 after_each 手动清理
var temp_files: Array[String] = []

func test_file_operations():
    var temp_file = "temp_test_file.dat"
    temp_files.append(temp_file)

    # 执行文件操作...
    pass

func after_each():
    # 清理临时文件
    for file_path in temp_files:
        if FileAccess.file_exists(file_path):
            DirAccess.remove_absolute(file_path)
    temp_files.clear()
```

## 🧪 测试数据构建

### 测试工厂模式
```gdscript
# 测试数据工厂
class TestPlayerFactory:
    static func create_player(health: int = 100, position: Vector2 = Vector2.ZERO) -> Player:
        var player = Player.new()
        player.health = health
        player.position = position
        player.max_health = health
        return player

    static func create_weak_player() -> Player:
        return create_player(25)

    static func create_full_health_player() -> Player:
        return create_player(100)

# 在测试中使用
func test_player_initialization():
    var player = TestPlayerFactory.create_full_health_player()
    assert_eq(player.health, 100)
    assert_eq(player.position, Vector2.ZERO)

func test_weak_player_behavior():
    var player = TestPlayerFactory.create_weak_player()
    assert_lt(player.health, 50)
```

### 测试场景准备
```gdscript
func create_test_scene() -> Node:
    var scene = Node.new()
    scene.name = "TestScene"

    # 添加测试组件
    var player = TestPlayerFactory.create_player()
    player.name = "Player"
    scene.add_child(player)

    var enemy = Enemy.new()
    enemy.name = "Enemy"
    enemy.position = Vector2(100, 0)
    scene.add_child(enemy)

    return scene

func test_scene_setup():
    var test_scene = create_test_scene()
    add_child_autofree(test_scene)

    var player = test_scene.get_node("Player")
    var enemy = test_scene.get_node("Enemy")

    assert_not_null(player)
    assert_not_null(enemy)
    assert_eq(enemy.position.distance_to(player.position), 100)
```

## 📝 高级测试技巧

### 测试异常和错误处理
```gdscript
func test_invalid_input_handling():
    var validator = InputValidator.new()

    # 测试空输入
    var result = validator.validate("")
    assert_false(result.is_valid)
    assert_eq(result.error_code, "EMPTY_INPUT")

    # 测试无效字符
    result = validator.validate("test@#$")
    assert_false(result.is_valid)
    assert_eq(result.error_code", "INVALID_CHARACTERS")
```

### 异步测试
```gdscript
func test_async_operation():
    var async_loader = AsyncLoader.new()
    add_child(async_loader)

    # 开始异步操作
    async_loader.start_load("res://test_data.json")

    # 等待操作完成
    await wait_for_signal(async_loader, "load_completed", 2.0)

    # 验证结果
    assert_true(async_loader.is_loaded)
    assert_not_null(async_loader.data)

    # 超时检查
    if not async_loader.is_loaded:
        fail("Async operation timed out")
```

### 内存和性能测试
```gdscript
func test_memory_usage():
    var initial_memory = OS.get_static_memory_usage_by_type()[0]

    # 执行可能消耗内存的操作
    var objects = []
    for i in range(1000):
        objects.append(HeavyObject.new())

    var peak_memory = OS.get_static_memory_usage_by_type()[0]

    # 验证内存使用在预期范围内
    var memory_increase = peak_memory - initial_memory
    assert_lt(memory_increase, 50 * 1024 * 1024, "Memory increase should be less than 50MB")

    # 清理
    for obj in objects:
        obj.queue_free()
```

## 🚀 常见测试模式和反模式

### ✅ 推荐的测试模式

1. **AAA 模式** (Arrange-Act-Assert)
```gdscript
func test_player_takes_damage():
    # Arrange - 准备测试数据和环境
    var player = TestPlayerFactory.create_player(100)
    var damage_amount = 25

    # Act - 执行被测试的操作
    player.take_damage(damage_amount)

    # Assert - 验证结果
    assert_eq(player.health, 75, "Player health should decrease by damage amount")
    assert_signal_emitted(player, "health_changed")
```

2. **测试数据隔离**
```gdscript
func test_with_isolated_data():
    # 使用局部变量，避免测试间共享状态
    var test_data = {"input": "test", "expected": "result"}
    var processor = DataProcessor.new()

    var result = processor.process(test_data.input)
    assert_eq(result, test_data.expected)
```

3. **边界条件测试**
```gdscript
func test_health_boundaries():
    var player = TestPlayerFactory.create_player(100)

    # 测试最小值边界
    player.take_damage(200)  # 超额伤害
    assert_eq(player.health, 0, "Health should not go below 0")

    # 测试最大值边界
    player.heal(999)  # 超额治疗
    assert_eq(player.health, player.max_health, "Health should not exceed maximum")
```

### ❌ 避免的反模式

1. **测试间依赖**
```gdscript
# 反模式：测试依赖全局状态
var global_player: Player

func test_player_initialization():
    global_player = Player.new()  # 修改全局状态

func test_player_movement():
    # 依赖前一个测试的设置 - 危险！
    global_player.move_right()
```

2. **过度复杂的测试**
```gdscript
# 反模式：一个测试验证太多功能
func test_complete_gameplay():
    # 包含初始化、输入处理、物理计算、UI更新...太复杂
    pass
```

3. **测试实现细节**
```gdscript
# 反模式：测试私有实现而非公共行为
func test_internal_state_variable():
    # 直接访问私有变量 - 脆弱的测试
    assert_eq(player._internal_state, "some_value")
```

这个 GUT 测试框架指南为 godot-developer 技能提供了全面的测试工具使用指导，从基础断言到高级测试模式，确保开发者能够有效地实施 TDD 开发流程。