extends Node
class_name ComponentTemplate

## 组件模板
## 用于创建可重用的游戏组件

# 导出配置 - 在编辑器中可设置
@export var enabled: bool = true
@export_group("Component Settings")
@export var config_value: float = 100.0

# 私有变量
var _is_initialized: bool = false

# 信号定义
signal component_enabled
signal component_disabled
signal config_changed

# 节点引用（使用@onready延迟加载）
@onready var parent_node = get_parent()

# ===== 生命周期方法 =====

func _ready():
    """初始化组件"""
    if enabled:
        initialize_component()

func _enter_tree():
    """节点进入场景树时调用"""
    pass

func _exit_tree():
    """节点离开场景树时调用"""
    cleanup()

# ===== 公共方法 =====

func enable_component():
    """启用组件"""
    if not enabled:
        enabled = true
        component_enabled.emit()
        initialize_component()

func disable_component():
    """禁用组件"""
    if enabled:
        enabled = false
        component_disabled.emit()
        cleanup()

func set_config(value: float):
    """设置配置值"""
    if config_value != value:
        config_value = value
        config_changed.emit()
        on_config_updated()

# ===== 虚方法（子类可重写） =====

func initialize_component():
    """初始化组件 - 子类重写"""
    if _is_initialized:
        return

    _is_initialized = true
    # 子类实现初始化逻辑

func cleanup():
    """清理组件 - 子类重写"""
    _is_initialized = false
    # 子类实现清理逻辑

func on_config_updated():
    """配置更新时调用 - 子类重写"""
    # 子类实现配置更新逻辑
    pass

# ===== 私有方法 =====

func _validate_configuration():
    """验证配置有效性"""
    # 子类可重写此方法进行配置验证
    pass