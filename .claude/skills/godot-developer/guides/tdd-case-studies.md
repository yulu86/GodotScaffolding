# TDD 实践案例研究

> **重要提示**：本文档展示实际游戏功能开发的完整 TDD 流程。每个案例都从需求分析开始，经过 Red-Green-Refactor 循环，最终产出高质量的功能代码。

## 📚 案例研究概览

本文档包含以下完整的 TDD 实践案例：

1. **玩家移动系统** - 基础游戏控制功能
2. **敌人 AI 行为系统** - 复杂的状态机实现
3. **物品和库存系统** - 数据管理和用户交互
4. **关卡进度系统** - 游戏流程和数据持久化
5. **音效管理系统** - 资源管理和性能优化

## 🎮 案例一：玩家移动系统开发

### 需求分析

**功能需求**：
- 玩家可以在2D平面中向四个方向移动
- 移动速度可配置
- 支持对角线移动（速度需要标准化）
- 移动有加速度和摩擦力，使动作更自然
- 支持输入配置（键盘、手柄等）

**技术要求**：
- 使用物理引擎进行移动计算
- 支持动画状态切换
- 性能优化，避免每帧重复计算

### Phase 1: Red - 编写失败的测试

#### 1.1 基础移动测试
```gdscript
# test/unit/test_player_movement.gd
extends GutTest

var player: Player
var input_system: MockInputSystem

func before_each():
    input_system = MockInputSystem.new()
    player = Player.new()
    player.input_system = input_system
    add_child_autofree(player)

func test_player_can_move_right():
    # 红色阶段：这个测试会失败，因为Player类还不存在
    player.position = Vector2.ZERO
    player.movement_speed = 100.0

    input_system.simulate_action("move_right", true)
    player._physics_process(1.0)

    assert_eq(player.position.x, 100.0, "Player should move 100 units right in 1 second")
    assert_eq(player.position.y, 0.0, "Player should not move vertically")

func test_player_can_move_left():
    player.position = Vector2.ZERO
    player.movement_speed = 100.0

    input_system.simulate_action("move_left", true)
    player._physics_process(1.0)

    assert_eq(player.position.x, -100.0, "Player should move 100 units left in 1 second")
```

#### 1.2 对角线移动测试
```gdscript
func test_diagonal_movement_normalized():
    player.position = Vector2.ZERO
    player.movement_speed = 100.0

    input_system.simulate_action("move_right", true)
    input_system.simulate_action("move_up", true)
    player._physics_process(1.0)

    # 对角线移动速度应该是标准化的
    var expected_speed = player.movement_speed / sqrt(2)  # ~70.71
    assert_almost_eq(player.position.x, expected_speed, 0.1, "X speed should be normalized")
    assert_almost_eq(player.position.y, -expected_speed, 0.1, "Y speed should be normalized")

func test_movement_with_acceleration():
    player.position = Vector2.ZERO
    player.movement_speed = 100.0
    player.acceleration = 200.0  # 每秒200单位加速度

    input_system.simulate_action("move_right", true)
    player._physics_process(0.5)  # 半秒时间

    # 在加速下，移动距离应该小于最大速度
    var expected_distance = 0.5 * player.acceleration * 0.5 * 0.5  # 0.5 * a * t^2
    assert_almost_eq(player.position.x, expected_distance, 0.1, "Should show acceleration effect")
```

### Phase 2: Green - 最小实现

#### 2.1 创建基础的Player类
```gdscript
# scripts/Player.gd
extends CharacterBody2D
class_name Player

@export var movement_speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 600.0

var input_system: InputSystem

func _ready():
    if not input_system:
        input_system = InputSystem.new()

func _physics_process(delta: float):
    handle_input(delta)
    move_and_slide()

func handle_input(delta: float):
    # 最小实现：让测试通过
    var input_direction = Vector2.ZERO

    if input_system.is_action_pressed("move_right"):
        input_direction.x += 1
    if input_system.is_action_pressed("move_left"):
        input_direction.x -= 1
    if input_system.is_action_pressed("move_up"):
        input_direction.y -= 1
    if input_system.is_action_pressed("move_down"):
        input_direction.y += 1

    # 简单实现，让基础测试通过
    if input_direction.length() > 0:
        input_direction = input_direction.normalized()
        velocity = input_direction * movement_speed
    else:
        velocity = Vector2.ZERO
```

运行测试，确认基础测试通过。

#### 2.2 MockInputSystem 实现
```gdscript
# test/mock/mock_input_system.gd
extends Node
class_name MockInputSystem

var pressed_actions: Array[String] = []

func is_action_pressed(action: String) -> bool:
    return action in pressed_actions

func get_action_strength(action: String) -> float:
    return 1.0 if action in pressed_actions else 0.0

func simulate_action(action: String, pressed: bool):
    if pressed:
        if action not in pressed_actions:
            pressed_actions.append(action)
    else:
        pressed_actions.erase(action)
```

### Phase 3: Refactor - 重构优化

#### 3.1 重构Player类结构
```gdscript
# scripts/Player.gd - 重构版本
extends CharacterBody2D
class_name Player

@export var movement_speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 600.0

var input_system: InputSystem
var _input_direction: Vector2 = Vector2.ZERO

func _ready():
    if not input_system:
        input_system = InputSystem.new()

func _physics_process(delta: float):
    _update_input_direction()
    _apply_movement(delta)
    move_and_slide()

func _update_input_direction():
    """更新输入方向"""
    _input_direction = Vector2.ZERO

    if input_system.is_action_pressed("move_right"):
        _input_direction.x += 1
    if input_system.is_action_pressed("move_left"):
        _input_direction.x -= 1
    if input_system.is_action_pressed("move_up"):
        _input_direction.y -= 1
    if input_system.is_action_pressed("move_down"):
        _input_direction.y += 1

    # 标准化对角线移动
    if _input_direction.length() > 0:
        _input_direction = _input_direction.normalized()

func _apply_movement(delta: float):
    """应用移动逻辑"""
    if _input_direction.length() > 0:
        # 加速到目标速度
        velocity = velocity.move_toward(
            _input_direction * movement_speed,
            acceleration * delta
        )
    else:
        # 应用摩擦力减速
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
```

### Phase 4: 完善 - 增加更多测试

#### 4.1 边界条件测试
```gdscript
func test_movement_with_zero_speed():
    player.movement_speed = 0.0
    player.position = Vector2.ZERO

    input_system.simulate_action("move_right", true)
    player._physics_process(1.0)

    assert_eq(player.position, Vector2.ZERO, "Zero speed should not move player")

func test_movement_with_negative_speed():
    player.movement_speed = -100.0
    player.position = Vector2.ZERO

    input_system.simulate_action("move_right", true)
    player._physics_process(1.0)

    # 应该处理负速度的边界情况
    assert_eq(player.position, Vector2.ZERO, "Negative speed should be handled safely")
```

#### 4.2 性能测试
```gdscript
func test_movement_performance():
    player.position = Vector2.ZERO
    input_system.simulate_action("move_right", true)

    reset_start_times()

    # 模拟1000帧
    for i in range(1000):
        player._physics_process(0.016)

    var elapsed_time = get_elapsed_test_time()
    assert_lt(elapsed_time, 0.1, "Movement calculation should be fast")
    assert_gt(player.position.x, 0, "Player should have moved")
```

## 🤖 案例二：敌人 AI 行为系统

### 需求分析

**功能需求**：
- 敌人有巡逻、追击、攻击、逃跑等状态
- 基于玩家位置和状态进行决策
- 支持视野范围检测
- 不同敌人类型有不同的行为模式

### TDD 实现过程

#### Red 阶段：状态机测试
```gdscript
# test/unit/test_enemy_ai.gd
extends GutTest

var enemy: EnemyAI
var player: Player

func before_each():
    enemy = EnemyAI.new()
    player = Player.new()
    player.position = Vector2(100, 0)

    add_child_autofree(enemy)
    add_child_autofree(player)

func test_enemy_starts_in_patrol_state():
    assert_eq(enemy.current_state, EnemyAI.State.PATROL, "Enemy should start in patrol state")

func test_enemy_chases_player_in_range():
    enemy.position = Vector2.ZERO
    enemy.detection_range = 150.0
    enemy.set_target(player)

    enemy._process(0.016)

    assert_eq(enemy.current_state, EnemyAI.State.CHASE, "Should chase player in detection range")

func test_enemy_ignores_player_out_of_range():
    enemy.position = Vector2.ZERO
    enemy.detection_range = 50.0
    player.position = Vector2(100, 0)  # 超出检测范围
    enemy.set_target(player)

    enemy._process(0.016)

    assert_eq(enemy.current_state, EnemyAI.State.PATROL, "Should ignore player out of range")
```

#### Green 阶段：基础状态机实现
```gdscript
# scripts/EnemyAI.gd
extends Node2D
class_name EnemyAI

enum State {
    PATROL,
    CHASE,
    ATTACK,
    FLEE,
    IDLE
}

@export var detection_range: float = 100.0
@export var attack_range: float = 50.0
@export var movement_speed: float = 80.0

var current_state: State = State.PATROL
var target: Node2D
var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0

func _ready():
    patrol_points = [Vector2(-100, 0), Vector2(100, 0)]

func _process(delta: float):
    _update_state()
    _execute_current_state(delta)

func _update_state():
    # 最小实现：简单的状态转换逻辑
    if target and position.distance_to(target.position) <= detection_range:
        current_state = State.CHASE
    else:
        current_state = State.PATROL

func _execute_current_state(delta: float):
    match current_state:
        State.PATROL:
            _patrol_behavior(delta)
        State.CHASE:
            _chase_behavior(delta)

func _patrol_behavior(delta: float):
    if patrol_points.size() > 0:
        var target_point = patrol_points[current_patrol_index]
        var direction = (target_point - position).normalized()
        position += direction * movement_speed * delta

        if position.distance_to(target_point) < 10:
            current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func _chase_behavior(delta: float):
    if target:
        var direction = (target.position - position).normalized()
        position += direction * movement_speed * delta
```

#### Refactor 阶段：状态机架构优化
```gdscript
# scripts/EnemyAI.gd - 重构版本
extends Node2D
class_name EnemyAI

enum State {
    PATROL,
    CHASE,
    ATTACK,
    FLEE,
    IDLE
}

@export var detection_range: float = 100.0
@export var attack_range: float = 50.0
@export var movement_speed: float = 80.0
@export var flee_health_threshold: float = 0.3

var current_state: State = State.PATROL
var target: Node2D
var state_timer: float = 0.0
var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0

func _ready():
    patrol_points = _generate_patrol_points()

func _process(delta: float):
    _update_state_timer(delta)
    _update_state()
    _execute_current_state(delta)

func _update_state_timer(delta: float):
    state_timer += delta

func _update_state():
    var new_state = _determine_desired_state()
    if new_state != current_state:
        _transition_to_state(new_state)

func _determine_desired_state() -> State:
    if not target:
        return State.PATROL

    var distance_to_target = position.distance_to(target.position)

    # 低血量时逃跑
    if _get_health_percentage() <= flee_health_threshold:
        return State.FLEE

    # 攻击范围内攻击
    if distance_to_target <= attack_range:
        return State.ATTACK

    # 检测范围内追击
    if distance_to_target <= detection_range:
        return State.CHASE

    return State.PATROL

func _transition_to_state(new_state: State):
    _exit_state(current_state)
    current_state = new_state
    _enter_state(new_state)

func _enter_state(state: State):
    state_timer = 0.0
    match state:
        State.PATROL:
            # 选择最近的巡逻点
            current_patrol_index = _find_nearest_patrol_point()
        State.ATTACK:
            # 准备攻击
            pass

func _exit_state(state: State):
    match state:
        State.ATTACK:
            # 清理攻击状态
            pass

func _execute_current_state(delta: float):
    match current_state:
        State.PATROL:
            _execute_patrol(delta)
        State.CHASE:
            _execute_chase(delta)
        State.ATTACK:
            _execute_attack(delta)
        State.FLEE:
            _execute_flee(delta)

# 具体状态执行方法
func _execute_patrol(delta: float):
    if patrol_points.size() == 0:
        return

    var target_point = patrol_points[current_patrol_index]
    var direction = (target_point - position).normalized()
    position += direction * movement_speed * delta

    if position.distance_to(target_point) < 10:
        current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func _execute_chase(delta: float):
    if not target:
        return

    var direction = (target.position - position).normalized()
    position += direction * movement_speed * delta

func _execute_attack(delta: float):
    if not target:
        return

    # 攻击逻辑
    if state_timer >= 1.0:  # 每秒攻击一次
        _perform_attack()
        state_timer = 0.0

func _execute_flee(delta: float):
    if not target:
        return

    var flee_direction = (position - target.position).normalized()
    position += flee_direction * movement_speed * 1.5 * delta  # 逃跑速度更快

# 辅助方法
func _generate_patrol_points() -> Array[Vector2]:
    var points: Array[Vector2] = []
    var radius = 100.0
    for i in range(4):
        var angle = (PI / 2) * i
        points.append(position + Vector2(cos(angle), sin(angle)) * radius)
    return points

func _find_nearest_patrol_point() -> int:
    var nearest_index = 0
    var nearest_distance = INF

    for i in range(patrol_points.size()):
        var distance = position.distance_to(patrol_points[i])
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_index = i

    return nearest_index

func _get_health_percentage() -> float:
    # 假设敌人有health属性
    return float(health) / max_health

func _perform_attack():
    if target.has_method("take_damage"):
        target.take_damage(10)
```

## 🎒 案例三：物品和库存系统

### 需求分析

**功能需求**：
- 支持不同类型的物品（武器、药水、材料等）
- 库存有容量限制
- 相同物品可以堆叠
- 物品可以装备和使用
- 支持拖拽操作

### TDD 实现过程

#### Red 阶段：库存基础功能测试
```gdscript
# test/unit/test_inventory.gd
extends GutTest

var inventory: Inventory
var sword: WeaponItem
var potion: HealthPotionItem

func before_each():
    inventory = Inventory.new()
    inventory.capacity = 20

    sword = WeaponItem.new()
    sword.name = "Iron Sword"
    sword.damage = 15
    sword.weight = 5.0
    sword.stack_size = 1

    potion = HealthPotionItem.new()
    potion.name = "Health Potion"
    potion.heal_amount = 25
    potion.weight = 0.5
    potion.stack_size = 99

    add_child_autofree(inventory)

func test_add_item_to_empty_inventory():
    var result = inventory.add_item(sword)

    assert_true(result.success, "Should add item to empty inventory")
    assert_eq(inventory.get_item_count(), 1, "Inventory should have 1 item")
    assert_eq(inventory.get_item_at(0), sword, "Sword should be at slot 0")

func test_add_stackable_items():
    var potion1 = HealthPotionItem.new()
    potion1.name = "Health Potion"
    potion1.quantity = 5

    var potion2 = HealthPotionItem.new()
    potion2.name = "Health Potion"
    potion2.quantity = 3

    # 添加第一个药水
    var result1 = inventory.add_item(potion1)
    assert_true(result1.success, "Should add first potion")

    # 添加相同药水应该堆叠
    var result2 = inventory.add_item(potion2)
    assert_true(result2.success, "Should stack identical items")
    assert_eq(inventory.get_item_count(), 1, "Should still have 1 stack")
    assert_eq(inventory.get_item_at(0).quantity, 8, "Stack should have combined quantity")

func test_inventory_full_prevents_adding():
    # 填满库存
    for i in range(inventory.capacity):
        var item = Item.new()
        inventory.add_item(item)

    var result = inventory.add_item(sword)
    assert_false(result.success, "Should not add item to full inventory")
    assert_eq(result.error_code, "INVENTORY_FULL", "Should return appropriate error")
```

#### Green 阶段：基础库存实现
```gdscript
# scripts/Inventory.gd
extends Node
class_name Inventory

@export var capacity: int = 20

var items: Array[Item] = []
var signals_connections: Dictionary = {}

signal item_added(item: Item, slot: int)
signal item_removed(slot: int)
signal item_moved(from_slot: int, to_slot: int)

func add_item(item: Item) -> Dictionary:
    # 最小实现，让基础测试通过
    if items.size() >= capacity:
        return {"success": false, "error_code": "INVENTORY_FULL"}

    # 检查是否可以堆叠
    for i in range(items.size()):
        if _can_stack_with(items[i], item):
            items[i].quantity += item.quantity
            return {"success": true, "slot": i}

    # 添加到新槽位
    items.append(item)
    return {"success": true, "slot": items.size() - 1}

func _can_stack_with(existing_item: Item, new_item: Item) -> bool:
    # 简单的堆叠检查
    return existing_item.name == new_item.name and existing_item.stack_size > 1

func get_item_count() -> int:
    return items.size()

func get_item_at(slot: int) -> Item:
    if slot >= 0 and slot < items.size():
        return items[slot]
    return null
```

#### Refactor 阶段：完善库存系统
```gdscript
# scripts/Inventory.gd - 重构版本
extends Node
class_name Inventory

@export var capacity: int = 20
@export var max_weight: float = 100.0

var items: Array[Item] = []
var _total_weight: float = 0.0

signal item_added(item: Item, slot: int)
signal item_removed(slot: int, item: Item)
signal item_moved(from_slot: int, to_slot: int, item: Item)
signal inventory_full
signal weight_exceeded

func add_item(item: Item) -> Dictionary:
    # 验证物品
    if not item:
        return {"success": false, "error_code": "INVALID_ITEM"}

    # 检查容量
    if items.size() >= capacity:
        var stack_result = _try_stack_with_existing(item)
        if stack_result.success:
            return stack_result
        else:
            inventory_full.emit()
            return {"success": false, "error_code": "INVENTORY_FULL"}

    # 检查重量
    if _total_weight + item.weight > max_weight:
        weight_exceeded.emit()
        return {"success": false, "error_code": "WEIGHT_EXCEEDED"}

    # 尝试堆叠
    var stack_result = _try_stack_with_existing(item)
    if stack_result.success:
        return stack_result

    # 添加到空槽位
    items.append(item)
    _total_weight += item.weight
    item_added.emit(item, items.size() - 1)

    return {"success": true, "slot": items.size() - 1}

func _try_stack_with_existing(new_item: Item) -> Dictionary:
    for i in range(items.size()):
        var existing_item = items[i]
        if _can_stack_with(existing_item, new_item):
            var max_stack = existing_item.stack_size
            var can_add = min(new_item.quantity, max_stack - existing_item.quantity)

            if can_add > 0:
                existing_item.quantity += can_add
                _total_weight += can_add * new_item.weight

                if can_add < new_item.quantity:
                    # 如果新物品还有剩余，创建新物品
                    var remaining_item = new_item.duplicate()
                    remaining_item.quantity = new_item.quantity - can_add
                    return add_item(remaining_item)

                return {"success": true, "slot": i}

    return {"success": false}

func _can_stack_with(existing_item: Item, new_item: Item) -> bool:
    return (
        existing_item.get_script() == new_item.get_script() and
        existing_item.name == new_item.name and
        existing_item.stack_size > 1 and
        existing_item.quantity < existing_item.stack_size and
        existing_item.can_stack_with(new_item)
    )

func remove_item(slot: int, quantity: int = -1) -> Dictionary:
    if slot < 0 or slot >= items.size():
        return {"success": false, "error_code": "INVALID_SLOT"}

    var item = items[slot]
    var remove_quantity = quantity if quantity > 0 else item.quantity

    if remove_quantity > item.quantity:
        remove_quantity = item.quantity

    if remove_quantity == item.quantity:
        # 移除整个堆叠
        items.remove_at(slot)
        _total_weight -= item.weight * item.quantity
        item_removed.emit(slot, item)
        return {"success": true, "item": item}
    else:
        # 部分移除
        item.quantity -= remove_quantity
        _total_weight -= item.weight * remove_quantity

        var removed_item = item.duplicate()
        removed_item.quantity = remove_quantity
        item_removed.emit(slot, removed_item)
        return {"success": true, "item": removed_item}

func move_item(from_slot: int, to_slot: int) -> Dictionary:
    if from_slot < 0 or from_slot >= items.size():
        return {"success": false, "error_code": "INVALID_SOURCE_SLOT"}

    if to_slot < 0 or to_slot >= capacity:
        return {"success": false, "error_code": "INVALID_TARGET_SLOT"}

    var item = items[from_slot]

    if to_slot < items.size():
        # 目标槽位有物品，尝试堆叠或交换
        var target_item = items[to_slot]
        if _can_stack_with(target_item, item):
            # 堆叠
            items[from_slot] = null
            items[from_slot].clear()
            return add_item(item)
        else:
            # 交换
            items[from_slot] = target_item
            items[to_slot] = item
            item_moved.emit(from_slot, to_slot, item)
            item_moved.emit(to_slot, from_slot, target_item)
    else:
        # 移动到空槽位
        items.remove_at(from_slot)
        items.insert(to_slot, item)
        item_moved.emit(from_slot, to_slot, item)

    return {"success": true}

func get_total_weight() -> float:
    return _total_weight

func is_full() -> bool:
    return items.size() >= capacity

func get_empty_slots() -> int:
    return capacity - items.size()

func find_item(item_name: String) -> int:
    for i in range(items.size()):
        if items[i] and items[i].name == item_name:
            return i
    return -1

func get_item_count(item_name: String) -> int:
    var total = 0
    for item in items:
        if item and item.name == item_name:
            total += item.quantity
    return total
```

## 🎯 案例四：音效管理系统

### 需求分析

**功能需求**：
- 支持不同类型的音效（背景音乐、音效、语音）
- 音量控制和淡入淡出
- 音效池管理，避免频繁创建销毁
- 3D空间音效支持

### TDD 实现过程

#### Red 阶段：音效播放测试
```gdscript
# test/unit/test_audio_manager.gd
extends GutTest

var audio_manager: AudioManager
var test_sound: AudioStream

func before_each():
    audio_manager = AudioManager.new()
    test_sound = AudioStreamOggVorbis.load_from_file("res://assets/sounds/test.ogg")

    add_child_autofree(audio_manager)

func test_play_sound_2d():
    var result = audio_manager.play_sound_2d(test_sound, Vector2.ZERO)

    assert_true(result, "Should successfully play 2D sound")
    assert_gt(audio_manager.get_playing_count(), 0, "Should have at least one playing sound")

func test_sound_pool_management():
    # 播放多个相同音效
    var results = []
    for i in range(10):
        results.append(audio_manager.play_sound_2d(test_sound, Vector2.ZERO))

    # 所有播放都应该成功
    for result in results:
        assert_true(result, "All sound plays should succeed")

    # 播放数量应该合理（音效池限制）
    assert_lte(audio_manager.get_playing_count(), 20, "Should not exceed pool limit")

func test_volume_control():
    audio_manager.set_master_volume(0.5)

    audio_manager.play_sound_2d(test_sound, Vector2.ZERO)

    assert_eq(audio_manager.get_master_volume(), 0.5, "Volume should be set correctly")
```

#### Green 阶段：基础音频管理
```gdscript
# scripts/AudioManager.gd
extends Node
class_name AudioManager

const MAX_PLAYING_SOUNDS = 20

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

var playing_sounds: Array[AudioStreamPlayer2D] = []
var sound_pool: Array[AudioStreamPlayer2D] = []

signal sound_started(sound_player: AudioStreamPlayer2D)
signal sound_finished(sound_player: AudioStreamPlayer2D)

func _ready():
    _initialize_sound_pool()

func _initialize_sound_pool():
    for i in range(MAX_PLAYING_SOUNDS):
        var player = AudioStreamPlayer2D.new()
        player.finished.connect(_on_sound_finished.bind(player))
        sound_pool.append(player)
        add_child(player)

func play_sound_2d(stream: AudioStream, position: Vector2) -> bool:
    if not stream:
        return false

    var player = _get_available_player()
    if not player:
        return false

    player.stream = stream
    player.position = position
    player.volume_db = linear_to_db(master_volume * sfx_volume)
    player.play()

    playing_sounds.append(player)
    sound_started.emit(player)
    return true

func _get_available_player() -> AudioStreamPlayer2D:
    for player in sound_pool:
        if not player.playing:
            return player
    return null

func _on_sound_finished(player: AudioStreamPlayer2D):
    playing_sounds.erase(player)
    sound_finished.emit(player)

func get_playing_count() -> int:
    return playing_sounds.size()

func set_master_volume(volume: float):
    master_volume = clamp(volume, 0.0, 1.0)
    _update_all_volumes()

func get_master_volume() -> float:
    return master_volume

func _update_all_volumes():
    for player in playing_sounds:
        player.volume_db = linear_to_db(master_volume * sfx_volume)
```

这个 TDD 案例研究展示了如何从需求分析开始，通过系统的测试驱动开发流程，逐步构建复杂且高质量的 game 功能。每个案例都遵循 Red-Green-Refactor 循环，确保代码质量和功能的正确性。