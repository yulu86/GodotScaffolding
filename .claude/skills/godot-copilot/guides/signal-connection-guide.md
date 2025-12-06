# Godot信号连接详细指导

## 概述

信号是Godot的核心特性之一，用于实现对象之间的通信。本指南提供了连接信号的详细步骤和最佳实践。

## 理解信号

### 什么是信号？

信号是Godot的观察者模式实现，允许对象发出通知，其他对象可以"监听"这些通知并响应。

### 信号的类型

1. **内置信号**：引擎定义的信号
2. **自定义信号**：用户定义的信号
3. **信号参数**：信号可以携带数据

## 连接信号的方法

### 方法1：通过编辑器界面连接（推荐）

#### 连接内置信号（以Button为例）

1. **选择发出信号的节点**
   ```
   在场景树中选择Button节点
   或在2D/3D视图中点击该节点
   ```

2. **打开节点面板**
   - 在检查器右侧点击"节点"标签
   - 或右键节点 → "连接信号"

3. **找到目标信号**
   ```
   在信号列表中找到需要的信号：
   ├─ button_down     # 鼠标按下
   ├─ button_up       # 鼠标释放
   ├─ pressed         # 点击（按下+释放）
   ├─ toggled         # 切换状态（切换按钮）
   └─ ...             # 其他信号
   ```

4. **连接信号**
   - 双击信号名称（例如：pressed）
   - 或选中信号后点击底部的"连接"按钮

5. **选择接收对象**
   - 选择要接收信号的节点
   - 通常选择同一场景中的其他节点
   - 或选择场景根节点

6. **确认连接设置**
   - **接收节点**：自动填充，可更改
   - **接收方法**：自动生成，可修改
   - **高级设置**：
     - `一次性`：只触发一次后自动断开
     - `延迟调用`：延迟一帧执行

7. **完成连接**
   - 点击"连接"按钮
   - Godot会自动在接收节点的脚本中创建方法

#### 示例：连接Button的pressed信号

```
1. 选择Button节点
2. 打开节点面板
3. 双击"pressed"信号
4. 选择接收节点（例如UIManager）
5. 方法名自动生成为：_on_button_pressed
6. 点击"连接"
```

### 方法2：通过代码连接

#### 基础语法

```gdscript
# 发出信号
signal_name.connect("method_name")

# 带参数的信号
signal_name.connect("method_name", [args])

# 使用lambda函数
signal_name.connect(func(): print("Signal received"))
```

#### 在_ready()中连接

```gdscript
extends Node

@onready var button: Button = $Button
@onready var player: CharacterBody2D = $Player

func _ready():
    # 连接按钮点击
    button.pressed.connect(_on_button_pressed)

    # 连接玩家信号
    player.health_changed.connect(_on_player_health_changed)

func _on_button_pressed():
    print("按钮被点击了")

func _on_player_health_changed(new_health):
    update_health_display(new_health)
```

#### 使用Callable包装器

```gdscript
func _ready():
    # 使用Callable包装器
    button.pressed.connect(Callable(self, "_on_button_pressed"))

    # 使用lambda
    timer.timeout.connect(func():
        spawn_enemy()
        timer.start()
    )
```

### 方法3：通过拖拽连接

1. **打开信号面板**
   - 选择发出信号的节点
   - 在检查器中打开"节点"标签

2. **拖拽信号**
   - 从信号列表拖拽到场景树中的接收节点
   - 释放鼠标
   - 自动创建连接

## 创建自定义信号

### 定义信号

```gdscript
# 在脚本中定义信号
signal health_changed(new_health: int)
signal died
signal item_collected(item_name: String, quantity: int)

# 带默认参数的信号
signal score_updated(score: int, combo: int = 1)
```

### 发出信号

```gdscript
class_name Player
extends CharacterBody2D

# 定义信号
signal health_changed(new_health: int)
signal died
signal level_up(new_level: int)

func take_damage(damage: int):
    current_health -= damage
    # 发出信号
    health_changed.emit(current_health)

    if current_health <= 0:
        died.emit()

func gain_experience(exp: int):
    experience += exp
    if experience >= next_level_exp:
        level += 1
        level_up.emit(level)
```

### 连接自定义信号

```gdscript
extends Node

@onready var player: Player = $Player
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var game_over_screen: Control = $UI/GameOver

func _ready():
    # 连接玩家信号
    player.health_changed.connect(_on_player_health_changed)
    player.died.connect(_on_player_died)
    player.level_up.connect(_on_player_level_up)

func _on_player_health_changed(new_health: int):
    health_bar.value = new_health

func _on_player_died():
    game_over_screen.show()
    get_tree().paused = true

func _on_player_level_up(new_level: int):
    show_level_up_effect()
    print("恭喜升级到等级 %d!" % new_level)
```

## 常见信号示例

### Button信号
```gdscript
# 按钮节点
@onready var start_button: Button = $UI/StartButton

func _ready():
    # 各种按钮信号
    start_button.pressed.connect(_on_start_button_pressed)
    start_button.button_down.connect(_on_button_down)
    start_button.button_up.connect(_on_button_up)
```

### Timer信号
```gdscript
# 计时器节点
@onready var spawn_timer: Timer = $SpawnTimer
@onready var countdown_timer: Timer = $CountdownTimer

func _ready():
    spawn_timer.timeout.connect(_spawn_enemy)
    countdown_timer.timeout.connect(_on_countdown_finished)

    # 配置计时器
    spawn_timer.wait_time = 2.0
    countdown_timer.one_shot = true
```

### Area2D信号
```gdscript
# 区域节点（用于拾取物品）
@onready var pickup_area: Area2D = $PickupArea

func _ready():
    pickup_area.body_entered.connect(_on_body_entered)
    pickup_area.area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node2D):
    if body is Player:
        collect_item()

func _on_area_entered(area: Area2D):
    # 处理与其他区域的交互
    pass
```

### AnimationPlayer信号
```gdscript
# 动画节点
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
    # 动画开始时
    animation_player.animation_started.connect(_on_animation_started)

    # 动画结束时
    animation_player.animation_finished.connect(_on_animation_finished)

    # 特定动画的信号
    animation_player.animation_changed.connect(_on_animation_changed)

func _on_animation_finished(anim_name: StringName):
    if anim_name == "jump":
        is_jumping = false
    elif anim_name == "attack":
        can_attack = true
```

### TreeItem信号（UI）
```gdscript
# 列表控件
@onready var inventory_list: ItemList = $UI/InventoryList

func _ready():
    inventory_list.item_selected.connect(_on_item_selected)
    inventory_list.item_activated.connect(_on_item_activated)
    inventory_list.multi_selected.connect(_on_multi_selected)
```

## 断开信号

### 使用代码断开
```gdscript
func _ready():
    # 连接信号
    button.pressed.connect(_on_button_pressed)

func cleanup():
    # 断开特定信号
    button.pressed.disconnect(_on_button_pressed)

    # 断开所有连接（危险操作）
    # button.pressed.disconnect_all()
```

### 使用队列断开
```gdscript
func _exit_tree():
    # 节点退出时自动清理信号连接
    if is_instance_valid(button):
        button.pressed.disconnect(_on_button_pressed)
```

## 信号连接的最佳实践

### 1. 命名规范
```gdscript
# 好的命名
_on_button_pressed
_on_player_health_changed
_on_timer_timeout

# 避免的命名
pressed_button  # 容易混淆
button_action  # 不够具体
handle_timer   # 太通用
```

### 2. 在_ready()中连接
```gdscript
# 正确：在_ready()中连接
func _ready():
    timer.timeout.connect(_on_timer_timeout)

# 错误：在_init()中连接（节点可能未准备好）
func _init():
    # 节点引用可能为null
    timer.timeout.connect(_on_timer_timeout)  # 错误！
```

### 3. 使用@onready
```gdscript
# 推荐：使用@onready
@onready var timer: Timer = $Timer

func _ready():
    timer.timeout.connect(_on_timer_timeout)

# 可选：手动查找节点
func _ready():
    var timer = get_node("Timer") as Timer
    timer.timeout.connect(_on_timer_timeout)
```

### 4. 处理断开连接
```gdscript
# 检查连接是否存在
func _ready():
    if not timer.timeout.is_connected(_on_timer_timeout):
        timer.timeout.connect(_on_timer_timeout)

# 安全断开
func cleanup():
    if timer and timer.timeout.is_connected(_on_timer_timeout):
        timer.timeout.disconnect(_on_timer_timeout)
```

### 5. 信号参数的类型提示
```gdscript
# 好的做法：明确类型
signal health_changed(new_health: int)
signal item_picked_up(item: Item)
signal position_updated(pos: Vector2)

# 在接收方法中使用类型
func _on_health_changed(new_health: int):
    # 类型安全
    health_label.text = "Health: %d" % new_health
```

## 高级技巧

### 1. 使用自定义回调
```gdscript
func _ready():
    # 创建自定义回调
    var custom_callback = func(data):
        handle_data(data)
        print("Data processed: " + str(data))

    some_signal.connect(custom_callback)
```

### 2. 信号队列
```gdscript
# 延迟处理信号
func _ready():
    button.pressed.connect(_on_button_pressed, CONNECT_DEFERRED)

func _on_button_pressed():
    # 延迟一帧执行
    print("Button clicked!")
```

### 3. 信号组
```gdscript
# 将多个信号连接到同一个方法
func connect_multiple_buttons():
    var buttons = [$UI/Button1, $UI/Button2, $UI/Button3]

    for button in buttons:
        button.pressed.connect(_on_any_button_pressed.bind(button))

func _on_any_button_pressed(button: Button):
    print("%s was clicked!" % button.name)
```

### 4. 信号过滤
```gdscript
func _ready():
    # 使用组信号
    enemy_group = get_tree().get_nodes_in_group("enemies")
    for enemy in enemy_group:
        enemy.died.connect(_on_enemy_died, CONNECT_ONE_SHOT)

func _on_enemy_died():
    # 每个敌人只触发一次
    update_enemy_count()
```

## 调试信号连接

### 查看连接的信号
```gdscript
func inspect_connections(node: Node):
    # 打印节点的所有信号连接
    var signal_list = node.get_signal_list()
    for signal_info in signal_list:
        var signal_name = signal_info.name
        var connections = node.get_signal_connection_list(signal_name)
        print("Signal %s has %d connections:" % [signal_name, connections.size()])
        for connection in connections:
            print("  - %s -> %s" % [connection.signal.get_name(), connection.callable.get_method()])
```

### 调试信号触发
```gdscript
func _ready():
    # 添加调试信息
    player.health_changed.connect(func(hp):
        print("Debug: Health changed to %d" % hp)
        _on_player_health_changed(hp)
    )
```

## 常见错误和解决方案

### 错误1：信号连接到不存在的方法
**错误**：`E 0:00:00:0000] Method "nonexistent_method" not found in target`
**解决**：确保接收方法存在且拼写正确

### 错误2：重复连接信号
**错误**：同一个信号被连接多次，导致多次触发
**解决**：
```gdscript
# 连接前检查
if not signal.is_connected(method):
    signal.connect(method)
```

### 错误3：连接时节点未准备好
**错误**：尝试在_init()中连接信号时节点引用为null
**解决**：使用_ready()或@onready

### 错误4：忘记断开连接
**错误**：内存泄漏或重复调用
**解决**：在_exit_tree()中清理连接

## 完整示例：信号驱动的游戏系统

### Player.gd
```gdscript
class_name Player
extends CharacterBody2D

# 定义信号
signal health_changed(current: int, max: int)
signal died
signal level_up(level: int)
signal coin_collected(amount: int)

@onready var health_component: Node = $HealthComponent
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

func _ready():
    health_component.health_changed.connect(_on_health_component_changed)

func _on_health_component_changed(health: int, max_health: int):
    # 转发信号
    health_changed.emit(health, max_health)

    if health <= 0:
        died.emit()
        play_death_sound()

func play_death_sound():
    audio_player.stream = load("res://sounds/death.wav")
    audio_player.play()
```

### GameManager.gd
```gdscript
extends Node

@onready var player: Player = $Player
@onready var ui: Control = $UI
@onready var spawner: Node = $EnemySpawner
@onready var scene_tree: SceneTree = get_tree()

func _ready():
    # 连接所有游戏信号
    connect_game_signals()

func connect_game_signals():
    # 玩家信号
    player.health_changed.connect(_on_player_health_changed)
    player.died.connect(_on_player_died)
    player.level_up.connect(_on_player_level_up)
    player.coin_collected.connect(_on_player_coin_collected)

    # UI信号
    ui.pause_button_pressed.connect(_on_pause_button_pressed)
    ui.restart_button_pressed.connect(_on_restart_button_pressed)

    # 其他信号
    spawner.enemy_spawned.connect(_on_enemy_spawned)

func _on_player_health_changed(current: int, max: int):
    ui.update_health_bar(current, max)

func _on_player_died():
    ui.show_game_over_screen()
    scene_tree.paused = true

func _on_player_level_up(level: int):
    ui.show_level_up_message(level)
    player.restore_full_health()

func _on_pause_button_pressed():
    scene_tree.paused = not scene_tree.paused
    ui.toggle_pause_menu()
```

通过遵循这些指导原则，你可以创建高效、可维护的信号系统，实现游戏对象之间的松耦合通信。记住，信号是Godot的强大特性，善用它们会让你的代码更加清晰和模块化！