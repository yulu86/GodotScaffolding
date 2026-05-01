---
name: godot-test
description: Godot 4.x GUT 测试编写专家 Skill，提供完整的 GUT 框架参考、测试模式库、测试调试工具和 MCP 测试集成指南。当需要编写 GUT 单元测试、查询 GUT 断言方法、设计测试用例、调试失败测试、设置测试基础设施或集成测试到 CI/CD 流程时触发此技能。
---

# Godot 测试编写专家

Godot 4.x 的 GUT 测试专家 — 框架参考、模式库和调试。

## 何时使用

- 为 GDScript 代码编写 GUT 单元测试
- 查询 GUT 断言方法或生命周期钩子
- 为 TDD 工作流设计测试用例
- 调试失败的测试
- 搭建测试基础设施
- 度量测试覆盖率
- 将测试集成到 MCP 或 CI/CD

## 快速参考

### 测试目录约定

测试文件在 `test/` 下镜像源码结构：

```
test/
├── unit/
│   ├── autoload/
│   │   └── test_game_manager.gd
│   ├── actors/
│   │   └── player/
│   │       ├── test_player.gd
│   │       └── test_player_state_machine.gd
│   ├── components/
│   │   └── test_health_component.gd
│   └── utils/
│       └── test_math_utils.gd
└── integration/
    └── test_combat_flow.gd
```

**规则**：测试文件路径必须与源文件路径相对于 `test/unit/` 的结构一致。

### 运行测试（P1-8：仅限命令行）

```bash
# Run all tests
$GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit

# Run specific file
$GODOT_HOME -s addons/gut/gut_cmdln.gd -gselect=test_health_component.gd -gexit

# Verbose output
$GODOT_HOME -s addons/gut/gut_cmdln.gd -gverbosity=2 -gexit

# Run specific directory
$GODOT_HOME -s addons/gut/gut_cmdln.gd -gdir=test/unit/components -gexit
```

### GUT 断言快速参考

| 方法 | 用途 |
|--------|---------|
| `assert_eq(actual, expected, msg)` | 相等性检查 |
| `assert_ne(actual, expected, msg)` | 不等性检查 |
| `assert_true(value, msg)` | 布尔值为真 |
| `assert_false(value, msg)` | 布尔值为假 |
| `assert_null(value, msg)` | 空值检查 |
| `assert_not_null(value, msg)` | 非空检查 |
| `assert_has(obj, method, msg)` | 对象拥有方法 |
| `assert_signal_emitted(obj, signal, msg)` | 信号已发射 |
| `watch_signals(obj)` | 开始监听信号 |

### GUT 生命周期钩子

| 钩子 | 时机 | 用途 |
|------|------|---------|
| `before_all()` | 所有测试前执行一次 | 高开销的初始化 |
| `before_each()` | 每个测试前执行 | 创建全新实例 |
| `after_each()` | 每个测试后执行 | 清理 |
| `after_all()` | 所有测试后执行一次 | 全局清理 |

## 参考文档（按需加载）

### GUT 框架（项目宪法级）
- **GUT 框架完整指南**：[references/gut-testing-framework.md](references/gut-testing-framework.md)（554 行）— 完整断言参考、Mock/Double 支持、参数化测试、信号测试、生命周期管理
- **测试模式与示例**：[references/test-patterns-examples.md](references/test-patterns-examples.md)（828 行）— 即用型测试模板，覆盖玩家、敌人、背包、状态机、性能测试

### 测试工具
- **测试调试工具**：[references/test-debugging-tools.md](references/test-debugging-tools.md)（694 行）— 诊断测试失败、性能基准测试、内存泄漏检测、报告生成
- **MCP 测试集成**：[references/mcp-testing-integration.md](references/mcp-testing-integration.md)（797 行）— MCP + GUT 集成、自动化测试场景、CI/CD 配置

### 精简参考（本文件内）
- **GUT 框架摘要**：[references/gut-framework.md](references/gut-framework.md) — 断言方法、Double 和生命周期的快速参考

## 测试模板

```gdscript
# test/unit/{module_path}/test_{class_name_snake}.gd
extends GutTest

var _instance: {ClassName}

func before_each() -> void:
	_instance = {ClassName}.new()
	add_child_autoqfree(_instance)

func test_initial_state() -> void:
	assert_not_null(_instance, "Instance should be created")

func test_{method}_works() -> void:
	# Arrange
	var input: int = 10
	var expected: int = 20
	# Act
	_instance.{method}(input)
	# Assert
	assert_eq(_instance.{property}, expected,
		"{method} should set {property} correctly")

func test_{signal}_emitted() -> void:
	watch_signals(_instance)
	_instance.{trigger_method}()
	assert_signal_emitted(_instance, "{signal}",
		"{signal} should be emitted")
```

## 覆盖率目标

| 级别 | 目标 | 范围 |
|-------|--------|-------|
| 单元测试 | 70% | 独立函数和类 |
| 集成测试 | 20% | 模块间交互 |
| E2E | 10% | 关键玩家流程 |

## 与 godot-developer 的 TDD 集成

1. **红灯**：编写失败的测试（使用本技能）
2. **绿灯**：实现最少量代码（使用 `godot-developer`）
3. **重构**：在保持测试通过的前提下优化代码
4. **验证**：运行测试，检查覆盖率（使用本技能）

## 约束

- **禁止**在测试文件中使用 `load()` 或 `preload()` — 直接引用类
- **禁止**跳过 `before_each()` — 始终创建全新实例
- **必须**使用 `add_child_autoqfree()` 代替 `add_child()` 以实现自动清理
- **必须**在断言信号发射前使用 `watch_signals()`
- **必须**通过命令行运行测试（`$GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit`）
- 测试目录结构必须镜像源码目录结构
