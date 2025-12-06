# GUT测试框架使用指南

## 什么是GUT？

GUT（Godot Unit Test）是Godot的单元测试框架，允许开发者编写和运行自动化测试。它提供了丰富的断言方法、测试组织结构和运行功能。

## 安装和配置

### 1. 安装GUT插件

1. 下载GUT插件：
   - GitHub地址：https://github.com/bitwes/Gut
   - 或通过Godot Asset Library搜索"GUT"

2. 安装到项目：
   ```
   addons/
   └── gut/
       ├── plugin.cfg
       ├── plugin.gd
       └── ... (其他GUT文件)
   ```

3. 在项目设置中启用插件：
   - 项目 → 项目设置 → 插件
   - 勾选"GUT"插件

### 2. 配置GUT

创建测试运行配置：
```gdscript
# test/test_runner.gd
extends SceneTree

func _ready():
    # 加载并运行测试
    var gut = Gut.new()
    gut.add_script('res://test/unit/')
    gut.add_script('res://test/integration/')
    gut.test()
    quit()
```

## 基础测试结构

### 1. 基本测试文件

```gdscript
# test/unit/example_test.gd
extends "res://addons/gut/test.gd"

class_name ExampleTest

# 测试类变量
var player: Player

# 每个测试前运行
func before_each():
    player = Player.new()
    add_child_autofree(player)  # 自动清理

# 每个测试后运行
func after_each():
    # 清理操作

# 测试方法（必须以test_开头）
func test_player_initial_health():
    assert_eq(player.current_health, player.max_health)

# 测试套件前后运行
func before_all():
    print("开始测试Player功能")

func after_all():
    print("Player功能测试完成")
```

### 2. 测试脚本目录结构

```
test/
├── unit/                   # 单元测试
│   ├── player/
│   │   ├── test_player_controller.gd
│   │   └── test_player_movement.gd
│   ├── enemy/
│   │   └── test_enemy_ai.gd
│   └── ui/
│       └── test_button_handler.gd
├── integration/            # 集成测试
│   ├── test_player_scene.gd
│   └── test_game_systems.gd
└── test_suite.gd          # 测试套件配置
```

## 断言方法

### 1. 基本断言

```gdscript
# 相等断言
assert_eq(actual, expected, "消息")
assert_ne(actual, expected, "消息")

# 数值断言
assert_almost_eq(actual, expected, tolerance, "消息")

# 布尔断言
assert_true(condition, "消息")
assert_false(condition, "消息")

# 空值断言
assert_null(value, "消息")
assert_not_null(value, "消息")
```

### 2. 字符串断言

```gdscript
# 字符串包含
assert_contains(haystack, needle, "消息")

# 字符串以...开头
assert_starts_with(text, prefix, "消息")

# 字符串以...结尾
assert_ends_with(text, suffix, "消息")

# 正则匹配
assert_matches(text, pattern, "消息")
```

### 3. 数组断言

```gdscript
# 数组包含
assert_contains(arr, item, "消息")

# 数组长度
assert_eq(arr.size(), expected_size, "消息")

# 数组相等
assert_eq(arr1, arr2, "消息")
```

### 4. 信号断言

```gdscript
# 等待信号
signal_emitted = false
player.health_changed.connect(func(): signal_emitted = true)
player.take_damage(1)
await get_tree().process_frame
assert_true(signal_emitted, "健康变化信号未发出")

# 使用GUT的信号断言
wait_for_signal(player, "health_changed", 1.0)
assert_signal_emitted(player, "health_changed")
```

### 5. 错误和警告断言

```gdscript
# 期望警告
assert_warns(func(): player.take_damage(-1))

# 期望错误
assert_errors(func(): invalid_operation())

# 检查特定警告数量
assert_warn_count(2)
assert_error_count(0)
```

## 测试场景和节点

### 1. 测试场景

```gdscript
func test_scene_loading():
    # 加载场景
    var player_scene = load("res://scenes/player/Player.tscn")
    var player_instance = player_scene.instantiate()

    # 添加到测试树
    add_child_autofree(player_instance)

    # 测试场景
    assert_true(player_instance.has_node("Sprite2D"))
    assert_true(player_instance.has_node("CollisionShape2D"))
```

### 2. 测试节点引用

```gdscript
func test_node_references():
    var player = preload("res://scenes/player/Player.tscn").instantiate()
    add_child_autofree(player)

    # 等待节点准备就绪
    await get_tree().process_frame

    # 测试@onready引用
    assert_not_null(player.sprite)
    assert_not_null(player.collision_shape)
```

### 3. 测试输入模拟

```gdscript
func test_input_handling():
    var player = Player.new()
    add_child_autofree(player)

    # 模拟输入
    Input.action_press("ui_right")
    player._physics_process(0.016)

    assert_gt(player.velocity.x, 0, "玩家应该向右移动")

    # 清理输入
    Input.action_release("ui_right")
```

## 测试数据和模拟

### 1. 使用测试数据

```gdscript
func test_with_multiple_data():
    var test_data = [
        {"damage": 1, "expected": 2},
        {"damage": 2, "expected": 1},
        {"damage": 3, "expected": 0}
    ]

    for data in test_data:
        player.current_health = 3
        player.take_damage(data.damage)
        assert_eq(player.current_health, data.expected)
```

### 2. 创建模拟对象（Doubles）

```gdscript
func test_with_mock_object():
    # 创建模拟对象
    var mock_input = double(InputManager).new()
    mock_input.is_jump_pressed = true

    # 注入模拟对象
    player.input_manager = mock_input

    # 测试
    player._process(0.016)
    assert_true(player.is_jumping)
```

### 3. 存根方法

```gdscript
func test_with_stubbed_method():
    # 存根随机数生成
    stub(RNG, 'randi_range').to_return(5)

    var damage = player.calculate_damage()
    assert_eq(damage, 5)
```

## 参数化测试

### 1. 使用参数化测试

```gdscript
func test_parameterized_movement():
    var test_cases = [
        {
            "input": Vector2.LEFT,
            "expected": Vector2.LEFT * 300,
            "description": "向左移动"
        },
        {
            "input": Vector2.RIGHT,
            "expected": Vector2.RIGHT * 300,
            "description": "向右移动"
        }
    ]

    for case in test_cases:
        player.handle_input(case.input)
        assert_eq(
            player.velocity,
            case.expected,
            case.description
        )
```

### 2. 使用GUT的参数化测试

```gdscript
func test_movement_parameters(
    input = ParameterFactory.named_parameters([
        ["left", Vector2.LEFT],
        ["right", Vector2.RIGHT],
        ["up", Vector2.UP],
        ["down", Vector2.DOWN]
    ])
):
    player.handle_movement(input)
    assert_true(player.velocity.length() > 0)
```

## 性能测试

```gdscript
func test_performance():
    var start_time = Time.get_ticks_msec()

    # 执行操作
    for i in range(1000):
        player.update_animation()

    var end_time = Time.get_ticks_msec()
    var duration = end_time - start_time

    assert_lt(duration, 16, "动画更新应在16ms内完成")
```

## 异步测试

### 1. 测试计时器

```gdscript
func test_timer_functionality():
    var timer = Timer.new()
    timer.wait_time = 0.1
    timer.one_shot = true
    add_child_autofree(timer)

    timer.start()
    await timer.timeout

    assert_true(timer.is_stopped())
```

### 2. 测试动画

```gdscript
func test_animation_playback():
    player.play_animation("run")

    # 等待动画播放
    await get_tree().create_timer(0.5).timeout

    assert_eq(player.animation_player.current_animation, "run")
```

## 运行测试

### 1. 在编辑器中运行

1. 打开GUT面板：项目 → 工具 → GUT
2. 选择测试目录
3. 点击"Run Tests"

### 2. 命令行运行

```bash
godot --headless --script test/test_runner.gd
```

### 3. 运行特定测试

```gdscript
# 在测试文件中
func test_specific():
    pass

# 运行时指定
gut.run_test_script('res://test/unit/player/test_player.gd')
```

## 测试配置选项

### 1. GUT配置

```gdscript
# gut_config.gd
extends Resource
class_name GutConfig

func _init():
    # 测试目录
    directories = ["res://test/"]

    # 包含模式
    include_subdirs = true

    # 输出设置
    log_level = 3  # 详细日志

    # 运行设置
    should_exit = true
    should_print_summary = true
```

### 2. 自定义测试设置

```gdscript
# 在测试文件中
func before_all():
    gut.set_yield_between_tests(true)  # 测试间等待
    gut.double_strategy = gut.DOUBLE_STRATEGY.INCLUDE_NATIVE  # 包含原生方法
```

## 最佳实践

### 1. 测试组织

- **一个测试一个概念**：每个测试只验证一个行为
- **描述性命名**：测试名称应清楚表达意图
- **使用测试夹具**：使用before_each设置测试环境
- **保持快速**：避免长时间运行的测试

### 2. 测试隔离

```gdscript
func before_each():
    # 创建新实例，避免测试间污染
    player = Player.new()
    add_child_autofree(player)

func after_each():
    # 清理全局状态
    Input.action_release("ui_accept")
```

### 3. 断言策略

```gdscript
# 好的断言：明确期望
assert_eq(player.health, 0, "玩家死亡时健康值应为0")

# 避免的断言：过于具体
assert_eq(player.velocity.x, 0.0, "不关心具体速度值")
```

### 4. 模拟和存根

- **只模拟需要的接口**
- **使用最小的模拟**
- **验证重要的交互**

## 调试测试

### 1. 使用调试输出

```gdscript
func test_debugging_example():
    print("当前健康: ", player.current_health)
    print("期望健康: ", expected_health)
    print("差值: ", player.current_health - expected_health)

    assert_eq(player.current_health, expected_health)
```

### 2. 使用断点

```gdscript
func test_with_breakpoint():
    breakpoint  # GUT会在此暂停
    player.complex_operation()
```

### 3. 查看测试输出

GUT提供详细的测试输出，包括：
- 测试结果
- 断言失败详情
- 性能数据
- 覆盖率信息

## 持续集成

### 1. CI配置示例（GitHub Actions）

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Godot
        uses: chickensoft-games/godot-action@v1
        with:
          version: 4.2
      - name: Run Tests
        run: godot --headless --script test/test_runner.gd
```

### 2. 测试覆盖率

GUT可以生成测试覆盖率报告，帮助识别未测试的代码。

## 常见问题

### 1. 测试随机失败
- **原因**：依赖时序或随机数
- **解决**：使用固定种子或模拟

### 2. 测试运行缓慢
- **原因**：加载资源过多
- **解决**：使用轻量级测试数据

### 3. 测试难以维护
- **原因**：测试过于复杂
- **解决**：简化测试，提取公共代码

通过掌握GUT测试框架，你可以创建可靠、可维护的Godot游戏代码。记住，好的测试是高质量代码的基石。