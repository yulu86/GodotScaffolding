# Godot开发指导

## 场景创建步骤

### 1. 基本场景创建流程
1. 确定场景根节点类型
   - Node: 用于逻辑容器
   - Node2D: 2D场景根节点
   - Node3D: 3D场景根节点
   - Control: UI场景根节点

2. 添加必要的子节点
   - CanvasLayer: UI层管理
   - Camera2D/Camera3D: 视角控制
   - TileMap: 2D关卡地图
   - AudioStreamPlayer: 音频播放

### 2. 节点命名规范
- 使用PascalCase命名节点
- 功能性节点添加前缀：
  - UI节点: UI_ 前缀
  - 碰撞节点: Collision_ 前缀
  - 动画节点: Animation_ 前缀

## 代码实现流程

### 1. 脚本结构
```gdscript
# 文件: scripts/player/player_controller.gd
extends CharacterBody2D
class_name PlayerController

# 导出变量（可在编辑器设置）
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

# 私有变量
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# 信号定义
signal health_changed(new_health: int)
signal player_died

# 节点引用
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _sprite: Sprite2D = $Sprite2D
```

### 2. 生命周期方法
```gdscript
func _ready():
    # 初始化代码
    pass

func _process(delta: float):
    # 每帧处理逻辑
    pass

func _physics_process(delta: float):
    # 物理相关处理
    pass
```

### 3. 信号连接
```gdscript
# 在_ready方法中连接信号
func _ready():
    # 连接内部信号
    _animation_player.animation_finished.connect(_on_animation_finished)

    # 连接外部信号（如果需要）
    # GameState.coin_collected.connect(_on_coin_collected)

func _on_animation_finished(anim_name: String):
    # 处理动画完成事件
    pass
```

## 测试驱动开发

### 1. GUT测试框架设置
```gdscript
# 文件: test/test_player_controller.gd
extends GutTest

var player: PlayerController

func before_each():
    # 测试前准备
    player = PlayerController.new()
    add_child_autofree(player)

func test_move_right():
    # 测试向右移动
    player.velocity.x = player.speed
    player._physics_process(0.016)
    assert_eq(player.velocity.x, player.speed)
```

### 2. 测试场景准备
```gdscript
# 创建测试场景
func test_player_jump():
    var player_scene = preload("res://scenes/player/player.tscn").instantiate()
    add_child_autofree(player_scene)

    # 模拟输入
    Input.action_press("jump")
    player_scene._physics_process(0.016)

    assert_true(player_scene.velocity.y < 0)
```

## 最佳实践

### 1. 性能优化
- 使用 `_process` 处理每帧更新
- 使用 `_physics_process` 处理物理相关
- 避免在 `_process` 中进行重量级计算
- 使用对象池管理频繁创建销毁的对象

### 2. 代码组织
- 按功能模块划分脚本
- 使用自动加载（Singleton）管理全局状态
- 通过信号解耦模块间依赖
- 使用组（groups）管理同类型节点

### 3. 调试技巧
- 使用 `print()` 输出调试信息
- 使用 `assert()` 进行断言检查
- 利用Godot的调试器进行断点调试
- 使用远程调试查看运行时状态