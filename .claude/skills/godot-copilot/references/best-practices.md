# Godot最佳实践指南

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