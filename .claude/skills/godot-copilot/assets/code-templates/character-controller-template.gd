extends CharacterBody2D
class_name CharacterController

# 导出的编辑器属性
@export var move_speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var double_jump_velocity: float = -350.0
@export var acceleration: float = 1000.0
@export var friction: float = 1200.0
@export var gravity_scale: float = 1.0
@export var max_health: int = 3

# 内部状态变量
var current_health: int
var can_double_jump: bool = true
var is_grounded: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var facing_direction: int = 1  # 1 for right, -1 for left

# 节点引用（使用@onready自动获取）
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ground_ray: RayCast2D = $GroundRay
@onready var hurt_timer: Timer = $HurtTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer

# 信号定义
signal health_changed(new_health)
signal player_died
signal jump_performed
signal double_jump_performed
signal landed

# 常量定义
const GRAVITY: float = 980.0

func _ready():
    # 初始化状态
    current_health = max_health
    health_changed.emit(current_health)
    
    # 连接计时器信号
    if hurt_timer:
        hurt_timer.timeout.connect(_on_hurt_timer_timeout)
    if invincibility_timer:
        invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)

func _physics_process(delta):
    if is_dead:
        return
    
    # 应用重力
    if not is_on_floor():
        velocity.y += GRAVITY * gravity_scale * delta
    
    # 处理受伤状态
    if is_hurt:
        apply_knockback(delta)
        move_and_slide()
        return
    
    # 处理输入
    handle_movement_input(delta)
    handle_jump_input()
    
    # 应用移动
    move_and_slide()
    
    # 更新状态
    update_grounded_state()
    update_facing_direction()
    update_animation()

# 处理水平移动输入
func handle_movement_input(delta):
    var input_direction = Input.get_axis("ui_left", "ui_right")
    
    if input_direction != 0:
        # 加速到目标速度
        velocity.x = move_toward(velocity.x, input_direction * move_speed, acceleration * delta)
    else:
        # 应用摩擦力减速
        velocity.x = move_toward(velocity.x, 0, friction * delta)

# 处理跳跃输入
func handle_jump_input():
    if Input.is_action_just_pressed("ui_accept"):
        if is_on_floor():
            perform_jump()
        elif can_double_jump:
            perform_double_jump()

# 执行基础跳跃
func perform_jump():
    velocity.y = jump_velocity
    can_double_jump = true
    jump_performed.emit()
    animation_player.play("jump")

# 执行二段跳
func perform_double_jump():
    velocity.y = double_jump_velocity
    can_double_jump = false
    double_jump_performed.emit()
    
    # 播放二段跳特效
    create_double_jump_effect()

# 更新接地状态
func update_grounded_state():
    var was_grounded = is_grounded
    is_grounded = is_on_floor()
    
    # 刚刚落地
    if is_grounded and not was_grounded:
        can_double_jump = true
        landed.emit()
        animation_player.play("land")

# 更新朝向
func update_facing_direction():
    if velocity.x > 0:
        facing_direction = 1
        sprite.flip_h = false
    elif velocity.x < 0:
        facing_direction = -1
        sprite.flip_h = true

# 更新动画
func update_animation():
    if is_hurt:
        return
    
    if not is_grounded:
        if velocity.y < 0:
            if animation_player.current_animation != "jump_up":
                animation_player.play("jump_up")
        else:
            if animation_player.current_animation != "fall":
                animation_player.play("fall")
    else:
        if abs(velocity.x) > 10:
            if animation_player.current_animation != "run":
                animation_player.play("run")
        else:
            if animation_player.current_animation != "idle":
                animation_player.play("idle")

# 受到伤害
func take_damage(damage: int, damage_source: Node = null):
    if is_dead or invincibility_timer.time_left > 0:
        return
    
    current_health -= damage
    health_changed.emit(current_health)
    
    if current_health <= 0:
        die()
    else:
        enter_hurt_state(damage_source)

# 进入受伤状态
func enter_hurt_state(damage_source: Node):
    is_hurt = true
    
    # 计算击退方向
    var knockback_direction = Vector2.ZERO
    if damage_source:
        knockback_direction = (global_position - damage_source.global_position).normalized()
    else:
        knockback_direction.x = -facing_direction
        knockback_direction.y = -1
    
    # 设置击退速度
    velocity = knockback_direction * 300
    
    # 启动计时器
    hurt_timer.start(0.5)
    invincibility_timer.start(1.0)
    
    # 播放受伤动画
    animation_player.play("hurt")
    
    # 视觉效果
    flash_white()

# 应用击退效果
func apply_knockback(delta):
    velocity.y += GRAVITY * gravity_scale * delta

# 角色死亡
func die():
    if is_dead:
        return
    
    is_dead = true
    current_health = 0
    health_changed.emit(current_health)
    
    # 停止所有运动
    velocity = Vector2.ZERO
    
    # 播放死亡动画
    animation_player.play("death")
    
    # 禁用碰撞
    collision_shape.disabled = true
    
    # 发出死亡信号
    player_died.emit()

# 治疗角色
func heal(amount: int):
    current_health = min(current_health + amount, max_health)
    health_changed.emit(current_health)
    
    # 治疗特效
    create_heal_effect()

# 重置角色状态
func reset_character():
    is_dead = false
    is_hurt = false
    can_double_jump = true
    current_health = max_health
    
    velocity = Vector2.ZERO
    collision_shape.disabled = false
    
    health_changed.emit(current_health)
    animation_player.play("idle")

# 创建二段跳特效
func create_double_jump_effect():
    var effect_scene = preload("res://effects/DoubleJumpEffect.tscn")
    var effect = effect_scene.instantiate()
    get_tree().current_scene.add_child(effect)
    effect.global_position = global_position

# 创建治疗特效
func create_heal_effect():
    var effect_scene = preload("res://effects/HealEffect.tscn")
    var effect = effect_scene.instantiate()
    get_tree().current_scene.add_child(effect)
    effect.global_position = global_position

# 闪烁效果
func flash_white():
    sprite.modulate = Color.WHITE
    await get_tree().create_timer(0.1).timeout
    sprite.modulate = Color.WHITE

# 计时器回调函数
func _on_hurt_timer_timeout():
    is_hurt = false

func _on_invincibility_timer_timeout():
    pass  # 无敌时间结束

# 获取当前状态信息（用于调试）
func get_debug_info() -> Dictionary:
    return {
        "velocity": velocity,
        "is_grounded": is_grounded,
        "can_double_jump": can_double_jump,
        "current_health": current_health,
        "is_hurt": is_hurt,
        "is_dead": is_dead,
        "facing_direction": facing_direction
    }