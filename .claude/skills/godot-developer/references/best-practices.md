# Godot 最佳实践指南

> **重要提示**：本文档基于 Godot 官方风格指南扩展，所有编码规范必须优先遵循 [official_gdscript_styleguide.md](./official_gdscript_styleguide.md)

## 🎮 场景设计原则

### 1. 场景树组织
```
Main (Node)
├── World (Node2D/Node3D)
│   ├── TileMap
│   ├── Player
│   ├── Enemies
│   └── Objects
├── UI (CanvasLayer)
│   ├── HUD
│   ├── Menus
│   └── Notifications
└── Audio (Node)
    ├── MusicPlayer
    └── SFXPlayer
```

### 2. 节点选择指南
- **动画**: 优先使用 `AnimationPlayer` 而非 `AnimatedSprite2D`
- **UI根节点**: 使用 `Control` 或其子类
- **2D角色**: 使用 `CharacterBody2D`、`RigidBody2D` 或 `Area2D`
- **3D角色**: 使用 `CharacterBody3D`、`RigidBody3D` 或 `Area3D`

## 💻 GDScript编码规范

### 1. 命名规范
```gdscript
# 类名使用PascalCase
class_name PlayerController

# 变量和函数使用snake_case
var movement_speed: float = 300.0
func calculate_velocity() -> Vector2

# 常量使用UPPER_SNAKE_CASE
const MAX_HEALTH: int = 100

# 私有变量添加下划线前缀
var _internal_state: bool = false

# 节点引用使用@onready
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
```

### 2. 类型提示
```gdscript
# 函数参数和返回值添加类型
func take_damage(amount: int) -> void:
    pass

func get_health_percentage() -> float:
    return float(current_health) / max_health

# 变量声明时指定类型
var inventory: Array[Item] = []
var enemies: Dictionary = {}
```

### 3. 信号使用
```gdscript
# 定义信号
signal health_changed(new_health: int)
signal player_died
signal item_collected(item: Item)

# 连接信号
func _ready():
    health_changed.connect(UIManager.update_health_bar)
    player_died.connect(GameManager.game_over)

# 发射信号
func update_health(value: int):
    current_health = value
    health_changed.emit(current_health)
```

## 🔄 生命周期管理

### 1. _ready() 方法
```gdscript
func _ready():
    # 1. 获取节点引用
    _sprite = $Sprite2D
    _animation_player = $AnimationPlayer

    # 2. 连接信号
    connect("body_entered", _on_body_entered)

    # 3. 初始化状态
    current_state = State.IDLE

    # 4. 启动定时器等
    $UpdateTimer.start()
```

### 2. _process() vs _physics_process()
```gdscript
# 每帧渲染更新（动画、视觉效果）
func _process(delta: float):
    update_animation()
    handle_input()
    update_particles()

# 物理更新（移动、碰撞检测）
func _physics_process(delta: float):
    move_and_slide()
    check_collisions()
    apply_gravity(delta)
```

## 🎯 性能优化

### 1. 避免性能陷阱
```gdscript
# ❌ 错误：在_process中频繁查找节点
func _process(delta):
    $Sprite2D.position += direction * speed * delta

# ✅ 正确：使用@onready缓存节点引用
@onready var sprite: Sprite2D = $Sprite2D
func _process(delta):
    sprite.position += direction * speed * delta

# ❌ 错误：每帧创建新对象
func _process(delta):
    var bullet = BulletScene.instantiate()
    add_child(bullet)

# ✅ 正确：使用对象池
func spawn_bullet():
    var bullet = BulletPool.get_bullet()
    if bullet:
        bullet.position = global_position
        bullet.activate()
```

### 2. 优化渲染
```gdscript
# 使用visibility范围
@export var visibility_range: float = 500.0

func _process(delta):
    var distance_to_player = global_position.distance_to(Player.global_position)
    visible = distance_to_player < visibility_range

    # 使用场景剔除
    $Sprite2D.visible = distance_to_player < visibility_range / 2

# 合并静态物体
# 将不移动的静态物体合并到单个TileMap或MeshInstance
```

## 🔧 常用模式

### 1. 状态机模式
```gdscript
enum State {
    IDLE,
    WALKING,
    JUMPING,
    ATTACKING
}

var current_state: State = State.IDLE

func _physics_process(delta):
    match current_state:
        State.IDLE:
            handle_idle_state(delta)
        State.WALKING:
            handle_walking_state(delta)
        State.JUMPING:
            handle_jumping_state(delta)
        State.ATTACKING:
            handle_attacking_state(delta)

func change_state(new_state: State):
    if current_state != new_state:
        exit_state(current_state)
        current_state = new_state
        enter_state(new_state)
```

### 2. 观察者模式（使用信号）
```gdscript
# 主题类
class_name AchievementSystem extends Node

signal achievement_unlocked(achievement_name: String)

# 观察者
class_name UIManager extends Node

func _ready():
    AchievementSystem.achievement_unlocked.connect(show_achievement_popup)
```

### 3. 单例模式（AutoLoad）
```gdscript
# 在项目设置中设置为AutoLoad
# 文件: global/game_manager.gd

extends Node

# 全局可访问
var player_score: int = 0
var current_level: int = 1

func add_score(points: int):
    player_score += points
    score_changed.emit(player_score)
```

## 📁 资源管理

### 1. 预加载资源
```gdscript
# 在类顶部预加载常用资源
const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const ENEMY_SCENE = preload("res://scenes/enemies/enemy.tscn")
const BULLET_SCENE = preload("res://scenes/projectiles/bullet.tscn")

# 音频资源
const SHOOT_SOUND = preload("res://assets/sounds/shoot.wav")
const HIT_SOUND = preload("res://assets/sounds/hit.wav")
```

### 2. 动态加载
```gdscript
# 需要时加载
func load_level(level_path: String):
    var packed_scene = load(level_path)
    if packed_scene:
        var level_instance = packed_scene.instantiate()
        $LevelContainer.add_child(level_instance)

# 异步加载
func load_level_async(level_path: String):
    ResourceLoader.load_threaded_request(level_path)
```

## 🧪 测试驱动开发最佳实践

### 1. TDD 基本原则
```gdscript
# 好的测试命名：清晰描述测试场景和预期结果
func test_player_takes_damage_and_health_decreases()
func test_player_health_never_goes_below_zero()
func test_player_heals_to_maximum_health_limit()

func test_inventory_adds_item_when_space_available()
func test_inventory_rejects_item_when_full()
func test_inventory_stacks_items_of_same_type()
```

### 2. 测试组织结构
```gdscript
# 测试文件结构示例
# test/unit/
# ├── test_player_controller.gd    # 玩家控制器测试
# ├── test_inventory_system.gd     # 库存系统测试
# ├── test_enemy_ai.gd           # 敌人AI测试
# ├── test_weapon_system.gd      # 武器系统测试
# └── helpers/                   # 测试辅助类
#     ├── test_player_factory.gd
#     └── mock_input_system.gd

# 标准测试模板
extends GutTest

var test_object: TestClass
var test_data: Dictionary = {}

func before_all():
    """在整个测试套件运行前执行一次"""
    test_data = load_test_configuration()

func before_each():
    """在每个测试方法前执行"""
    test_object = TestClass.new()
    add_child_autofree(test_object)

func after_each():
    """在每个测试方法后执行"""
    if test_object:
        test_object.cleanup()

func after_all():
    """在整个测试套件运行后执行一次"""
    test_data.clear()
```

### 3. AAA 测试模式 (Arrange-Act-Assert)
```gdscript
func test_player_movement_with_correct_speed():
    # Arrange - 准备测试环境
    var player = Player.new()
    player.position = Vector2.ZERO
    player.movement_speed = 200.0
    add_child_autofree(player)

    # Act - 执行被测试的操作
    player.move_direction(Vector2.RIGHT)
    player._physics_process(1.0)  # 1秒时间

    # Assert - 验证结果
    assert_eq(player.position.x, 200.0, "Player should move 200 units in 1 second")
    assert_eq(player.position.y, 0.0, "Player should not move vertically")
```

### 4. 测试数据工厂模式
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
    add_child_autofree(player)

    assert_eq(player.health, 100)
    assert_eq(player.position, Vector2.ZERO)
```

### 5. Mock 和 Double 使用技巧
```gdscript
# 使用 Double 隔离外部依赖
func test_player_with_mocked_input():
    var PlayerClass = preload("res://scripts/Player.gd")
    var player = double(PlayerClass).new()

    # 模拟输入系统
    stub(player, "is_action_pressed").to_return(true, ["move_right"])
    stub(player, "get_action_strength").to_return(1.0, ["move_right"])

    add_child_autofree(player)

    player._physics_process(0.016)

    assert_called(player, "is_action_pressed", ["move_right"])
    assert_gt(player.velocity.x, 0)

# Partial Double 保留关键行为
func test_weapon_with_partial_double():
    var WeaponClass = preload("res://scripts/Weapon.gd")
    var weapon = partial_double(WeaponClass).new()

    # 保留原始的 calculate_damage 方法
    # 只模拟 fire 方法的视觉效果
    stub(weapon, "create_muzzle_flash").to_do_nothing()

    add_child_autofree(weapon)

    weapon.fire()

    assert_called(weapon, "create_muzzle_flash")
    assert_true(weapon.is_firing)
```

### 6. 信号测试模式
```gdscript
# 基础信号测试
func test_health_changed_signal():
    var health_component = HealthComponent.new()
    var signal_received = false
    var received_health = 0

    health_component.health_changed.connect(func(health):
        signal_received = true
        received_health = health
    )

    add_child_autofree(health_component)

    health_component.take_damage(30)

    assert_true(signal_received, "Health changed signal should be emitted")
    assert_eq(received_health, 70, "Signal should carry correct health value")
    assert_signal_emitted(health_component, "health_changed", [70])

# 带参数的复杂信号测试
func test_inventory_item_added_signal():
    var inventory = Inventory.new()
    var item = Item.new()
    item.name = "Health Potion"
    item.quantity = 5

    var signal_data = null
    inventory.item_added.connect(func(item_data, slot):
        signal_data = {item = item_data, slot = slot}
    )

    add_child_autofree(inventory)

    var success = inventory.add_item(item)

    assert_true(success, "Item should be added successfully")
    assert_not_null(signal_data, "Signal data should be received")
    assert_eq(signal_data.item.name, "Health Potion")
    assert_eq(signal_data.item.quantity, 5)
    assert_signal_emitted_with_parameters(inventory, "item_added", [item, 0])
```

### 7. 参数化测试和数据驱动测试
```gdscript
# 使用参数数组测试多种情况
var damage_test_params = [
    [10, 90, false],  # [伤害, 预期剩余健康, 是否死亡]
    [50, 50, false],
    [100, 0, true],
    [150, 0, true]    # 过额伤害
]

func test_player_takes_damage(params = use_parameters(damage_test_params)):
    var player = Player.new()
    player.health = 100
    var damage = params[0]
    var expected_health = params[1]
    var should_die = params[2]

    add_child_autofree(player)

    player.take_damage(damage)

    assert_eq(player.health, expected_health, "Health should be %d after %d damage" % [expected_health, damage])
    assert_eq(player.is_dead(), should_die, "Player death state should be %s" % should_die)

    if should_die:
        assert_signal_emitted(player, "player_died")
```

### 8. 边界条件和错误处理测试
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

func test_inventory_error_handling():
    var inventory = Inventory.new()
    inventory.capacity = 2

    # 填满库存
    inventory.add_item(Item.new())
    inventory.add_item(Item.new())

    var extra_item = Item.new()
    var result = inventory.add_item(extra_item)

    assert_false(result.success, "Adding to full inventory should fail")
    assert_eq(result.error_code, "INVENTORY_FULL", "Should return appropriate error")
    assert_eq(inventory.get_item_count(), 2, "Inventory size should remain unchanged")
```

### 9. 性能测试模式
```gdscript
func test_pathfinding_performance():
    var pathfinder = Pathfinder.new()
    var grid_size = 100
    var start_pos = Vector2i(0, 0)
    var end_pos = Vector2i(grid_size - 1, grid_size - 1)

    # 设置测试网格
    pathfinder.setup_grid(grid_size, grid_size)

    # 性能测试
    reset_start_times()
    var path = pathfinder.find_path(start_pos, end_pos)
    var elapsed_time = get_elapsed_test_time()

    # 验证性能要求
    assert_lt(elapsed_time, 0.1, "Pathfinding should complete within 100ms")
    assert_not_null(path, "Path should be found")
    assert_gt(path.size(), 0, "Path should contain waypoints")
```

### 10. 测试反模式和避免方法
```gdscript
# ❌ 反模式：测试实现细节（脆弱）
func test_player_internal_velocity():
    var player = Player.new()
    player._velocity = Vector2(100, 0)  # 直接访问内部状态
    player._process(1.0)
    assert_eq(player.position.x, 100)

# ✅ 正确模式：测试公共接口（稳定）
func test_player_moves_right():
    var player = Player.new()
    player.move_direction(Vector2.RIGHT)
    player._process(1.0)
    assert_eq(player.position.x, 100)

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

## 🎨 UI开发建议

### 1. 响应式设计
```gdscript
# 使用锚点和容器
func setup_responsive_ui():
    # 使用容器自动布局
    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 10)

    # 设置锚点
    button.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
```

### 2. UI主题
```gdscript
# 创建一致的UI主题
@export var ui_theme: Theme

func _ready():
    # 应用主题到所有控件
    apply_theme_recursively(self, ui_theme)

func apply_theme_recursively(node: Node, theme: Theme):
    if node is Control:
        node.theme = theme
    for child in node.get_children():
        apply_theme_recursively(child, theme)
```