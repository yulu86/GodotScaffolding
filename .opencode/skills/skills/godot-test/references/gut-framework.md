# GUT 测试框架参考

## 安装

GUT 必须作为 Godot 插件安装：
1. 从 https://github.com/bitwes/Gut 下载
2. 解压到 `addons/gut/`
3. 在 项目 → 项目设置 → 插件 中启用

## 命令行执行

```bash
# Basic run
$GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit

# With options
$GODOT_HOME -s addons/gut/gut_cmdln.gd \
  -gselect=test_health_component.gd \
  -gverbosity=2 \
  -gexit
```

## 命令行关键选项

| 标志 | 描述 |
|------|-------------|
| `-gselect=file.gd` | 运行指定测试文件 |
| `-gdir=path/to/dir` | 运行指定目录中的测试 |
| `-gverbosity=0-3` | 输出详细程度（0=最小，3=最大） |
| `-gexit` | 测试完成后退出 |
| `-gprefab` | 运行前显示测试名称 |
| `-ghide_orphans` | 隐藏孤立节点警告 |
| `-gmax_itter=N` | 模糊测试的最大迭代次数 |

## 测试文件结构

```gdscript
extends GutTest

# --- Lifecycle Hooks ---
func before_all() -> void:
	# One-time setup (before all tests)
	pass

func before_each() -> void:
	# Per-test setup (fresh state)
	pass

func after_each() -> void:
	# Per-test cleanup
	pass

func after_all() -> void:
	# One-time cleanup
	pass

# --- Tests ---
func test_something() -> void:
	assert_true(true, "Basic assertion")
```

## 自动释放辅助方法

| 方法 | 用途 |
|--------|---------|
| `add_child_autofree(node)` | 添加子节点，测试结束时自动释放 |
| `add_child_autoqfree(node)` | 添加子节点，测试结束时自动队列释放 |
| `autofree(obj)` | 标记任意对象为自动释放 |
| `autoqfree(obj)` | 标记任意对象为自动队列释放 |

## Double/Spy 支持

```gdscript
func test_with_double() -> void:
	var mock_enemy = double(Enemy.gd).new()
	stub(mock_enemy, "take_damage").to_do_nothing()
	add_child_autoqfree(mock_enemy)
	# Test code using mock_enemy...
```

## 参数化测试

```gdscript
func test_damage_values(params = [
	[10, 90],   # damage, expected_health
	[50, 50],
	[100, 0],
	[999, 0],   # overkill clamped to 0
]) -> void:
	var damage: int = params[0]
	var expected: int = params[1]
	_health.take_damage(damage)
	assert_eq(_health._current_health, expected)
```

## 最佳实践

1. **每个概念一个断言** — 不要堆叠不相关的断言
2. **描述性消息** — 每个断言都应说明出了什么问题
3. **测试名称描述行为** — 使用 `test_take_damage_reduces_health` 而非 `test_damage`
4. **隔离测试** — 每个测试必须独立，不共享可变状态
5. **使用 before_each** — 为每个测试创建全新实例
6. **测试公共 API** — 测试行为，而非实现细节
7. **负面测试** — 测试无效输入和错误条件
