```gdscript
# 模板：Component 场景脚本
# 放在与 .tscn 文件相同的目录中
class_name {ClassName}
extends {BaseClass}

# --- 导出变量（检查器可调）---
@export var enabled: bool = true

# --- 信号（解耦通信）---
signal activated
signal deactivated

# --- 私有状态 ---
var _is_active: bool = false

# --- 生命周期 ---
func _ready() -> void:
	_initialize()

func _initialize() -> void:
	_is_active = true

# --- 公共接口 ---
func activate() -> void:
	if _is_active:
		return
	_is_active = true
	activated.emit()

func deactivate() -> void:
	if not _is_active:
		return
	_is_active = false
	deactivated.emit()

func is_active() -> bool:
	return _is_active
```
