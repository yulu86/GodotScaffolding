extends CharacterBody2D
class_name CharacterController

## 角色控制器模板
## 提供基础的移动、跳跃和动画功能

# ===== 导出变量 =====
@export_group("Movement Settings")
@export var speed: float = 300.0
@export var acceleration: float = 1000.0
@export var friction: float = 1200.0
@export var jump_velocity: float = -400.0

@export_group("Animation")
@export var idle_animation_name: String = "idle"
@export var walk_animation_name: String = "walk"
@export var jump_animation_name: String = "jump"

# ===== 私有变量 =====
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _is_jumping: bool = false
var _facing_right: bool = true

# ===== 信号 =====
signal character_jumped
signal character_landed
signal direction_changed(new_direction: int)

# ===== 节点引用 =====
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

# ===== 生命周期 =====

func _ready():
    # 初始化动画
    if _animation_player and _animation_player.has_animation(idle_animation_name):
        _animation_player.play(idle_animation_name)

# ===== 物理处理 =====

func _physics_process(delta: float):
    # 应用重力
    if not is_on_floor():
        velocity.y += _gravity * delta
    else:
        if _is_jumping:
            _is_jumping = false
            character_landed.emit()

    # 处理跳跃
    handle_jump()

    # 处理移动
    handle_movement(delta)

    # 更新动画
    update_animation()

    # 移动角色
    move_and_slide()

# ===== 移动处理 =====

func handle_movement(delta: float):
    var input_direction = Input.get_axis("move_left", "move_right")

    if input_direction != 0:
        # 加速
        velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)

        # 更新朝向
        update_facing_direction(input_direction)
    else:
        # 减速
        velocity.x = move_toward(velocity.x, 0, friction * delta)

func handle_jump():
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity
        _is_jumping = true
        character_jumped.emit()

# ===== 朝向和动画 =====

func update_facing_direction(direction: float):
    var new_facing_right = direction > 0

    if new_facing_right != _facing_right:
        _facing_right = new_facing_right
        _sprite.flip_h = not _facing_right
        direction_changed.emit(1 if _facing_right else -1)

func update_animation():
    if not _animation_player:
        return

    var animation_name: String

    # 选择动画
    if not is_on_floor():
        animation_name = jump_animation_name
    elif abs(velocity.x) > 10:
        animation_name = walk_animation_name
    else:
        animation_name = idle_animation_name

    # 播放动画
    if _animation_player.current_animation != animation_name:
        _animation_player.play(animation_name)

# ===== 公共方法 =====

func add_horizontal_force(force: float):
    """添加水平推力"""
    velocity.x += force

func set_frozen(frozen: bool):
    """设置是否冻结"""
    set_process(not frozen)
    set_physics_process(not frozen)
    if frozen and _animation_player:
        _animation_player.pause()
    elif not frozen and _animation_player:
        _animation_player.play()

# ===== 虚方法（可重写） =====

func on_character_jumped():
    """跳跃时调用 - 子类可重写"""
    pass

func on_character_landed():
    """着陆时调用 - 子类可重写"""
    pass

# ===== 辅助方法 =====

func get_movement_input() -> float:
    """获取移动输入"""
    return Input.get_axis("move_left", "move_right")

func is_moving() -> bool:
    """是否正在移动"""
    return abs(velocity.x) > 10

func get_facing_direction() -> int:
    """获取朝向方向（1=右，-1=左）"""
    return 1 if _facing_right else -1