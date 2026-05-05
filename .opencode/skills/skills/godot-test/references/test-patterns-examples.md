# 测试模式与代码示例

> **重要提示**：本文档提供可直接使用的测试模式模板和示例。所有示例都基于实际游戏开发场景，可以直接应用到项目中。

## 📋 标准测试模板

### 基础单元测试模板

#### 简单功能测试模板
```gdscript
# test/unit/test_calculator.gd
extends GutTest

var calculator: Calculator

func before_each():
    # 创建测试对象
    calculator = Calculator.new()
    add_child_autofree(calculator)

func after_each():
    # 清理资源（如果有）
    pass

# 基础功能测试
func test_addition_with_positive_numbers():
    # Arrange - 准备测试数据
    var a = 5
    var b = 3
    var expected = 8

    # Act - 执行被测试的操作
    var result = calculator.add(a, b)

    # Assert - 验证结果
    assert_eq(result, expected, "5 + 3 should equal 8")

func test_addition_with_negative_numbers():
    # Arrange
    var a = -5
    var b = 3
    var expected = -2

    # Act
    var result = calculator.add(a, b)

    # Assert
    assert_eq(result, expected, "-5 + 3 should equal -2")

func test_addition_with_zero():
    # Arrange
    var a = 10
    var b = 0
    var expected = 10

    # Act
    var result = calculator.add(a, b)

    # Assert
    assert_eq(result, expected, "10 + 0 should equal 10")
```

#### 边界条件测试模板
```gdscript
func test_health_boundaries():
    var player = Player.new()
    player.max_health = 100

    # 测试下边界：健康值不能为负
    player.health = -50
    assert_eq(player.health, 0, "Health should be clamped to minimum 0")

    # 测试上边界：健康值不能超过最大值
    player.health = 150
    assert_eq(player.health, player.max_health, "Health should be clamped to maximum")

    # 测试边界值 0
    player.health = 0
    player.take_damage(10)
    assert_eq(player.health, 0, "Health should remain 0 when already at minimum")

    # 测试边界值 max_health
    player.health = player.max_health
    player.heal(10)
    assert_eq(player.health, player.max_health, "Health should remain at maximum")
```

### 异常处理测试模板

#### 错误情况测试
```gdscript
func test_invalid_input_handling():
    var validator = InputValidator.new()

    # 测试空输入
    var result = validator.validate_name("")
    assert_false(result.is_valid, "Empty name should be invalid")
    assert_eq(result.error_code, "EMPTY_INPUT", "Should return empty input error")

    # 测试无效字符
    result = validator.validate_name("Player@#")
    assert_false(result.is_valid, "Name with special characters should be invalid")
    assert_eq(result.error_code, "INVALID_CHARACTERS", "Should return invalid characters error")

    # 测试过长名称
    var long_name = "a".repeat(100)
    result = validator.validate_name(long_name)
    assert_false(result.is_valid, "Very long name should be invalid")
    assert_eq(result.error_code, "NAME_TOO_LONG", "Should return name too long error")

    # 测试有效输入
    result = validator.validate_name("ValidPlayer123")
    assert_true(result.is_valid, "Valid name should be accepted")
```

#### 资源不足测试
```gdscript
func test_insufficient_resources():
    var player = Player.new()
    player.gold = 50

    var item = Item.new()
    item.cost = 100

    # 尝试购买金钱不足的物品
    var result = player.purchase_item(item)
    assert_false(result.success, "Should not be able to purchase with insufficient gold")
    assert_eq(result.error_code, "INSUFFICIENT_GOLD", "Should return insufficient gold error")
    assert_eq(player.gold, 50, "Gold should remain unchanged")

    # 测试刚好足够的金钱
    player.gold = item.cost
    result = player.purchase_item(item)
    assert_true(result.success, "Should be able to purchase with exact gold")
    assert_eq(player.gold, 0, "Gold should be reduced to zero")
```

## 🎮 游戏对象测试模式

### 玩家控制器测试

#### 移动系统测试
```gdscript
extends GutTest

var player: PlayerController
var input_system: InputSystem

func before_each():
    player = PlayerController.new()
    input_system = InputSystem.new()

    # 设置测试环境
    player.position = Vector2.ZERO
    player.movement_speed = 200.0
    player.input_system = input_system

    add_child_autofree(player)
    add_child_autofree(input_system)

func test_player_movement_in_four_directions():
    # 测试向右移动
    input_system.simulate_action("move_right", true)
    player._physics_process(0.1)  # 100ms
    assert_gt(player.position.x, 0, "Player should move right")
    assert_eq(player.position.y, 0, "Player should not move vertically")

    # 重置位置
    player.position = Vector2.ZERO

    # 测试向左移动
    input_system.simulate_action("move_right", false)
    input_system.simulate_action("move_left", true)
    player._physics_process(0.1)
    assert_lt(player.position.x, 0, "Player should move left")

    # 测试向上移动
    player.position = Vector2.ZERO
    input_system.simulate_action("move_left", false)
    input_system.simulate_action("move_up", true)
    player._physics_process(0.1)
    assert_lt(player.position.y, 0, "Player should move up")

    # 测试向下移动
    player.position = Vector2.ZERO
    input_system.simulate_action("move_up", false)
    input_system.simulate_action("move_down", true)
    player._physics_process(0.1)
    assert_gt(player.position.y, 0, "Player should move down")

func test_player_movement_speed_calculation():
    var test_time = 1.0  # 1秒
    var expected_distance = player.movement_speed * test_time

    input_system.simulate_action("move_right", true)
    player._physics_process(test_time)

    assert_eq(abs(player.position.x), expected_distance, "Player should move speed * time distance")

func test_player_diagonal_movement():
    input_system.simulate_action("move_right", true)
    input_system.simulate_action("move_up", true)
    player._physics_process(1.0)

    # 对角线移动时，X和Y方向的速度应该相等
    assert_eq(abs(player.position.x), abs(player.position.y), "Diagonal movement should be equal in X and Y")

    # 对角线移动速度应该是正常速度的 sqrt(2)/2
    var diagonal_speed = player.movement_speed * 0.7071  # sqrt(2)/2
    var distance = sqrt(player.position.x * player.position.x + player.position.y * player.position.y)
    assert_almost_eq(distance, diagonal_speed, 0.1, "Diagonal speed should be normalized")
```

#### 战斗系统测试
```gdscript
func test_player_attack_sequence():
    var weapon = Weapon.new()
    weapon.damage = 25
    weapon.attack_speed = 1.0  # 每秒1次攻击

    player.equip_weapon(weapon)
    var test_target = TestTarget.new()
    test_target.health = 100

    # 模拟攻击
    player.attack(test_target)

    # 验证攻击效果
    assert_eq(test_target.health, 75, "Target should take damage from weapon")
    assert_signal_emitted(weapon, "fired")
    assert_signal_emitted(weapon, "damage_dealt", [25])

func test_attack_cooldown():
    var weapon = Weapon.new()
    weapon.attack_speed = 2.0  # 每秒0.5次攻击
    player.equip_weapon(weapon)

    var test_target = TestTarget.new()
    test_target.health = 100

    # 第一次攻击应该成功
    var result1 = player.attack(test_target)
    assert_true(result1, "First attack should succeed")

    # 立即第二次攻击应该失败（冷却时间）
    var result2 = player.attack(test_target)
    assert_false(result2, "Second attack should fail due to cooldown")

    # 等待冷却时间后攻击应该成功
    player._process(2.1)  # 稍微超过冷却时间
    var result3 = player.attack(test_target)
    assert_true(result3, "Attack should succeed after cooldown")
```

### 敌人AI测试模式

#### 行为树测试
```gdscript
extends GutTest

var enemy: EnemyAI
var player: PlayerController

func before_each():
    enemy = EnemyAI.new()
    player = PlayerController.new()
    player.position = Vector2(100, 0)

    add_child_autofree(enemy)
    add_child_autofree(player)

func test_enemy_patrol_behavior():
    # 设置巡逻点
    var patrol_points = [Vector2(0, 0), Vector2(100, 0), Vector2(0, 100)]
    enemy.set_patrol_points(patrol_points)
    enemy.set_state(EnemyAI.State.PATROL)

    # 模拟一段时间的行为
    for i in range(100):
        enemy._process(0.016)

    # 验证敌人在巡逻点附近
    var is_near_patrol_point = false
    for point in patrol_points:
        if enemy.position.distance_to(point) < 10:
            is_near_patrol_point = true
            break

    assert_true(is_near_patrol_point, "Enemy should be near patrol points")

func test_enemy_chase_behavior():
    enemy.set_state(EnemyAI.State.CHASE)
    enemy.set_target(player)

    var initial_distance = enemy.position.distance_to(player.position)

    # 模拟追逐行为
    for i in range(100):
        enemy._process(0.016)

    var final_distance = enemy.position.distance_to(player.position)

    # 敌人应该向玩家靠近
    assert_lt(final_distance, initial_distance, "Enemy should move closer to player")
    assert_lt(final_distance, 20, "Enemy should be close to player after chasing")
```

### 物品和库存系统测试

#### 物品系统测试
```gdscript
extends GutTest

var inventory: Inventory
var sword: WeaponItem
var potion: HealthPotionItem

func before_each():
    inventory = Inventory.new()
    inventory.capacity = 10

    sword = WeaponItem.new()
    sword.name = "Iron Sword"
    sword.damage = 15
    sword.weight = 5.0

    potion = HealthPotionItem.new()
    potion.name = "Health Potion"
    potion.heal_amount = 25
    potion.weight = 0.5

    add_child_autofree(inventory)

func test_add_item_to_empty_inventory():
    var result = inventory.add_item(sword)

    assert_true(result.success, "Should add item to empty inventory")
    assert_eq(inventory.get_item_count(), 1, "Inventory should have 1 item")
    assert_eq(inventory.get_item_at(0), sword, "Sword should be at slot 0")
    assert_signal_emitted(inventory, "item_added", [sword, 0])

func test_add_item_to_full_inventory():
    # 填满库存
    for i in range(inventory.capacity):
        var item = Item.new()
        inventory.add_item(item)

    # 尝试添加更多物品
    var result = inventory.add_item(potion)

    assert_false(result.success, "Should not add item to full inventory")
    assert_eq(result.error_code, "INVENTORY_FULL", "Should return inventory full error")
    assert_eq(inventory.get_item_count(), inventory.capacity, "Inventory size should not change")

func test_stackable_items():
    # 创建两个相同的药水
    var potion1 = HealthPotionItem.new()
    potion1.name = "Health Potion"
    potion1.quantity = 5

    var potion2 = HealthPotionItem.new()
    potion2.name = "Health Potion"
    potion2.quantity = 3

    # 添加第一个药水
    inventory.add_item(potion1)

    # 添加相同药水应该堆叠
    var result = inventory.add_item(potion2)

    assert_true(result.success, "Should stack identical items")
    assert_eq(inventory.get_item_count(), 1, "Should still have 1 stack")
    assert_eq(inventory.get_item_at(0).quantity, 8, "Stack should have combined quantity")
```

## 🔧 组件交互测试模式

### 信号通信测试

#### 简单信号测试
```gdscript
extends GutTest

var emitter: SignalEmitter
var receiver: SignalReceiver

var signal_received: bool = false
var signal_data: Variant = null

func before_each():
    emitter = SignalEmitter.new()
    receiver = SignalReceiver.new()

    # 连接信号
    emitter.data_updated.connect(_on_data_updated)

    add_child_autofree(emitter)
    add_child_autofree(receiver)

func _on_data_updated(data):
    signal_received = true
    signal_data = data

func test_signal_emission_and_reception():
    var test_data = {"score": 100, "level": 5}

    emitter.emit_signal("data_updated", test_data)

    assert_true(signal_received, "Signal should be received")
    assert_eq(signal_data, test_data, "Signal should carry correct data")
    assert_signal_emitted(emitter, "data_updated", [test_data])

func test_multiple_signal_connections():
    var receiver1 = TestReceiver.new()
    var receiver2 = TestReceiver.new()

    emitter.data_updated.connect(receiver1.handle_data)
    emitter.data_updated.connect(receiver2.handle_data)

    var test_data = {"value": 42}
    emitter.emit_signal("data_updated", test_data)

    assert_eq(receiver1.received_data, test_data, "First receiver should get data")
    assert_eq(receiver2.received_data, test_data, "Second receiver should get data")
    assert_signal_emit_count(emitter, "data_updated", 1, "Signal should be emitted once")
```

#### 复杂信号链测试
```gdscript
func test_signal_chain_communication():
    # 创建信号链：Input -> Player -> GameState -> UI
    var input_handler = InputHandler.new()
    var player = PlayerController.new()
    var game_state = GameState.new()
    var ui_manager = UIManager.new()

    # 设置信号链
    input_handler.action_performed.connect(player.handle_input)
    player.health_changed.connect(game_state.update_player_health)
    game_state.player_health_updated.connect(ui_manager.update_health_bar)

    add_child_autofree(input_handler)
    add_child_autofree(player)
    add_child_autofree(game_state)
    add_child_autofree(ui_manager)

    # 触发输入
    input_handler.simulate_action("take_damage", 25)

    # 验证信号链传播
    assert_signal_emitted(input_handler, "action_performed")
    assert_signal_emitted(player, "health_changed")
    assert_signal_emitted(game_state, "player_health_updated")
    assert_eq(ui_manager.health_bar_value, 75, "UI should reflect final health state")
```

### 依赖注入测试

#### 构造函数注入测试
```gdscript
extends GutTest

class MockInputSystem:
    var pressed_actions: Array[String] = []
    var action_strengths: Dictionary = {}

    func is_action_pressed(action: String) -> bool:
        return action in pressed_actions

    func get_action_strength(action: String) -> float:
        return action_strengths.get(action, 0.0)

func test_player_with_injected_input_system():
    var mock_input = MockInputSystem.new()
    mock_input.pressed_actions = ["move_right"]
    mock_input.action_strengths = ["move_right"] = 1.0

    var player = PlayerController.new(mock_input)  # 注入依赖
    player.position = Vector2.ZERO
    player.movement_speed = 100.0

    add_child_autofree(player)

    player._physics_process(1.0)

    assert_gt(player.position.x, 0, "Player should move right with injected input")
    assert_eq(player.position.y, 0, "Player should not move vertically")
```

#### 属性注入测试
```gdscript
func test_weapon_with_injected_damage_calculator():
    var weapon = Weapon.new()
    var damage_calc = MockDamageCalculator.new()
    damage_calc.damage_to_return = 50  # 设置返回值

    weapon.set_damage_calculator(damage_calc)  # 注入依赖

    var target = TestTarget.new()
    target.health = 100

    weapon.attack(target)

    assert_eq(target.health, 50, "Target should take damage from injected calculator")
    assert_called(damage_calc, "calculate_damage", [weapon, target])
```

## 🎯 场景和集成测试模式

### 场景加载测试
```gdscript
extends GutTest

func test_main_scene_loads_correctly():
    # 加载主场景
    var main_scene = preload("res://scenes/main_game.tscn").instantiate()
    add_child_autofree(main_scene)

    # 验证必要节点存在
    var player_node = main_scene.get_node_or_null("Player")
    assert_not_null(player_node, "Main scene should have Player node")

    var ui_node = main_scene.get_node_or_null("UI")
    assert_not_null(ui_node, "Main scene should have UI node")

    var game_manager_node = main_scene.get_node_or_null("GameManager")
    assert_not_null(game_manager_node, "Main scene should have GameManager node")

    # 验证节点类型
    assert_true(player_node is PlayerController, "Player should be PlayerController")
    assert_true(ui_node is CanvasLayer, "UI should be CanvasLayer")
    assert_true(game_manager_node is GameManager, "GameManager should be GameManager")

func test_level_scene_structure():
    var level_scene = preload("res://scenes/levels/test_level.tscn").instantiate()
    add_child_autofree(level_scene)

    # 检查关卡结构
    var tilemap = level_scene.get_node_or_null("TileMap")
    assert_not_null(tilemap, "Level should have TileMap")

    var spawn_points = level_scene.get_node_or_null("SpawnPoints")
    assert_not_null(spawn_points, "Level should have SpawnPoints container")

    # 验证至少有一个生成点
    var spawn_point_count = spawn_points.get_child_count()
    assert_gt(spawn_point_count, 0, "Level should have at least one spawn point")

    # 验证生成点命名规范
    for i in range(spawn_point_count):
        var spawn_point = spawn_points.get_child(i)
        assert_true(spawn_point.name.begins_with("SpawnPoint"), "Spawn points should follow naming convention")
```

### 完整工作流测试
```gdscript
extends GutTest

func test_complete_gameplay_workflow():
    # 设置完整游戏场景
    var game_scene = preload("res://scenes/game.tscn").instantiate()
    add_child_autofree(game_scene)

    var player = game_scene.get_node("Player")
    var enemy_spawner = game_scene.get_node("EnemySpawner")
    var ui = game_scene.get_node("UI")
    var game_state = game_scene.get_node("GameState")

    # 模拟游戏开始
    game_state.start_game()

    # 验证初始状态
    assert_eq(player.health, player.max_health, "Player should start with full health")
    assert_eq(game_state.get_score(), 0, "Score should start at 0")
    assert_false(game_state.is_game_over(), "Game should not be over at start")

    # 模拟敌人生成
    enemy_spawner.spawn_enemy()
    await wait_for_signal(enemy_spawner, "enemy_spawned", 1.0)

    var enemy = enemy_spawner.get_last_spawned_enemy()
    assert_not_null(enemy, "Enemy should be spawned")

    # 模拟玩家移动和攻击
    var enemy_position = enemy.global_position
    player.move_to(enemy_position)
    await wait_for_signal(player, "reached_target", 2.0)

    player.attack()
    await wait_for_signal(enemy, "health_changed", 0.5)

    # 验证攻击效果
    assert_lt(enemy.health, enemy.max_health, "Enemy should take damage")
    assert_gt(game_state.get_score(), 0, "Score should increase after hitting enemy")

    # 模拟敌人死亡
    enemy.health = 0
    enemy.take_damage(0)  # 触发死亡逻辑

    await wait_for_signal(enemy, "died", 0.5)
    assert_true(enemy.is_dead(), "Enemy should be dead")
    assert_true(game_state.get_score() > 0, "Score should increase after enemy death")

    # 验证UI更新
    assert_gt(ui.get_score_display(), 0, "UI should display updated score")
```

## 🔄 状态机测试模式

### 状态转换测试
```gdscript
extends GutTest

var player_state_machine: PlayerStateMachine

func before_each():
    player_state_machine = PlayerStateMachine.new()
    add_child_autofree(player_state_machine)

func test_initial_state():
    assert_eq(player_state_machine.current_state, PlayerStateMachine.State.IDLE,
              "Player should start in IDLE state")

func test_idle_to_walk_transition():
    # 模拟移动输入
    player_state_machine.handle_input("move_right", true)

    assert_eq(player_state_machine.current_state, PlayerStateMachine.State.WALKING,
              "Should transition to WALKING when movement input detected")

func test_walk_to_idle_transition():
    # 先进入行走状态
    player_state_machine.handle_input("move_right", true)
    player_state_machine._process(0.016)

    # 停止移动输入
    player_state_machine.handle_input("move_right", false)

    assert_eq(player_state_machine.current_state, PlayerStateMachine.State.IDLE,
              "Should transition back to IDLE when movement input stops")

func test_walk_to_attack_transition():
    # 进入行走状态
    player_state_machine.handle_input("move_right", true)
    player_state_machine._process(0.016)

    # 触发攻击
    player_state_machine.handle_input("attack", true)

    assert_eq(player_state_machine.current_state, PlayerStateMachine.State.ATTACKING,
              "Should transition to ATTACKING when attack input detected")

func test_invalid_state_transitions():
    # 在IDLE状态下停止移动（已经是IDLE）
    player_state_machine.handle_input("move_right", false)
    assert_eq(player_state_machine.current_state, PlayerStateMachine.State.IDLE,
              "Should remain in IDLE when stopping movement while already IDLE")

    # 在攻击状态下再次攻击（取决于攻击速度）
    player_state_machine.handle_input("attack", true)
    player_state_machine._process(0.016)

    # 如果武器有攻击冷却，第二次攻击应该被忽略
    if player_state_machine.is_attack_cooldown_active():
        assert_eq(player_state_machine.current_state, PlayerStateMachine.State.ATTACKING,
                  "Should remain in ATTACKING during cooldown")
```

## 🚀 性能测试模式

### 算法性能测试
```gdscript
extends GutTest

func test_pathfinding_algorithm_performance():
    var pathfinder = AStarPathfinder.new()
    var grid_size = 50
    var obstacles = []

    # 设置测试网格
    pathfinder.setup_grid(grid_size, grid_size)

    # 添加一些障碍物
    for i in range(20):
        var obstacle_pos = Vector2i(randi() % grid_size, randi() % grid_size)
        obstacles.append(obstacle_pos)
        pathfinder.set_cell_obstacle(obstacle_pos, true)

    var start_pos = Vector2i(0, 0)
    var end_pos = Vector2i(grid_size - 1, grid_size - 1)

    # 性能测试
    reset_start_times()
    var path = pathfinder.find_path(start_pos, end_pos)
    var elapsed_time = get_elapsed_test_time()

    # 验证性能要求
    assert_lt(elapsed_time, 0.05, "Pathfinding should complete within 50ms for 50x50 grid")
    assert_not_null(path, "Path should be found")
    assert_gt(path.size(), 0, "Path should contain waypoints")

    # 验证路径质量
    var path_length = pathfinder.calculate_path_length(path)
    var direct_distance = start_pos.distance_to(end_pos)
    assert_lte(path_length, direct_distance * 1.5, "Path should be reasonably optimal")

func test_particle_system_performance():
    var particle_system = ParticleSystem.new()
    particle_system.max_particles = 1000

    add_child_autofree(particle_system)

    # 测试粒子生成性能
    reset_start_times()
    particle_system.emit(1000)  # 发射1000个粒子
    var emit_time = get_elapsed_test_time()

    assert_lt(emit_time, 0.1, "Particle emission should complete within 100ms")
    assert_eq(particle_system.get_active_particle_count(), 1000, "All particles should be active")

    # 测试粒子更新性能
    reset_start_times()
    for i in range(100):  # 模拟100帧
        particle_system._process(0.016)
    var update_time = get_elapsed_test_time()

    assert_lt(update_time, 0.2, "Particle updates should be fast")
    assert_gt(particle_system.get_active_particle_count(), 0, "Particles should still be active")
```

### 内存使用测试
```gdscript
func test_memory_usage_in_game_loop():
    var initial_memory = OS.get_static_memory_usage_by_type()[0]

    # 创建多个游戏对象
    var objects = []
    for i in range(100):
        var obj = GameObject.new()
        obj.initialize_with_complex_data()
        objects.append(obj)

    var peak_memory = OS.get_static_memory_usage_by_type()[0]
    var memory_increase = peak_memory - initial_memory

    # 验证内存使用合理
    assert_lt(memory_increase, 100 * 1024 * 1024, "Memory increase should be less than 100MB")

    # 清理对象
    for obj in objects:
        obj.queue_free()
    objects.clear()

    # 等待垃圾回收
    await get_tree().process_frame
    await get_tree().process_frame

    var final_memory = OS.get_static_memory_usage_by_type()[0]
    var memory_released = peak_memory - final_memory

    assert_gt(memory_released, memory_increase * 0.8, "Most memory should be released")
```

## 🐛 常见测试反模式和解决方案

### 反模式1：测试实现细节
```gdscript
# ❌ 反模式：测试私有变量
func test_player_internal_velocity():
    var player = Player.new()
    player._velocity = Vector2(100, 0)  # 直接设置私有变量
    player._process(1.0)
    assert_eq(player.position.x, 100)

# ✅ 正确模式：测试公共接口
func test_player_movement_result():
    var player = Player.new()
    player.move_direction(Vector2.RIGHT)  # 使用公共方法
    player._process(1.0)
    assert_eq(player.position.x, 100)
```

### 反模式2：测试过于复杂
```gdscript
# ❌ 反模式：一个测试验证太多功能
func test_complete_player_system():
    # 测试移动、战斗、库存、UI...太复杂
    pass

# ✅ 正确模式：拆分为多个专门的测试
func test_player_movement()
func test_player_combat()
func test_player_inventory()
func test_player_ui_interaction()
```

### 反模式3：测试依赖外部状态
```gdscript
# ❌ 反模式：依赖全局状态
var global_player: Player

func test_player_health():
    global_player = Player.new()  # 修改全局状态

# ✅ 正确模式：每个测试创建自己的实例
func test_player_health():
    var player = Player.new()  # 局部实例
```

### 反模式4：测试不稳定（时间依赖）
```gdscript
# ❌ 反模式：依赖真实时间
func test_timer():
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.start()
    await get_tree().create_timer(1.0).timeout  # 可能不稳定

# ✅ 正确模式：使用模拟时间或直接触发
func test_timer():
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.start()
    timer.emit_signal("timeout")  # 直接触发
    assert_true(timer.time_left == 0)
```

这些测试模式和示例为 Godot 游戏开发提供了全面的测试指导，从基础功能测试到复杂的集成测试，帮助开发者构建高质量、可维护的游戏代码。