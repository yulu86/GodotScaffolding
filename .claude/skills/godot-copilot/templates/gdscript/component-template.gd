extends Node
class_name ComponentTemplate

# =============================================================================
# 组件模板
# 用于创建可重用的游戏组件
# 使用说明：
# 1. 根据组件需求修改类名和功能
# 2. 继承此类创建具体组件
# 3. 实现组件特有的功能
# =============================================================================

# 组件基础属性
var enabled: bool = true
var owner_node: Node = null
var component_name: String = ""

# 信号定义
signal component_enabled
signal component_disabled
signal component_data_changed(property: String, value: Variant)
signal component_event(event_name: String, data: Dictionary = {})

# -----------------------------------------------------------------------------
# 生命周期方法
# -----------------------------------------------------------------------------

func _ready():
    """组件初始化"""
    component_name = get_script().get_global_name()
    initialize()

func initialize():
    """初始化组件（子类重写）"""
    pass

func _process(delta):
    """每帧更新"""
    if enabled:
        update_component(delta)

func update_component(delta):
    """更新组件逻辑（子类重写）"""
    pass

# -----------------------------------------------------------------------------
# 组件控制
# -----------------------------------------------------------------------------

func set_enabled(new_enabled: bool):
    """设置组件启用状态"""
    if enabled == new_enabled:
        return

    enabled = new_enabled

    if enabled:
        on_enabled()
        component_enabled.emit()
    else:
        on_disabled()
        component_disabled.emit()

func enable():
    """启用组件"""
    set_enabled(true)

func disable():
    """禁用组件"""
    set_enabled(false)

func on_enabled():
    """组件启用时调用（子类重写）"""
    pass

func on_disabled():
    """组件禁用时调用（子类重写）"""
    pass

# -----------------------------------------------------------------------------
# 所有者管理
# -----------------------------------------------------------------------------

func set_owner(node: Node):
    """设置组件所有者"""
    owner_node = node

func get_owner() -> Node:
    """获取组件所有者"""
    return owner_node

# -----------------------------------------------------------------------------
# 数据管理
# -----------------------------------------------------------------------------

func set_data(property: String, value: Variant):
    """设置组件数据"""
    if has_method("set_" + property):
        call("set_" + property, value)
    else:
        set(property, value)
    component_data_changed.emit(property, value)

func get_data(property: String):
    """获取组件数据"""
    if has_method("get_" + property):
        return call("get_" + property)
    else:
        return get(property)

# -----------------------------------------------------------------------------
# 事件系统
# -----------------------------------------------------------------------------

func emit_event(event_name: String, data: Dictionary = {}):
    """发出组件事件"""
    component_event.emit(event_name, data)

# -----------------------------------------------------------------------------
# 具体组件示例（基于模板创建）
# =============================================================================

# 示例1：生命组件
class HealthComponent extends ComponentTemplate:
    signal health_changed(current: int, maximum: int)
    signal died
    signal damage_taken(amount: int)
    signal healed(amount: int)

    @export var maximum_health: int = 100
    var current_health: int

    func _ready():
        super._ready()
        current_health = maximum_health

    func take_damage(damage: int):
        if not enabled or current_health <= 0:
            return

        current_health = max(0, current_health - damage)
        health_changed.emit(current_health, maximum_health)
        damage_taken.emit(damage)

        if current_health <= 0:
            die()

    func heal(amount: int):
        if not enabled or current_health >= maximum_health:
            return

        current_health = min(maximum_health, current_health + amount)
        health_changed.emit(current_health, maximum_health)
        healed.emit(amount)

    func die():
        if enabled:
            enabled = false
            died.emit()

    func get_health_percentage() -> float:
        return float(current_health) / maximum_health

    func is_dead() -> bool:
        return current_health <= 0

    func reset():
        current_health = maximum_health
        enabled = true

# 示例2：移动组件
class MovementComponent extends ComponentTemplate:
    signal movement_started
    signal movement_stopped
    signal speed_changed(new_speed: float)

    @export var max_speed: float = 300.0
    @export var acceleration: float = 1000.0
    @export var friction: float = 1200.0
    @export var can_move: bool = true

    var current_speed: float = 0.0
    var move_direction: Vector2 = Vector2.ZERO
    var velocity: Vector2 = Vector2.ZERO
    var is_moving: bool = false

    func _ready():
        super._ready()

    func set_move_direction(direction: Vector2):
        if not enabled or not can_move:
            return

        move_direction = direction.normalized()

        if move_direction.length() > 0:
            if not is_moving:
                is_moving = true
                movement_started.emit()

        update_speed()

    func update_speed():
        var target_speed = move_direction.length() * max_speed

        if target_speed > current_speed:
            current_speed = move_toward(current_speed, target_speed, acceleration * get_process_delta_time())
        elif target_speed < current_speed:
            current_speed = move_toward(current_speed, target_speed, friction * get_process_delta_time())

        speed_changed.emit(current_speed)

    func _physics_process(delta):
        super._process(delta)
        if enabled and owner_node and owner_node is CharacterBody2D:
            velocity = move_direction * current_speed
            owner_node.velocity = velocity
            owner_node.move_and_slide()

        # 检查是否停止移动
        if is_moving and move_direction.length() == 0:
            is_moving = false
            movement_stopped.emit()

    func stop():
        move_direction = Vector2.ZERO

    func set_max_speed(speed: float):
        max_speed = speed

    func set_can_move(value: bool):
        can_move = value
        if not value:
            stop()

# 示例3：攻击组件
class AttackComponent extends ComponentTemplate:
    signal attack_started
    signal attack_finished
    signal damage_dealt(target: Node, damage: int)

    @export var damage: int = 10
    @export var attack_range: float = 50.0
    @export var attack_cooldown: float = 1.0
    @export var can_attack: bool = true

    var is_attacking: bool = false
    var cooldown_timer: Timer

    func _ready():
        super._ready()
        setup_cooldown_timer()

    func setup_cooldown_timer():
        cooldown_timer = Timer.new()
        cooldown_timer.wait_time = attack_cooldown
        cooldown_timer.timeout.connect(_on_cooldown_finished)
        add_child(cooldown_timer)

    func try_attack(target_position: Vector2) -> bool:
        if not enabled or not can_attack or is_attacking:
            return false

        if is_target_in_range(target_position):
            start_attack()
            return true

        return false

    func is_target_in_range(target_position: Vector2) -> bool:
        if not owner_node:
            return false
        return owner_node.global_position.distance_to(target_position) <= attack_range

    func start_attack():
        is_attacking = true
        attack_started.emit()

        # 执行攻击动画或效果
        perform_attack()

    func perform_attack():
        # 子类重写实现具体攻击逻辑
        finish_attack()

    func finish_attack():
        attack_finished.emit()
        is_attacking = false
        start_cooldown()

    func start_cooldown():
        can_attack = false
        cooldown_timer.start()

    func _on_cooldown_finished():
        can_attack = true

    func deal_damage_to(target: Node):
        if target.has_method("take_damage"):
            target.take_damage(damage)
            damage_dealt.emit(target, damage)

# 示例4：收集组件
class CollectibleComponent extends ComponentTemplate:
    signal collected
    signal pickup_value_changed(value: int)

    @export var value: int = 10
    @export var collectible_type: String = "coin"
    @export var auto_collect: bool = false
    @export var collection_range: float = 30.0

    var can_be_collected: bool = true
    var collection_effect: PackedScene

    func _ready():
        super._ready()
        setup_collision()

    func setup_collision():
        if owner_node and owner_node.has_node("Area2D"):
            var area = owner_node.get_node("Area2D")
            area.body_entered.connect(_on_body_entered)

    func _on_body_entered(body: Node):
        if not enabled or not can_be_collected:
            return

        # 检查是否是玩家
        if body.is_in_group("player"):
            if auto_collect or is_player_in_range(body):
                collect(body)

    func is_player_in_range(player: Node) -> bool:
        return owner_node.global_position.distance_to(player.global_position) <= collection_range

    func collect(collector: Node):
        if not can_be_collected:
            return

        can_be_collected = false
        collected.emit()

        # 给收集者增加价值
        if collector.has_method("add_value"):
            collector.add_value(value)
        elif collector.has_method("add_score"):
            collector.add_score(value)

        # 播放收集效果
        play_collection_effect()

        # 销毁或隐藏对象
        if owner_node:
            owner_node.queue_free()

    func play_collection_effect():
        if collection_effect:
            var effect = collection_effect.instantiate()
            get_tree().current_scene.add_child(effect)
            effect.global_position = owner_node.global_position

    func set_value(new_value: int):
        value = new_value
        pickup_value_changed.emit(value)

# 示例5：状态机组件
class StateMachineComponent extends ComponentTemplate:
    signal state_changed(old_state: String, new_state: String)

    var current_state: String = ""
    var states: Dictionary = {}
    var state_data: Dictionary = {}

    func _ready():
        super._ready()
        register_states()

    func register_states():
        """注册所有状态（子类重写）"""
        pass

    func add_state(state_name: String, state_node: Node):
        """添加状态"""
        states[state_name] = state_node
        state_node.set_name(state_name)

    func change_state(new_state: String):
        """改变状态"""
        if new_state == current_state or not states.has(new_state):
            return

        var old_state = current_state
        current_state = new_state

        # 退出旧状态
        if old_state != "" and states.has(old_state):
            var old_state_node = states[old_state]
            if old_state_node.has_method("exit"):
                old_state_node.exit()

        # 进入新状态
        var new_state_node = states[new_state]
        if new_state_node.has_method("enter"):
            new_state_node.enter(state_data)

        state_changed.emit(old_state, new_state)
        state_data.clear()

    func get_current_state_node() -> Node:
        """获取当前状态节点"""
        return states.get(current_state, null)

    func set_state_data(key: String, value: Variant):
        """设置状态数据"""
        state_data[key] = value

# 示例6：音效组件
class SoundComponent extends ComponentTemplate:
    signal sound_played(sound_name: String)

    @export var sound_library: Dictionary = {}
    @export var randomize_pitch: bool = true
    @export var pitch_variation: float = 0.1

    var audio_players: Array[AudioStreamPlayer2D] = []

    func _ready():
        super._ready()
        setup_audio_players()

    func setup_audio_players():
        # 创建多个音频播放器以支持同时播放
        for i in range(3):
            var player = AudioStreamPlayer2D.new()
            add_child(player)
            audio_players.append(player)

    func play_sound(sound_name: String, volume: float = 1.0):
        """播放音效"""
        if not enabled or not sound_library.has(sound_name):
            return

        var stream = load(sound_library[sound_name])
        if not stream:
            return

        var player = get_available_player()
        if not player:
            return

        player.stream = stream
        player.volume_db = linear_to_db(volume)

        if randomize_pitch:
            player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)

        player.play()
        sound_played.emit(sound_name)

    func get_available_player() -> AudioStreamPlayer2D:
        """获取可用的音频播放器"""
        for player in audio_players:
            if not player.playing:
                return player
        return null

    func stop_all_sounds():
        """停止所有音效"""
        for player in audio_players:
            player.stop()

    func add_sound(name: String, path: String):
        """添加音效到库"""
        sound_library[name] = path

# =============================================================================
# 使用示例
# =============================================================================

# 在脚本中使用组件：

# 1. 添加组件到节点
# var health_comp = HealthComponent.new()
# player.add_child(health_comp)
# health_comp.set_owner(player)

# 2. 配置组件
# health_comp.maximum_health = 200
# health_comp.current_health = 200

# 3. 连接信号
# health_comp.health_changed.connect(_on_health_changed)

# 4. 使用组件
# health_comp.take_damage(50)

# 5. 创建自定义组件
# class MyCustomComponent extends ComponentTemplate:
#     # 实现组件功能
#     pass

# =============================================================================
# 最佳实践
# =============================================================================

# 1. 组件应该单一职责
# 2. 组件之间通过事件通信
# 3. 使用enabled属性控制组件
# 4. 组件应该可重用
# 5. 保持组件独立性