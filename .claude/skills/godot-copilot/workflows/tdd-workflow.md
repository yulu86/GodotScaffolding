# TDD（测试驱动开发）工作流程

## 概述

本文档描述了在Godot项目中使用TDD（测试驱动开发）的详细工作流程。TDD是一种软件开发方法，通过先编写测试用例来驱动代码的开发。

## TDD循环：红-绿-重构

### 1. 红灯阶段（Red）- 编写失败的测试

**目标**：编写一个描述期望行为的测试，并确认测试失败。

**步骤**：
1. **创建或打开测试文件**
   ```gdscript
   # 位置：test/unit/player/test_player_controller.gd
   extends "res://addons/gut/test.gd"
   ```

2. **编写测试用例**
   ```gdscript
   func test_player_should_start_with_full_health():
       var player = PlayerController.new()
       assert_eq(player.current_health, player.max_health,
           "Player should start with max health")
   ```

3. **运行测试并确认失败**
   - 在Godot编辑器中运行GUT测试
   - 确认测试失败（红灯）
   - 这证明了测试能正确检测功能缺失

**重要提醒**：
- 不要编写任何实现代码
- 测试失败是预期的，证明测试有效
- 测试名称应清楚描述被测试的行为

### 2. 绿灯阶段（Green）- 编写最小实现

**目标**：编写最简单的代码使测试通过。

**步骤**：
1. **编写最小可行代码**
   ```gdscript
   # 在PlayerController.gd中
   class_name PlayerController
   extends CharacterBody2D

   @export var max_health: int = 3
   var current_health: int

   func _ready():
       current_health = max_health
   ```

2. **运行测试确认通过**
   - 运行GUT测试
   - 确认测试通过（绿灯）

**原则**：
- 只编写刚好能让测试通过的代码
- 不添加额外功能
- 保持代码简单直接

### 3. 重构阶段（Refactor）- 优化代码

**目标**：改进代码质量，同时保持测试通过。

**步骤**：
1. **审查代码**
   - 检查代码是否清晰
   - 识别重复代码
   - 应用设计模式

2. **重构实现**
   ```gdscript
   class_name PlayerController
   extends CharacterBody2D

   @export var max_health: int = 3:
       set(value):
           max_health = value
           if not _is_initialized:
               current_health = max_health

   var current_health: int
   var _is_initialized: bool = false

   func _ready():
       _is_initialized = true
       reset_health()

   func reset_health():
       current_health = max_health
   ```

3. **持续运行测试**
   - 每次重构后运行测试
   - 确保测试仍然通过
   - 如果测试失败，撤销更改

## 完整TDD流程示例

### 功能需求：玩家可以跳跃

#### 步骤1：红灯 - 编写跳跃测试

```gdscript
# test/unit/player/test_player_controller.gd
func test_player_can_jump_when_on_ground():
    var player = PlayerController.new()
    player.is_on_floor = true  # 模拟在地面
    player.jump()
    assert_true(player.velocity.y < 0,
        "Player should have upward velocity after jump")

func test_player_cannot_jump_when_in_air():
    var player = PlayerController.new()
    player.is_on_floor = false  # 模拟在空中
    var initial_velocity = player.velocity.y
    player.jump()
    assert_eq(player.velocity.y, initial_velocity,
        "Player should not jump when already in air")
```

运行测试 → 失败（因为没有jump方法）

#### 步骤2：绿灯 - 实现跳跃功能

```gdscript
# PlayerController.gd
func jump():
    if is_on_floor():
        velocity.y = jump_velocity
```

运行测试 → 通过

#### 步骤3：重构 - 改进代码

```gdscript
# PlayerController.gd
func jump() -> bool:
    if not is_on_floor():
        return false

    velocity.y = jump_velocity
    jump_performed.emit()
    animation_player.play("jump")
    return true
```

运行测试 → 仍然通过

## 测试组织结构

### 目录结构
```
test/
├── unit/           # 单元测试
│   ├── player/
│   │   ├── test_player_controller.gd
│   │   └── test_player_health.gd
│   ├── enemy/
│   └── ui/
├── integration/    # 集成测试
│   ├── test_scenes.gd
│   └── test_systems.gd
└── test_suite.gd   # 测试套件
```

### 测试命名规范
- 测试文件：`test_[类名].gd`
- 测试方法：`test_[场景]_[期望行为]`
- 示例：`test_player_should_take_damage_correctly`

## 常见测试模式

### 1. 状态测试
```gdscript
func test_health_decreases_when_taking_damage():
    player.take_damage(1)
    assert_eq(player.current_health, 2)
```

### 2. 行为测试
```gdscript
func test_emits_signal_when_dies():
    player.die()
    assert_signal_emitted(player, "player_died")
```

### 3. 交互测试
```gdscript
func test_player_can_collect_coin():
    var coin = Coin.new()
    player.collect(coin)
    assert_eq(player.coins, 1)
```

## GUT测试框架使用技巧

### 1. 使用before_each和after_each
```gdscript
func before_each():
    player = PlayerController.new()
    add_child_autofree(player)

func after_each():
    # 清理资源
```

### 2. 参数化测试
```gdscript
func test_movement_with_different_inputs():
    var test_cases = [
        {"input": Vector2.LEFT, "expected": Vector2.LEFT * speed},
        {"input": Vector2.RIGHT, "expected": Vector2.RIGHT * speed},
    ]

    for case in test_cases:
        player.move(case.input)
        assert_eq(player.velocity, case.expected)
```

### 3. 模拟和存根
```gdscript
func test_player_uses_input_manager():
    var input_manager = InputManager.new()
    input_manager.simulate_action("ui_accept")
    player.input_manager = input_manager

    player._process(0.016)
    assert_true(player.is_jumping)
```

## 最佳实践

1. **小步快跑**：每个测试只验证一个行为
2. **描述性命名**：测试名称应清楚表达意图
3. **独立性**：测试之间不应有依赖
4. **快速反馈**：保持测试快速运行
5. **持续重构**：定期改进测试代码

## 常见错误和解决方案

### 错误1：测试过于复杂
**问题**：一个测试验证多个功能
**解决**：拆分成多个独立的测试

### 错误2：测试依赖实现细节
**问题**：测试知道太多内部实现
**解决**：测试公共接口和行为

### 错误3：忘记重构
**问题**：测试通过后直接进入下一个功能
**解决**：给重构留出专门时间

## 集成到工作流

1. **功能开发前**：先编写测试
2. **开发过程中**：持续运行测试
3. **提交前**：确保所有测试通过
4. **代码审查**：包含测试的审查
5. **持续集成**：自动运行测试套件

通过遵循这个TDD工作流程，你可以创建更可靠、更易维护的Godot游戏代码。