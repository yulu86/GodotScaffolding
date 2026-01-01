# 信号连接指导

## 🔌 信号基础

### 什么是信号
信号是Godot的观察者模式实现，允许节点之间解耦通信：
- **发射信号**: 节点发出事件通知
- **连接信号**: 其他节点监听并响应事件
- **参数传递**: 信号可以携带数据

### 内置信号
大多数节点都有内置信号：
```gdscript
# Timer 节点
timeout # 定时器结束

# Button 节点
pressed # 按钮按下
button_up # 按钮释放

# Body 节点
body_entered # 物体进入
body_exited # 物体离开

# AnimationPlayer
animation_finished # 动画结束
```

## 📝 定义自定义信号

### 信号声明
```gdscript
# 无参数信号
signal game_over

# 带参数信号
signal health_changed(new_health: int)
signal item_collected(item_name: String, value: int)

# 多参数信号
signal player_stats_updated(health: int, mana: int, level: int)
```

### 发射信号
```gdscript
func take_damage(amount: int):
    current_health -= amount
    health_changed.emit(current_health)  # 发射信号

    if current_health <= 0:
        game_over.emit()  # 发射游戏结束信号
```

## 🔗 连接信号的方式

### 1. 编辑器连接
1. 选择节点
2. 在检查器中找到"节点"标签
3. 双击要连接的信号
4. 选择目标节点和方法
5. 点击"连接"

### 2. 代码连接
```gdscript
# 连接到当前节点的方法
func _ready():
    $Timer.timeout.connect(_on_timer_timeout)
    $Button.pressed.connect(_on_button_pressed)

# 连接到其他节点
func _ready():
    $Timer.timeout.connect(UIManager.show_time_up)
    $Player.health_changed.connect($HealthBar.update_health)

# 使用lambda连接（不推荐，难以调试）
func _ready():
    $Button.pressed.connect(func(): print("Button clicked"))
```

### 3. 使用组连接
```gdscript
# 将多个敌人添加到组
for enemy in enemies:
    enemy.add_to_group("enemies")
    enemy.died.connect(_on_enemy_died)

# 使用组信号
func _ready():
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.health_changed.connect(check_all_enemies_defeated)
```

## 📋 信号处理方法命名规范

### 推荐命名格式
```gdscript
# 格式：_on_[发射节点名称]_[信号名称]
func _on_Timer_timeout():
    print("Timer finished")

func _on_Button_pressed():
    print("Button was pressed")

func _on_Player_health_changed(new_health):
    print(f"Player health: {new_health}")

func _on_Enemy_died():
    print("An enemy died")
```

### 使用信号参数
```gdscript
# 声明带参数的信号
signal score_changed(new_score: int, multiplier: float)

# 发射时传递参数
func add_score(points: int):
    var final_score = points * score_multiplier
    score += final_score
    score_changed.emit(score, score_multiplier)

# 接收时使用参数
func _on_GameManager_score_changed(new_score: int, multiplier: float):
    $ScoreLabel.text = "Score: %d (x%.1f)" % [new_score, multiplier]
```

## 🚀 高级用法

### 1. 条件信号连接
```gdscript
func connect_signals():
    if player_has_ability:
        $Player.power_up_collected.connect(_on_power_up_collected)

    if debug_mode:
        $Player.health_changed.connect(debug_log_health)
```

### 2. 临时信号连接
```gdscript
# 连接并在完成时断开
func play_cutscene():
    var cutscene = cutscene_scene.instantiate()
    add_child(cutscene)

    # 连接完成信号
    var connection = cutscene.finished.connect(
        func():
            cutscene.queue_free()
            resume_game()
    )

    # 确保断开连接
    cutscene.tree_exiting.connect(connection.unbind.call())
```

### 3. 信号队列
```gdsignal
# 使用call_deferred延迟处理
func _on_Enemy_died():
    # 延迟处理，避免修改正在迭代的集合
    update_enemy_count.call_deferred()
```

## 🛠️ 调试信号

### 查看信号连接
```gdscript
# 打印所有连接
func print_signal_connections(node: Node):
    for signal in node.get_signal_list():
        var connections = node.get_signal_connection_list(signal.name)
        if connections.size() > 0:
            print(f"Signal '{signal.name}' has {connections.size()} connections:")
            for conn in connections:
                print(f"  - {conn.callable}")
```

### 常见信号问题
1. **信号未连接**: 检查_connect_是否在_ready_中执行
2. **节点未就绪**: 使用@onready或在树中延迟连接
3. **参数不匹配**: 确保信号和处理方法的参数一致
4. **内存泄漏**: 临时连接记得断开

## 💡 最佳实践

1. **优先使用内置信号**: 避免重复定义已有功能
2. **合理设计信号粒度**: 不要过细或过粗
3. **使用强类型**: 信号参数添加类型提示
4. **及时断开连接**: 临时连接要记得清理
5. **文档化信号**: 为自定义信号添加注释说明

```gdscript
## 玩家生命值变化时发射
## @param new_health: 新的生命值 (0-100)
signal health_changed(new_health: int)

## 玩家获得新能力时发射
## @param ability_name: 能力名称
## @param ability_level: 能力等级
signal ability_unlocked(ability_name: String, ability_level: int)
```