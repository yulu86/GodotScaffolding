```gdscript
# 模板：Actor 场景脚本
# 放在与 .tscn 文件相同的目录中
class_name {ClassName}
extends CharacterBody2D

# --- 导出变量 ---
@export var move_speed: float = 200.0
@export var max_health: int = 100

# --- 信号 ---
signal health_changed(new_health: int)
signal died

# --- 私有状态 ---
var _current_health: int
var _velocity: Vector2 = Vector2.ZERO

# --- 节点引用（使用 %UniqueName）---
@onready var _sprite: AnimatedSprite2D = %ActorSprite
@onready var _collision: CollisionShape2D = %ActorCollision

# --- 生命周期 ---
func _ready() -> void:
	_current_health = max_health
	_connect_signals()

func _physics_process(delta: float) -> void:
	velocity = _velocity
	move_and_slide()

# --- 公共接口 ---
func take_damage(amount: int) -> void:
	_current_health = max(0, _current_health - amount)
	health_changed.emit(_current_health)
	if _current_health == 0:
		died.emit()

func heal(amount: int) -> void:
	_current_health = min(max_health, _current_health + amount)
	health_changed.emit(_current_health)

# --- 私有方法 ---
func _connect_signals() -> void:
	pass
```
