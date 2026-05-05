```gdscript
# 模板：GUT 测试文件
# Path: test/unit/{module_path}/test_{class_name_snake}.gd
extends GutTest

var _instance: {ClassName}

func before_each() -> void:
	_instance = {ClassName}.new()
	add_child_autoqfree(_instance)

func after_each() -> void:
	# 自动清理由 add_child_autoqfree 处理
	pass

# === 构造函数测试 ===

func test_initial_state() -> void:
	assert_not_null(_instance, "Instance should be created")

# === 核心行为测试 ===

func test_{method_name}_works() -> void:
	# Arrange
	var input: int = 10
	var expected: int = 20

	# Act
	_instance.{method_name}(input)

	# Assert
	assert_eq(_instance.{property}, expected,
		"{method_name} should set {property} correctly")

# === 边界条件测试 ===

func test_{method_name}_with_invalid_input() -> void:
	_instance.{method_name}(-1)
	# 不应崩溃

# === 信号测试 ===

func test_{signal_name}_emitted() -> void:
	watch_signals(_instance)
	_instance.{trigger_method}()
	assert_signal_emitted(_instance, "{signal_name}",
		"{signal_name} 应在调用 {trigger_method} 时发射")
```
