# MCP 测试集成指南

> **重要提示**：本文档详细介绍如何将 Godot MCP 工具与 GUT 测试框架集成使用，提供完整的测试自动化和项目管理解决方案。

## 🔗 Godot MCP 工具测试功能概述

Godot MCP 工具为测试开发提供了强大的支持，包括场景创建、项目管理、资源操作等功能。通过 MCP 集成，可以大大提高 TDD 开发效率。

### MCP 测试相关功能
- **场景创建和管理**：自动化测试场景搭建
- **项目文件操作**：测试资源生成和管理
- **脚本编辑**：动态创建和修改测试脚本
- **项目运行**：自动化测试执行和结果收集

## 🎯 场景创建和测试自动化

### 使用 MCP 创建测试场景

#### 基础测试场景创建
```gdscript
# 通过 MCP 创建标准测试场景
func create_test_player_scene():
    """创建标准的玩家测试场景"""
    # 使用 MCP 创建场景根节点
    var scene_root = Node2D.new()
    scene_root.name = "TestPlayerScene"

    # 添加玩家节点
    var player = preload("res://scripts/Player.gd").new()
    player.name = "Player"
    player.position = Vector2.ZERO
    scene_root.add_child(player)

    # 添加碰撞形状
    var collision_shape = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 16.0
    collision_shape.shape = shape
    player.add_child(collision_shape)

    # 添加精灵
    var sprite = Sprite2D.new()
    sprite.texture = preload("res://assets/sprites/player.png")
    player.add_child(sprite)

    return scene_root

# 在测试中使用 MCP 创建的场景
extends GutTest

func test_player_in_test_scene():
    # 使用 MCP 创建测试场景
    var test_scene = create_test_player_scene()
    add_child_autofree(test_scene)

    var player = test_scene.get_node("Player")
    assert_not_null(player, "Test scene should contain player")
    assert_true(player.has_node("CollisionShape2D"), "Player should have collision shape")
    assert_true(player.has_node("Sprite2D"), "Player should have sprite")

    # 测试玩家功能
    player.health = 100
    player.take_damage(25)
    assert_eq(player.health, 75, "Player should take damage correctly")
```

#### 复杂测试环境搭建
```gdscript
func create_combat_test_environment():
    """创建战斗测试环境"""
    var scene_root = Node2D.new()
    scene_root.name = "CombatTestEnvironment"

    # 添加环境设置
    var game_manager = preload("res://scripts/GameManager.gd").new()
    game_manager.name = "GameManager"
    scene_root.add_child(game_manager)

    # 添加玩家
    var player_scene = preload("res://scenes/player.tscn")
    var player = player_scene.instantiate()
    player.name = "Player"
    player.position = Vector2(100, 100)
    scene_root.add_child(player)

    # 添加多个敌人
    var enemy_positions = [
        Vector2(200, 100),
        Vector2(150, 50),
        Vector2(250, 150)
    ]

    for i in range(enemy_positions.size()):
        var enemy = preload("res://scenes/enemy.tscn").instantiate()
        enemy.name = "Enemy" + str(i)
        enemy.position = enemy_positions[i]
        scene_root.add_child(enemy)

    # 添加障碍物
    create_obstacles(scene_root)

    return scene_root

func create_obstacles(parent: Node):
    """创建测试障碍物"""
    var obstacle_positions = [
        {"pos": Vector2(150, 200), "size": Vector2(50, 20)},
        {"pos": Vector2(250, 100), "size": Vector2(20, 80)}
    ]

    for obstacle_data in obstacle_positions:
        var obstacle = StaticBody2D.new()
        obstacle.position = obstacle_data.pos

        var collision_shape = CollisionShape2D.new()
        var shape = RectangleShape2D.new()
        shape.size = obstacle_data.size
        collision_shape.shape = shape
        obstacle.add_child(collision_shape)

        parent.add_child(obstacle)
```

### 自动化测试场景管理

#### 场景模板系统
```gdscript
# 场景模板管理器
class TestSceneTemplateManager:
    var templates: Dictionary = {}

    func _init():
        _register_default_templates()

    func _register_default_templates():
        # 玩家测试模板
        templates["player_basic"] = {
            "root_type": "Node2D",
            "nodes": [
                {
                    "type": "Player",
                    "name": "Player",
                    "position": Vector2.ZERO,
                    "properties": {
                        "health": 100,
                        "movement_speed": 200.0
                    }
                },
                {
                    "type": "Camera2D",
                    "name": "Camera2D",
                    "position": Vector2.ZERO
                }
            ]
        }

        # 战斗测试模板
        templates["combat_arena"] = {
            "root_type": "Node2D",
            "nodes": [
                {"type": "Player", "name": "Player", "position": Vector2(100, 100)},
                {"type": "Enemy", "name": "Enemy", "position": Vector2(300, 100)},
                {"type": "GameManager", "name": "GameManager"}
            ]
        }

    func create_scene_from_template(template_name: String) -> Node:
        if not templates.has(template_name):
            push_error("Template not found: " + template_name)
            return null

        var template = templates[template_name]
        var scene = ClassDB.instantiate(template.root_type)

        for node_data in template.nodes:
            var node = ClassDB.instantiate(node_data.type)
            node.name = node_data.name
            node.position = node_data.position

            # 设置属性
            if node_data.has("properties"):
                for prop_name in node_data.properties:
                    node.set(prop_name, node_data.properties[prop_name])

            scene.add_child(node)

        return scene

# 使用模板管理器
var template_manager = TestSceneTemplateManager.new()

func test_with_template():
    var combat_scene = template_manager.create_scene_from_template("combat_arena")
    add_child_autofree(combat_scene)

    var player = combat_scene.get_node("Player")
    var enemy = combat_scene.get_node("Enemy")

    assert_not_null(player, "Player should be created from template")
    assert_not_null(enemy, "Enemy should be created from template")
```

## 📁 测试数据生成和管理

### MCP 资源文件操作

#### 自动生成测试数据
```gdscript
# 测试数据生成器
class TestDataGenerator:
    func generate_test_players(count: int) -> Array[Dictionary]:
        var players = []
        for i in range(count):
            players.append({
                "name": "TestPlayer" + str(i),
                "health": randi_range(50, 100),
                "position": Vector2(randf_range(-100, 100), randf_range(-100, 100)),
                "equipment": generate_random_equipment()
            })
        return players

    func generate_random_equipment() -> Dictionary:
        var equipment_types = ["weapon", "armor", "accessory"]
        var selected_type = equipment_types[randi() % equipment_types.size()]

        return {
            "type": selected_type,
            "name": generate_item_name(selected_type),
            "stats": generate_item_stats(selected_type)
        }

    func generate_item_name(type: String) -> String:
        var prefixes = ["Iron", "Steel", "Magic", "Ancient"]
        var base_names = {
            "weapon": ["Sword", "Axe", "Bow", "Staff"],
            "armor": ["Chestplate", "Helmet", "Boots", "Gauntlets"],
            "accessory": ["Ring", "Amulet", "Bracelet", "Charm"]
        }

        var prefix = prefixes[randi() % prefixes.size()]
        var base_name = base_names[type][randi() % base_names[type].size()]
        return prefix + " " + base_name

    func save_test_data_to_file(data: Array[Dictionary], file_path: String):
        var file = FileAccess.open(file_path, FileAccess.WRITE)
        if file:
            file.store_var(data)
            file.close()
            print("Test data saved to: ", file_path)

# 在测试中使用生成的数据
func test_with_generated_players():
    var data_generator = TestDataGenerator.new()
    var test_players = data_generator.generate_test_players(10)

    # 保存测试数据供后续使用
    data_generator.save_test_data_to_file(test_players, "res://test_data/players.json")

    for player_data in test_players:
        var player = Player.new()
        player.name = player_data.name
        player.health = player_data.health
        player.position = player_data.position

        # 测试每个玩家的功能
        test_player_functionality(player, player_data)
```

#### 测试资源管理
```gdscript
# 测试资源管理器
class TestResourceManager:
    var created_resources: Array[String] = []

    func create_test_texture(size: Vector2i, color: Color) -> ImageTexture:
        var image = Image.create(size.x, size.y, false, Image.FORMAT_RGB8)
        image.fill(color)

        var texture = ImageTexture.new()
        texture.set_image(image)

        var resource_path = "res://test_data/temp_texture_" + str(Time.get_ticks_msec()) + ".png"
        image.save_png(resource_path)
        created_resources.append(resource_path)

        return texture

    func create_test_audio_sample(duration: float, frequency: float) -> AudioStreamWAV:
        var sample_rate = 44100
        var frames = int(duration * sample_rate)
        var audio_data = PackedFloat32Array()

        for i in range(frames):
            var time = float(i) / sample_rate
            var sample = sin(2.0 * PI * frequency * time)
            audio_data.append(sample * 0.5)  # 降低音量

        var audio_stream = AudioStreamWAV.new()
        audio_stream.data = audio_data
        audio_stream.format = AudioStreamWAV.FORMAT_16_BITS
        audio_stream.mix_rate = sample_rate
        audio_stream.stereo = false

        return audio_stream

    func cleanup_test_resources():
        for resource_path in created_resources:
            if FileAccess.file_exists(resource_path):
                DirAccess.remove_absolute(resource_path)
                print("Cleaned up: ", resource_path)

        created_resources.clear()

# 在测试中使用资源管理器
func test_with_textures_and_audio():
    var resource_manager = TestResourceManager.new()
    add_child_autofree(resource_manager)

    # 创建测试纹理
    var test_texture = resource_manager.create_test_texture(Vector2i(64, 64), Color.RED)
    var sprite = Sprite2D.new()
    sprite.texture = test_texture
    add_child_autofree(sprite)

    # 创建测试音频
    var test_audio = resource_manager.create_test_audio_sample(1.0, 440.0)  # 1秒 440Hz音调
    var audio_player = AudioStreamPlayer.new()
    audio_player.stream = test_audio
    add_child_autofree(audio_player)

    # 测试资源功能
    assert_not_null(sprite.texture, "Sprite should have texture")
    assert_not_null(audio_player.stream, "Audio player should have stream")

    # 测试音频播放
    audio_player.play()
    assert_true(audio_player.playing, "Audio should be playing")

    # 资源会在测试结束时自动清理
```

## 🔄 测试工作流自动化

### CI/CD 集成

#### 自动化测试脚本
```gdscript
# 自动化测试运行器
class AutomatedTestRunner:
    var test_results: Dictionary = {}
    var failed_tests: Array[String] = []

    func run_all_tests():
        print("Starting automated test run...")
        var start_time = Time.get_ticks_msec()

        # 运行单元测试
        run_test_suite("unit")

        # 运行集成测试
        run_test_suite("integration")

        # 运行性能测试
        run_test_suite("performance")

        var end_time = Time.get_ticks_msec()
        var total_time = (end_time - start_time) / 1000.0

        generate_test_report(total_time)

    func run_test_suite(suite_name: String):
        print("Running " + suite_name + " tests...")
        var suite_results = []

        # 这里可以集成 MCP 运行测试
        var test_files = get_test_files_for_suite(suite_name)

        for test_file in test_files:
            var result = run_single_test_file(test_file)
            suite_results.append(result)

            if not result.passed:
                failed_tests.append(test_file)

        test_results[suite_name] = suite_results

    func run_single_test_file(test_file: String) -> Dictionary:
        # 使用 MCP 运行单个测试文件
        var command = "godot -s addons/gut/gut_cmdln.gd -gtest=" + test_file + " -gexit -gjunit_xml_file=test_results_" + test_file.get_file() + ".xml"

        # 这里可以调用 MCP 执行命令
        var output = execute_command(command)

        return parse_test_output(output)

    func execute_command(command: String) -> String:
        # 模拟命令执行（实际中会调用 MCP）
        var exit_code = OS.execute(command, [], [], output)
        return output

    func parse_test_output(output: String) -> Dictionary:
        # 解析测试输出
        var lines = output.split("\n")
        var passed = false
        var test_count = 0
        var failure_count = 0

        for line in lines:
            if "Tests:" in line:
                # 解析测试数量信息
                pass
            elif "Passed:" in line:
                passed = true

        return {
            "passed": passed,
            "test_count": test_count,
            "failure_count": failure_count,
            "output": output
        }

    func generate_test_report(total_time: float):
        var report = "# Automated Test Report\n\n"
        report += "Generated: " + Time.get_datetime_string_from_system() + "\n"
        report += "Total Duration: " + str(total_time) + "s\n\n"

        var total_tests = 0
        var total_failures = 0

        for suite_name in test_results:
            var suite_results = test_results[suite_name]
            report += "## " + suite_name.capitalize() + " Tests\n\n"

            for result in suite_results:
                var status = "✅ PASS" if result.passed else "❌ FAIL"
                report += "- " + status + "\n"
                total_tests += result.test_count
                total_failures += result.failure_count

        report += "\n## Summary\n\n"
        report += "- Total Tests: " + str(total_tests) + "\n"
        report += "- Total Failures: " + str(total_failures) + "\n"
        report += "- Success Rate: " + str(100.0 - float(total_failures) / total_tests * 100.0) + "%\n"

        if failed_tests.size() > 0:
            report += "\n## Failed Tests\n\n"
            for failed_test in failed_tests:
                report += "- " + failed_test + "\n"

        # 保存报告
        var file = FileAccess.open("res://test_reports/automated_report.md", FileAccess.WRITE)
        file.store_string(report)
        file.close()

        print("Test report generated: res://test_reports/automated_report.md")

# 定期运行自动化测试
func _ready():
    if OS.get_environment("CI") == "true":
        # 在 CI 环境中运行测试
        var test_runner = AutomatedTestRunner.new()
        test_runner.run_all_tests()

        # 根据测试结果设置退出码
        if test_runner.failed_tests.size() > 0:
            OS.exit(1)  # 测试失败
        else:
            OS.exit(0)  # 测试成功
```

#### 持续集成配置
```yaml
# .github/workflows/test.yml
name: Godot Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    - name: Setup Godot
      uses: chickensoft-games/godot-action@v1
      with:
        version: 4.2.1

    - name: Install MCP Dependencies
      run: |
        pip install godot-mcp-tools

    - name: Run Tests with MCP
      run: |
        # 使用 MCP 运行测试
        mcp godot run-tests --unit --integration --performance

        # 生成覆盖率报告
        mcp godot generate-coverage --output coverage.xml

    - name: Upload Test Results
      uses: actions/upload-artifact@v2
      with:
        name: test-results
        path: |
          test_reports/
          coverage.xml

    - name: Upload Coverage
      uses: codecov/codecov-action@v1
      with:
        file: coverage.xml
```

### 测试数据收集和分析

#### 测试指标收集
```gdscript
# 测试指标收集器
class TestMetricsCollector:
    var test_metrics: Dictionary = {}
    var performance_metrics: Dictionary = {}

    func collect_test_metrics(test_name: String, metrics: Dictionary):
        test_metrics[test_name] = {
            "timestamp": Time.get_unix_time_from_system(),
            "duration": metrics.get("duration", 0.0),
            "memory_usage": metrics.get("memory_usage", 0),
            "assertions": metrics.get("assertions", 0),
            "passed": metrics.get("passed", false)
        }

    func collect_performance_metrics(test_name: String, perf_data: Dictionary):
        performance_metrics[test_name] = {
            "fps": perf_data.get("fps", 0.0),
            "frame_time": perf_data.get("frame_time", 0.0),
            "cpu_usage": perf_data.get("cpu_usage", 0.0),
            "memory_peak": perf_data.get("memory_peak", 0)
        }

    func generate_metrics_report() -> String:
        var report = "# Test Metrics Report\n\n"

        report += "## Test Execution Metrics\n\n"
        for test_name in test_metrics:
            var metrics = test_metrics[test_name]
            report += "### " + test_name + "\n"
            report += "- Duration: " + str(metrics.duration) + "s\n"
            report += "- Memory Usage: " + str(metrics.memory_usage / 1024) + "KB\n"
            report += "- Assertions: " + str(metrics.assertions) + "\n"
            report += "- Status: " + ("PASS" if metrics.passed else "FAIL") + "\n\n"

        report += "## Performance Metrics\n\n"
        for test_name in performance_metrics:
            var perf = performance_metrics[test_name]
            report += "### " + test_name + "\n"
            report += "- Average FPS: " + str(perf.fps) + "\n"
            report += "- Frame Time: " + str(perf.frame_time) + "ms\n"
            report += "- CPU Usage: " + str(perf.cpu_usage) + "%\n"
            report += "- Memory Peak: " + str(perf.memory_peak / 1024 / 1024) + "MB\n\n"

        return report

# 在测试中收集指标
extends GutTest

var metrics_collector = TestMetricsCollector.new()

func test_with_metrics_collection():
    var start_memory = OS.get_static_memory_usage_by_type()[0]
    var start_time = Time.get_ticks_msec() / 1000.0

    # 执行测试逻辑
    var player = Player.new()
    add_child_autofree(player)

    # 模拟游戏循环并收集性能数据
    var fps_samples = []
    for i in range(100):
        var frame_start = Time.get_ticks_msec()

        player._process(1.0 / 60.0)

        var frame_time = Time.get_ticks_msec() - frame_start
        fps_samples.append(1000.0 / frame_time)

    var end_time = Time.get_ticks_msec() / 1000.0
    var end_memory = OS.get_static_memory_usage_by_type()[0]

    # 计算指标
    var test_metrics = {
        "duration": end_time - start_time,
        "memory_usage": end_memory - start_memory,
        "assertions": gut.get_assert_count(),
        "passed": gut.get_test_count() == gut.get_pass_count()
    }

    var performance_metrics = {
        "fps": calculate_average(fps_samples),
        "frame_time": 1000.0 / calculate_average(fps_samples),
        "cpu_usage": estimate_cpu_usage(),
        "memory_peak": get_peak_memory_usage()
    }

    # 收集指标
    metrics_collector.collect_test_metrics("test_with_metrics", test_metrics)
    metrics_collector.collect_performance_metrics("test_with_metrics", performance_metrics)

    # 测试断言
    assert_gt(calculate_average(fps_samples), 50.0, "Should maintain reasonable FPS")

func calculate_average(values: Array) -> float:
    if values.size() == 0:
        return 0.0

    var sum = 0.0
    for value in values:
        sum += value

    return sum / values.size()

func estimate_cpu_usage() -> float:
    # 简单的 CPU 使用率估算
    return randf_range(10.0, 80.0)  # 实际中需要真实的测量方法

func get_peak_memory_usage() -> int:
    # 获取峰值内存使用
    return OS.get_static_memory_usage_by_type()[0]
```

## 🔧 高级 MCP 集成技巧

### 动态测试生成

#### 基于配置的测试生成
```gdscript
# 动态测试生成器
class DynamicTestGenerator:
    func generate_tests_from_config(config_file: String):
        var config = load_json_config(config_file)

        for test_config in config.tests:
            generate_test_file(test_config)

    func generate_test_file(test_config: Dictionary):
        var template = load_test_template()
        var test_content = template.format(test_config)

        var file_path = "res://test/generated/" + test_config.name + ".gd"
        save_test_file(file_path, test_content)

        print("Generated test file: " + file_path)

    func load_test_template() -> String:
        return """
extends GutTest

func test_{test_name}():
    # Generated test for {feature}
    var {object_name} = {object_type}.new()
    add_child_autofree({object_name})

    # Test implementation
    {test_implementation}

func test_{test_name}_edge_cases():
    # Edge case testing
    {edge_case_tests}
"""

# 配置文件示例 (test_config.json)
{
    "tests": [
        {
            "name": "player_health_system",
            "feature": "Player Health System",
            "object_name": "player",
            "object_type": "Player",
            "test_implementation": """
# Test initial health
assert_eq(player.health, 100, "Player should start with 100 health")

# Test damage
player.take_damage(25)
assert_eq(player.health, 75, "Player should take damage correctly")

# Test healing
player.heal(20)
assert_eq(player.health, 95, "Player should heal correctly")
            """,
            "edge_case_tests": """
# Test health boundaries
player.health = 0
player.take_damage(10)
assert_eq(player.health, 0, "Health should not go below 0")

player.health = 100
player.heal(50)
assert_eq(player.health, 100, "Health should not exceed maximum")
            """
        }
    ]
}

# 使用动态测试生成器
func generate_dynamic_tests():
    var generator = DynamicTestGenerator.new()
    generator.generate_tests_from_config("res://test/test_config.json")
```

### 智能测试优化

#### 测试优先级和并行化
```gdscript
# 智能测试调度器
class SmartTestScheduler:
    var test_priorities: Dictionary = {}
    var test_dependencies: Dictionary = {}
    var test_execution_history: Array[Dictionary] = []

    func schedule_tests() -> Array[String]:
        var scheduled_tests = []

        # 优先级排序
        var sorted_tests = get_tests_sorted_by_priority()

        # 考虑依赖关系
        for test in sorted_tests:
            if can_execute_test(test):
                scheduled_tests.append(test)

        return scheduled_tests

    func get_tests_sorted_by_priority() -> Array[String]:
        var tests = test_priorities.keys()
        tests.sort_custom(func(a, b):
            return test_priorities[a] > test_priorities[b]
        )
        return tests

    func can_execute_test(test_name: String) -> bool:
        if not test_dependencies.has(test_name):
            return true

        var dependencies = test_dependencies[test_name]
        for dep in dependencies:
            if not was_test_successful(dep):
                return false

        return true

    func was_test_successful(test_name: String) -> bool:
        for history in test_execution_history:
            if history.test == test_name:
                return history.success
        return true  # 默认认为成功

# 并行测试执行器
class ParallelTestExecutor:
    var max_parallel_tests = 4
    var running_tests: Array[Thread] = []

    func execute_tests_parallel(tests: Array[String]):
        var test_queue = tests.duplicate()
        var completed_tests = []

        while test_queue.size() > 0 or running_tests.size() > 0:
            # 启动新测试
            while running_tests.size() < max_parallel_tests and test_queue.size() > 0:
                var test_name = test_queue.pop_front()
                var thread = Thread.new()
                thread.start(_execute_test.bind(test_name))
                running_tests.append(thread)

            # 检查完成的测试
            var completed_threads = []
            for thread in running_tests:
                if not thread.is_alive():
                    completed_threads.append(thread)

            for thread in completed_threads:
                running_tests.erase(thread)
                thread.wait_to_finish()
                completed_threads.append(thread)

            # 短暂等待避免 CPU 占用过高
            OS.delay_msec(10)

        return completed_tests

    func _execute_test(test_name: String):
        # 在独立线程中执行测试
        var command = "godot -s addons/gut/gut_cmdln.gd -gtest=res://test/" + test_name + ".gd -gexit"
        OS.execute(command, [], [], null)
```

这个 MCP 测试集成指南展示了如何将 Godot MCP 工具与 GUT 测试框架深度集成，提供完整的自动化测试解决方案，从场景创建到 CI/CD 集成，全面提升 TDD 开发效率。