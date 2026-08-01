# GDScript 开发规范

> 本文档为只读文档。
> Godot 4.x / GDScript 编码规范。AI 在**阶段 8（TDD 开发）**编码时**必须**加载并遵循本规范；**阶段 7（架构设计）**参考架构相关条目（状态机/对象池/数据驱动）。
> 每条含：规范说明 + 正例（✅）+ 反例（❌）。

---

## 一、命名约定

### 1. 类与文件命名

**说明**：类名 PascalCase，文件名 snake_case.gd；一个脚本定义一个 `class_name`。

**正例**（✅）：
```gdscript
class_name PlayerController
extends CharacterBody2D
# 文件：player_controller.gd
```

**反例**（❌）：
```gdscript
class_name playerController      # 类名应 PascalCase
# 文件：PlayerController.gd      # 文件名应 snake_case
```

### 2. 变量与函数命名

**说明**：变量、函数用 snake_case；私有成员以单下划线 `_` 前缀。

**正例**（✅）：
```gdscript
var current_health: int = 100
var _internal_counter: int = 0

func calculate_damage(base: int) -> int:
    return base * 2

func _private_helper() -> void:
    pass
```

**反例**（❌）：
```gdscript
var CurrentHealth = 100          # 变量应 snake_case + 类型
var internalCounter = 0          # 私有应 _ 前缀

func CalculateDamage():          # 函数应 snake_case + 返回类型
    pass
```

### 3. 常量与信号命名

**说明**：常量 SCREAMING_SNAKE_CASE；信号用过去式 snake_case，描述"发生了什么"。

**正例**（✅）：
```gdscript
const MAX_SPEED: float = 200.0
const JUMP_FORCE: int = -400

signal health_changed(new_health: int)
signal player_died
signal item_collected(item: Item)
```

**反例**（❌）：
```gdscript
const maxSpeed = 200.0           # 常量应 SCREAMING + 类型
const JumpForce = -400

signal update_health             # 信号应用过去式
signal die                       # 语义不清
```

---

## 二、类型系统

### 4. 变量静态类型提示

**说明**：所有变量显式标注类型，启用静态检查与自动补全。

**正例**（✅）：
```gdscript
var speed: float = 100.0
var player: CharacterBody2D
var items: Array[Item] = []
var stats: Dictionary = {}
```

**反例**（❌）：
```gdscript
var speed = 100.0                # 缺类型
var player                       # 缺类型
var items = []                   # 缺类型与元素类型
```

### 5. 函数签名类型

**说明**：函数参数与返回值标注类型。

**正例**（✅）：
```gdscript
func get_damage() -> int:
    return _base * _multiplier

func find_nearest_enemy(pos: Vector2) -> Enemy:
    return null
```

**反例**（❌）：
```gdscript
func get_damage():               # 缺返回类型
    return _base * _multiplier

func find_nearest_enemy(pos):    # 缺参数与返回类型
    return null
```

---

## 三、节点与引用

### 6. @onready 节点引用

**说明**：用 `@onready` + 类型提示获取节点引用，避免在 `_ready()` 内 `get_node()`。

**正例**（✅）：
```gdscript
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var sprite: Sprite2D = $Sprite2D
@onready var weapon: Weapon = $WeaponMount/Weapon
```

**反例**（❌）：
```gdscript
func _ready() -> void:
    var sprite = get_node("Sprite2D")   # 应用 @onready + 类型
```

### 7. 唯一节点名 %

**说明**：关键节点用 `%` 唯一名引用，避免深层脆弱路径（层级 ≤ 3-4）。

**正例**（✅）：
```gdscript
@onready var player: Player = %Player
@onready var animation: AnimationPlayer = %AnimationPlayer
```

**反例**（❌）：
```gdscript
@onready var thing = $Parent/Child/GrandChild/GreatGrandChild  # 脆弱深路径 + 缺类型
```

### 8. is_instance_valid 替代 null 检查

**说明**：判断节点是否有效（含未释放）用 `is_instance_valid()`，而非 `!= null`（已释放节点仍可能 `!= null`）。

**正例**（✅）：
```gdscript
if is_instance_valid(target):
    target.take_damage(10)
```

**反例**（❌）：
```gdscript
if target != null:               # 已释放节点仍可能为 true，崩溃风险
    target.take_damage(10)
```

---

## 四、信号与通信

### 9. 类型化信号

**说明**：信号带类型参数，用 `.emit()` 触发，不用字符串 `emit_signal()`。

**正例**（✅）：
```gdscript
signal health_changed(current: int, maximum: int)
signal died

func take_damage(amount: int) -> void:
    _health = max(0, _health - amount)
    health_changed.emit(_health, _max_health)
    if _health <= 0:
        died.emit()
```

**反例**（❌）：
```gdscript
signal health_changed            # 缺参数类型
emit_signal("health_changed")    # 字符串易错、无补全
```

### 10. 信号向上、调用向下（signal up, call down）

**说明**：子节点发信号，父节点连接并调用子节点方法；禁止子节点 `get_parent()` 反向调用。

**正例**（✅）：
```gdscript
# 子节点 Health
signal died

# 父节点 Player
func _ready() -> void:
    $Health.died.connect(_on_died)

func _on_died() -> void:
    queue_free()
```

**反例**（❌）：
```gdscript
# 子节点直接调用父节点 —— 紧耦合
func die() -> void:
    get_parent().on_child_died()      # 禁止
    get_parent().get_parent().x()     # 更脆弱
```

---

## 五、资源与数据

### 11. 资源加载策略

**说明**：小/关键资源 `preload()`；运行时可选/大资源用 `load()` 或 `ResourceLoader` 异步加载；禁止在 `_process` 内加载。

**正例**（✅）：
```gdscript
const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn")

func load_level_async(path: String) -> void:
    ResourceLoader.load_threaded_request(path)
```

**反例**（❌）：
```gdscript
func _process(delta: float) -> void:
    var tex = load("res://textures/big.png")  # 每帧加载，卡顿 + 内存抖动
```

### 12. Resource 数据驱动

**说明**：静态数据用自定义 Resource（`@export` 字段 + `.tres` 实例），不要在脚本里硬编码 const 数据。

**正例**（✅）：
```gdscript
# scripts/resources/item_data.gd
class_name ItemData
extends Resource
@export var id: String
@export var damage: int = 10

# data/sword.tres = ItemData 的实例（取值与代码分离）
```

**反例**（❌）：
```gdscript
const SWORD_DAMAGE = 10                    # 应抽到 Resource
const POTION_HEAL = 20
const ITEMS = {"sword": {"damage": 10}}    # 硬编码字典数据
```

---

## 六、脚本结构

### 13. 脚本区块顺序

**说明**：按固定顺序组织：`class_name`/`extends` → 文档注释 → signals → enums → exports → constants → public vars → private vars → `@onready` → lifecycle → public methods → private methods。

**正例**（✅）：
```gdscript
class_name Player
extends CharacterBody2D
## 玩家控制器。

signal died

enum State { IDLE, RUN }

@export var speed: float = 100.0
const MAX_HEALTH: int = 100
var current_state: State = State.IDLE
var _counter: int = 0
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    pass

func take_damage(amount: int) -> void:
    pass

func _calculate() -> void:
    pass
```

**反例**（❌）：
```gdscript
# 顺序混乱：变量、信号、函数穿插
var x: int = 0
signal foo
func _ready() -> void: pass
const Y: int = 1
@export var z: float = 0.0
```

### 14. @export 分组与范围

**说明**：编辑器可配置值用 `@export`，相关参数用 `@export_group` 分组，数值用 `@export_range` 约束。

**正例**（✅）：
```gdscript
@export_group("Movement")
@export var walk_speed: float = 100.0
@export_range(0.0, 1.0, 0.1) var friction: float = 0.8

@export_group("Combat")
@export var damage: int = 10
```

**反例**（❌）：
```gdscript
@export var walk_speed = 100.0    # 缺类型、缺分组
@export var friction = 0.8        # 缺范围约束
@export var damage = 10
```

---

## 七、常用模式

### 15. 枚举状态机

**说明**：简单状态用 enum + match；状态多/复杂时拆为独立状态节点。

**正例**（✅）：
```gdscript
enum State { IDLE, WALK, JUMP }
var current_state: State = State.IDLE

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE: _process_idle(delta)
        State.WALK: _process_walk(delta)

func change_state(new_state: State) -> void:
    if current_state == new_state:
        return
    _exit_state(current_state)
    current_state = new_state
    _enter_state(new_state)
```

**反例**（❌）：
```gdscript
var state = "idle"               # 字符串状态易错
func _physics_process(delta: float) -> void:
    if state == "idle":          # 散落 if/elif 难维护
        pass
    elif state == "walk":
        pass
```

### 16. 对象池

**说明**：频繁创建销毁的对象（子弹、粒子）用对象池复用，避免反复实例化卡顿。

**正例**（✅）：
```gdscript
var _pool: Array[Node] = []

func acquire() -> Node:
    if _pool.is_empty():
        return _scene.instantiate()
    var obj := _pool.pop_back()
    obj.set_process(true)
    return obj

func release(obj: Node) -> void:
    obj.set_process(false)
    _pool.append(obj)
```

**反例**（❌）：
```gdscript
func shoot() -> void:
    var b := bullet_scene.instantiate()   # 每次新建
    add_child(b)
# 子弹消亡直接 queue_free()，反复实例化造成卡顿
```

### 17. 存档系统（Resource）

**说明**：存档数据用自定义 Resource + `ResourceSaver`/`ResourceLoader`，存到 `user://`（可写）；禁止存到 `res://`（只读）。

**正例**（✅）：
```gdscript
class_name SaveData
extends Resource
@export var player_position: Vector2
@export var level_name: String

func save_game(data: SaveData) -> void:
    ResourceSaver.save(data, "user://save.tres")

func load_game() -> SaveData:
    if ResourceLoader.exists("user://save.tres"):
        return load("user://save.tres") as SaveData
    return SaveData.new()
```

**反例**（❌）：
```gdscript
ResourceSaver.save(data, "res://save.tres")   # res:// 只读，打包后无法写
```

### 18. 协程 await

**说明**：异步用 `await`，禁用已废弃的 `yield`（Godot 3 语法）。

**正例**（✅）：
```gdscript
func teleport_after(delay: float) -> void:
    await get_tree().create_timer(delay).timeout
    position = Vector2.ZERO

await %AnimationPlayer.animation_finished
```

**反例**（❌）：
```gdscript
yield(get_tree().create_timer(1.0), "timeout")   # Godot 3 废弃语法
```

---

## 八、性能与反模式

### 19. 避免轮询，用信号

**说明**：状态变化用信号通知，不要在 `_process` 内反复检查同一条件。

**正例**（✅）：
```gdscript
# 数值变化时发信号，监听者响应
health_changed.emit(_health)
```

**反例**（❌）：
```gdscript
func _process(delta: float) -> void:
    if enemy.health <= 0:        # 每帧轮询，浪费 CPU
        game_over()
```

### 20. 避免魔法数字

**说明**：裸数字/字符串用 `const` 或 `@export` 命名，赋予语义。

**正例**（✅）：
```gdscript
const MAX_JUMP_VELOCITY: float = -600.0
@export var attack_range: float = 50.0
velocity.y = MAX_JUMP_VELOCITY
```

**反例**（❌）：
```gdscript
velocity.y = -600.0             # 含义不明
if state == 2:                   # 魔法数字
    pass
```

### 21. Autoload 保持精瘦

**说明**：autoload 只放全局服务（AudioManager/SaveManager），不放游戏逻辑；保持可测试、低耦合。

**正例**（✅）：
```gdscript
# scripts/autoloads/audio_manager.gd
class_name AudioManager
extends Node
func play_sfx(stream: AudioStream) -> void:
    pass
```

**反例**（❌）：
```gdscript
# autoload 塞满游戏状态 —— 难测试、紧耦合
class_name GameManager
extends Node
var player_health: int           # 应在 Player 上
var current_level: int           # 应在 LevelManager 上
func spawn_enemy() -> void:      # 应在 EnemySpawner 上
    pass
```

### 22. 避免循环依赖

**说明**：类之间禁止互相 `preload` 导致加载错误；用信号或依赖注入解耦。

**正例**（✅）：
```gdscript
# 通过信号通信，互不直接引用
signal target_acquired(target: Node2D)
```

**反例**（❌）：
```gdscript
# a.gd 与 b.gd 互相 preload —— 循环依赖加载错误
const B = preload("res://scripts/b.gd")
```

---

## 九、文档与注释

### 23. 信号与函数必须有中文注释

**说明**：所有信号声明与函数定义**必须**有中文注释说明其用途；函数用 Godot 文档注释 `##`（显示在编辑器悬停、可生成文档），信号同样用 `##` 说明触发时机与参数含义。私有函数（`_` 前缀）也不例外。

**正例**（✅）：
```gdscript
## 玩家生命值变化时发出。
## [param current] 当前生命值 [param maximum] 最大生命值
signal health_changed(current: int, maximum: int)

## 玩家死亡信号。
signal died

## 对自身造成伤害。
func take_damage(amount: int) -> void:
    pass

## 计算击退方向（私有辅助）。
func _calculate_knockback() -> Vector2:
    return Vector2.ZERO
```

**反例**（❌）：
```gdscript
signal health_changed(current: int, maximum: int)   # 无注释
signal died

func take_damage(amount: int) -> void:              # 无注释
    pass

func _calculate_knockback() -> Vector2:             # 私有函数也必须有注释
    return Vector2.ZERO
```

---

## 十、代码格式

### 24. 函数定义上方保留 2 个空行

**说明**：每个 `func` 定义上方保留 **2 个空行**，使函数边界清晰、便于快速定位；函数内部逻辑块之间保留 1 个空行。变量声明区块与首个 `func` 之间也应有 2 个空行。

**正例**（✅）：
```gdscript
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
    _init_stats()


func take_damage(amount: int) -> void:
    _health -= amount


func _calculate() -> Vector2:
    return Vector2.ZERO
```

**反例**（❌）：
```gdscript
@onready var sprite: Sprite2D = $Sprite2D
func _ready() -> void:                       # 变量与函数间无空行
    pass
func take_damage(amount: int) -> void:      # 函数间无空行，边界模糊
    _health -= amount

func _calculate() -> Vector2:               # 仅1空行，不够醒目
    return Vector2.ZERO
```

---

## 附：快速自查清单

编码完成、提交前逐条核对：

- [ ] 类名 PascalCase、文件/变量/函数 snake_case、常量 SCREAMING
- [ ] 所有变量、参数、返回值、信号有类型提示
- [ ] 节点引用用 `@onready` + 类型；关键节点用 `%`
- [ ] 信号类型化 + `.emit()`；子发信号父监听，无 `get_parent()` 调用
- [ ] 无 `_process` 内 `load()`；数据用 Resource 而非硬编码 const
- [ ] 脚本区块顺序正确；`@export` 分组 + 范围约束
- [ ] 无 `yield`、无 `!= null` 判节点、无魔法数字、无循环依赖
- [ ] 所有信号与函数均有中文注释（`##` 文档注释）
- [ ] 每个 `func` 上方有 2 个空行
