# Godot开发最佳实践

## 项目组织

### 目录结构标准
```
project.godot
├── scenes/           # 场景文件(.tscn)
│   ├── main/         # 主要场景
│   ├── ui/           # UI场景
│   ├── characters/   # 角色场景
│   ├── environments/ # 环境场景
│   └── effects/      # 特效场景
├── scripts/          # 脚本文件(.gd)
│   ├── core/         # 核心系统
│   ├── characters/   # 角色脚本
│   ├── ui/           # UI脚本
│   ├── managers/     # 管理器脚本
│   └── utils/        # 工具脚本
├── assets/           # 资源文件
│   ├── textures/     # 纹理图片
│   ├── audio/        # 音频文件
│   ├── fonts/        # 字体文件
│   ├── materials/    # 材质文件
│   └── models/       # 3D模型
├── data/             # 数据文件
│   ├── levels/       # 关卡数据
│   ├── config/       # 配置文件
│   └── localization/ # 本地化文件
└── export/           # 导出配置
```

### 命名规范

#### 文件命名
- **场景文件**：PascalCase (Player.tscn, MainMenu.tscn)
- **脚本文件**：PascalCase (Player.gd, GameManager.gd)
- **纹理文件**：snake_case (player_idle.png, bg_main_menu.jpg)
- **音频文件**：snake_case (sfx_jump.wav, bgm_level_1.ogg)
- **常量文件**：UPPER_SNAKE_CASE (MAX_HEALTH, GAME_VERSION)

#### 节点命名
- **场景根节点**：使用场景名称 (Player, Enemy, UI)
- **功能节点**：描述性命名 (HealthBar, JumpButton, SpawnPoint)
- **容器节点**：类型后缀 (ButtonsContainer, ItemsGrid, OptionsPanel)

#### 变量命名
- **私有变量**：下划线前缀 (_health, _is_dead)
- **导出变量**：描述性名称 (move_speed, jump_height)
- **常量**：大写加下划线 (MAX_LIVES, GRAVITY)
- **枚举**：PascalCase (State.IDLE, State.RUNNING)

## 代码设计原则

### 单一职责原则
```gdscript
# 好的示例 - 每个脚本只负责一个功能
extends CharacterBody2D

# 只处理移动相关逻辑
func _physics_process(delta):
    handle_movement(delta)
    apply_gravity(delta)

func handle_movement(delta):
    # 移动逻辑
    pass

func apply_gravity(delta):
    # 重力逻辑
    pass

# 其他功能委托给对应的组件
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_component: AnimationComponent = $AnimationComponent
```

### 开放封闭原则
```gdscript
# 好的示例 - 可扩展的设计
class_name WeaponBase
extends Node

# 基础武器接口
virtual func use():
    pass

virtual func reload():
    pass

# 具体武器实现
class Pistol extends WeaponBase:
    func use():
        # 手枪射击逻辑
        pass

class Rifle extends WeaponBase:
    func use():
        # 步枪射击逻辑
        pass
```

### 依赖注入
```gdscript
# 好的示例 - 通过构造函数或方法注入依赖
class_name GameManager
extends Node

@export var player_scene: PackedScene
@export var enemy_spawner: EnemySpawner
@export var ui_manager: UIManager

func start_game():
    var player = player_scene.instantiate()
    enemy_spawner.set_target(player)
    ui_manager.set_player_reference(player)
```

## 性能优化

### 渲染优化

#### 1. 批处理优化
```gdscript
# 避免频繁的绘制调用
func _draw():
    # 坏的示例 - 多次绘制相似对象
    for i in range(100):
        draw_circle(Vector2(i * 10, 0), 5, Color.RED)

# 好的示例 - 使用批处理
func _draw():
    # 合并相似对象的绘制
    var points = []
    for i in range(100):
        points.append(Vector2(i * 10, 0))
    draw_multiline(points, Color.RED)
```

#### 2. 纹理优化
```gdscript
# 使用纹理图集减少状态切换
@export var texture_atlas: Texture2D

func get_sprite_rect(index: int) -> Rect2:
    var sprite_width = 32
    var sprite_height = 32
    var atlas_width = texture_atlas.get_width()
    var sprites_per_row = atlas_width / sprite_width
    
    var x = (index % sprites_per_row) * sprite_width
    var y = (index / sprites_per_row) * sprite_height
    
    return Rect2(x, y, sprite_width, sprite_height)
```

#### 3. LOD系统
```gdscript
# 距离相关的细节层次
func _process(delta):
    var distance_to_camera = global_position.distance_to(camera.global_position)
    
    if distance_to_camera < 50:
        mesh.mesh = high_detail_mesh
    elif distance_to_camera < 200:
        mesh.mesh = medium_detail_mesh
    else:
        mesh.mesh = low_detail_mesh
```

### 内存优化

#### 1. 对象池模式
```gdscript
# 好的示例 - 对象池管理
class_name BulletPool
extends Node

@export var bullet_scene: PackedScene
@export var pool_size: int = 50

var available_bullets: Array[Bullet] = []
var active_bullets: Array[Bullet] = []

func _ready():
    for i in range(pool_size):
        var bullet = bullet_scene.instantiate()
        add_child(bullet)
        bullet.set_process(false)
        available_bullets.append(bullet)

func spawn_bullet(position: Vector2, direction: Vector2):
    var bullet: Bullet
    if available_bullets.size() > 0:
        bullet = available_bullets.pop_back()
    else:
        # 扩展池大小
        bullet = bullet_scene.instantiate()
        add_child(bullet)
    
    bullet.global_position = position
    bullet.direction = direction
    bullet.set_process(true)
    active_bullets.append(bullet)

func return_bullet(bullet: Bullet):
    bullet.set_process(false)
    active_bullets.erase(bullet)
    available_bullets.append(bullet)
```

#### 2. 资源管理
```gdscript
# 好的示例 - 资源的懒加载和释放
class_name ResourceManager
extends Node

var loaded_resources: Dictionary = {}

func get_resource(path: String) -> Resource:
    if not loaded_resources.has(path):
        loaded_resources[path] = load(path)
    return loaded_resources[path]

func unload_resource(path: String):
    if loaded_resources.has(path):
        loaded_resources.erase(path)
        # 强制垃圾回收
        call_deferred("_force_gc")

func _force_gc():
    # 手动触发垃圾回收
    var dummy = []
    dummy.clear()
```

### 计算优化

#### 1. 缓存计算结果
```gdscript
# 好的示例 - 缓存昂贵的计算
extends Node

var _cached_path: Array[Vector2] = []
var _last_start_pos: Vector2
var _last_end_pos: Vector2

func find_path(start: Vector2, end: Vector2) -> Array[Vector2]:
    if start == _last_start_pos and end == _last_end_pos:
        return _cached_path
    
    _cached_path = _calculate_path(start, end)
    _last_start_pos = start
    _last_end_pos = end
    
    return _cached_path

func _calculate_path(start: Vector2, end: Vector2) -> Array[Vector2]:
    # 实际的寻路算法
    pass
```

#### 2. 空间分割
```gdscript
# 好的示例 - 使用四叉树优化碰撞检测
class_name QuadTree
extends Node2D

var boundary: Rect2
var capacity: int = 4
var objects: Array[Node2D] = []
var divided: bool = false

var northeast: QuadTree
var northwest: QuadTree
var southeast: QuadTree
var southwest: QuadTree

func insert(object: Node2D) -> bool:
    if not boundary.has_point(object.global_position):
        return false
    
    if objects.size() < capacity:
        objects.append(object)
        return true
    
    if not divided:
        subdivide()
    
    return northeast.insert(object) or northwest.insert(object) or \
           southeast.insert(object) or southwest.insert(object)
```

## 错误处理和调试

### 错误处理模式

#### 1. 防御性编程
```gdscript
# 好的示例 - 输入验证
func deal_damage(target: Node, amount: int):
    # 验证目标
    if not target or not is_instance_valid(target):
        push_error("Invalid target for deal_damage")
        return
    
    # 验证伤害值
    if amount < 0:
        push_warning("Negative damage amount: %d" % amount)
        amount = 0
    
    # 验证目标是否有健康组件
    if not target.has_method("take_damage"):
        push_error("Target does not have take_damage method")
        return
    
    target.take_damage(amount)
```

#### 2. 优雅降级
```gdscript
# 好的示例 - 备用方案
func load_high_score() -> int:
    # 尝试从文件加载
    var file = FileAccess.open("user://high_score.save", FileAccess.READ)
    if file:
        var score = file.get_32()
        file.close()
        return score
    
    # 文件不存在，使用默认值
    print("High score file not found, using default value")
    return 0
```

### 调试技巧

#### 1. 可视化调试
```gdscript
# 好的示例 - 调试绘制
func _draw():
    if not Engine.is_editor_hint() and not debug_mode:
        return
    
    # 绘制路径
    if current_path.size() > 1:
        draw_polyline(current_path, Color.BLUE, 2.0)
    
    # 绘制检测范围
    draw_circle(Vector2.ZERO, detection_radius, Color.YELLOW, false, 2.0)
    
    # 绘制方向指示
    draw_line(Vector2.ZERO, direction * 50, Color.RED, 3.0)
```

#### 2. 性能分析
```gdscript
# 好的示例 - 性能监控
extends Node

var frame_times: Array[float] = []
var max_samples: int = 60

func _process(delta):
    frame_times.append(delta * 1000.0)  # 转换为毫秒
    
    if frame_times.size() > max_samples:
        frame_times.pop_front()
    
    if Input.is_action_just_pressed("debug_performance"):
        print_performance_stats()

func print_performance_stats():
    var total_time = 0.0
    var min_time = INF
    var max_time = -INF
    
    for time in frame_times:
        total_time += time
        min_time = min(min_time, time)
        max_time = max(max_time, time)
    
    var avg_time = total_time / frame_times.size()
    var fps = 1000.0 / avg_time
    
    print("=== Performance Stats ===")
    print("FPS: %.1f" % fps)
    print("Frame Time: Avg=%.2fms, Min=%.2fms, Max=%.2fms" % [avg_time, min_time, max_time])
    print("========================")
```

## 架构模式

### 状态机模式
```gdscript
# 好的示例 - 状态机实现
class_name StateMachine
extends Node

var current_state: State
var states: Dictionary = {}

func _ready():
    # 初始化状态
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.state_machine = self

func change_state(state_name: String):
    if not states.has(state_name):
        push_error("State not found: " + state_name)
        return
    
    if current_state:
        current_state.exit()
    
    current_state = states[state_name]
    current_state.enter()

# 基础状态类
class_name State
extends Node

var state_machine: StateMachine

func enter():
    pass

func exit():
    pass

func process(delta):
    pass

func physics_process(delta):
    pass
```

### 观察者模式
```gdscript
# 好的示例 - 事件系统
class_name EventManager
extends Node

# 单例模式
static var instance: EventManager

var listeners: Dictionary = {}

func _ready():
    instance = self

func register_event(event_name: String, callback: Callable):
    if not listeners.has(event_name):
        listeners[event_name] = []
    
    listeners[event_name].append(callback)

func unregister_event(event_name: String, callback: Callable):
    if listeners.has(event_name):
        listeners[event_name].erase(callback)

func emit_event(event_name: String, args: Array = []):
    if not listeners.has(event_name):
        return
    
    for callback in listeners[event_name]:
        callback.callv(args)

# 使用示例
func _ready():
    EventManager.instance.register_event("player_died", _on_player_died)

func _on_player_died():
    EventManager.instance.emit_event("show_game_over")
```

### 工厂模式
```gdscript
# 好的示例 - 敌人工厂
class_name EnemyFactory
extends Node

var enemy_scenes: Dictionary = {
    "goblin": preload("res://scenes/enemies/Goblin.tscn"),
    "orc": preload("res://scenes/enemies/Orc.tscn"),
    "dragon": preload("res://scenes/enemies/Dragon.tscn")
}

func create_enemy(enemy_type: String, position: Vector2) -> Enemy:
    if not enemy_scenes.has(enemy_type):
        push_error("Unknown enemy type: " + enemy_type)
        return null
    
    var enemy_scene = enemy_scenes[enemy_type]
    var enemy = enemy_scene.instantiate()
    
    enemy.global_position = position
    
    # 根据类型配置属性
    match enemy_type:
        "goblin":
            enemy.health = 50
            enemy.damage = 10
        "orc":
            enemy.health = 100
            enemy.damage = 20
        "dragon":
            enemy.health = 500
            enemy.damage = 50
    
    return enemy
```

## 测试策略

### 单元测试
```gdscript
# 好的示例 - 测试用例
extends "res://addons/gut/test.gd"

func before_each():
    # 测试前准备
    player = Player.new()
    add_child(player)

func after_each():
    # 测试后清理
    player.queue_free()

func test_player_initial_health():
    assert_eq(player.health, 100, "Player should start with 100 health")

func test_take_damage():
    player.take_damage(30)
    assert_eq(player.health, 70, "Player health should be reduced by damage amount")

func test_death():
    player.take_damage(150)
    assert_true(player.is_dead, "Player should be dead when health reaches 0")
```

### 集成测试
```gdscript
# 好的示例 - 集成测试场景
extends Node

func run_integration_tests():
    test_player_enemy_collision()
    test_projectile_damage()
    test_ui_health_display()

func test_player_enemy_collision():
    # 设置测试场景
    var player = create_test_player(Vector2(100, 100))
    var enemy = create_test_enemy(Vector2(120, 100))
    
    # 运行物理帧
    for i in range(10):
        get_tree().physics_frame += 1
        player._physics_process(0.016)
        enemy._physics_process(0.016)
    
    # 验证结果
    assert_true(player.health < 100, "Player should take damage from enemy collision")
```

这些最佳实践将帮助您创建高质量、可维护、性能优良的Godot游戏项目。记住，好的代码不仅能够正常运行，还应该易于理解、修改和扩展。