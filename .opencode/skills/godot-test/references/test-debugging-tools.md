# 测试调试工具指南

> **重要提示**：本文档提供 GUT 测试框架的完整调试和工具使用指南，帮助开发者有效诊断测试问题、分析性能和优化测试质量。

## 🔧 GUT 测试运行和结果分析

### 基础测试运行命令

#### 命令行运行测试
```bash
# 运行所有测试
godot -s addons/gut/gut_cmdln.gd -gexit

# 运行特定测试文件
godot -s addons/gut/gut_cmdln.gd -gtest=res://test/unit/test_player.gd -gexit

# 运行指定目录的测试
godot -s addons/gut/gut_cmdln.gd -gdir=res://test/unit -gexit

# 运行指定测试方法
godot -s addons/gut/gut_cmdln.gd -gtest=res://test/unit/test_player.gd -gunit_test_name=test_player_movement -gexit

# 详细输出模式
godot -s addons/gut/gut_cmdln.gd -glog_level=0 -gexit

# 包含子目录
godot -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit
```

#### 运行特定测试类别
```bash
# 只运行单元测试
godot -s addons/gut/gut_cmdln.gd -gdir=res://test/unit -gexit

# 只运行集成测试
godot -s addons/gut/gut_cmdln.gd -gdir=res://test/integration -gexit

# 运行性能测试
godot -s addons/gut/gut_cmdln.gd -gdir=res://test/performance -gexit
```

### 测试结果分析和报告

#### 控制台输出分析
```bash
# 运行测试并查看详细输出
godot -s addons/gut/gut_cmdln.gd -gtest=res://test/unit/test_player.gd -glog_level=0 -gexit

# 输出示例分析：
# ==========================
# Running test_player.gd
# ==========================
#
# test_player_initialization...PASS
# test_player_movement...FAIL
#   Expected: 100.0, Got: 95.0
#   At: test/unit/test_player.gd:45
#   Message: Player should move 100 units in 1 second
#
# test_player_death...PASS
#
# Summary:
# Tests: 3, Passed: 2, Failed: 1, Orphans: 0
# Duration: 0.045s
```

#### 生成 XML 报告
```bash
# 生成 JUnit XML 格式的报告
godot -s addons/gut/gut_cmdln.gd -gjunit_xml_file=res://test_results.xml -gexit

# 生成 HTML 报告
godot -s addons/gut/gut_cmdln.gd -ginclude_subdirs -gjunit_xml_file=test_results.xml -gexit

# 报告文件会在指定路径生成，可用于 CI/CD 集成
```

### 测试覆盖率分析

#### 基础覆盖率检查
```gdscript
# 在测试中添加覆盖率标记
func test_comprehensive_player_functionality():
    # 覆盖：Player.__new, Player._ready, Player.set_health
    var player = Player.new()
    assert_eq(player.health, 100)

    # 覆盖：Player.take_damage, Player.health_changed signal
    player.take_damage(30)
    assert_eq(player.health, 70)

    # 覆盖：Player.heal, Player.is_dead
    player.heal(50)
    assert_eq(player.health, 100)
    assert_false(player.is_dead())

    print("Coverage check: All main player functions tested")
```

#### 手动覆盖率跟踪
```gdscript
# 创建覆盖率跟踪器
class TestCoverageTracker:
    var covered_functions: Array[String] = []
    var covered_branches: Array[String] = []

    func mark_function_covered(func_name: String):
        if func_name not in covered_functions:
            covered_functions.append(func_name)

    func mark_branch_covered(branch_name: String):
        if branch_name not in covered_branches:
            covered_branches.append(branch_name)

    func get_coverage_percentage(total_functions: int) -> float:
        return float(covered_functions.size()) / total_functions * 100.0

# 在测试中使用
var coverage_tracker = TestCoverageTracker.new()

func test_player_movement():
    var player = Player.new()
    coverage_tracker.mark_function_covered("Player.__new")

    player.move_right()
    coverage_tracker.mark_function_covered("Player.move_right")
    coverage_tracker.mark_branch_covered("movement_input_positive")

    print("Coverage: ", coverage_tracker.get_coverage_percentage(10), "%")
```

## 🐛 测试失败诊断和调试方法

### 常见失败类型分析

#### 断言失败 (Assertion Failures)
```gdscript
# 问题：测试预期值与实际值不匹配
func test_player_movement():
    var player = Player.new()
    player.movement_speed = 100.0

    player.move_right()
    player._process(1.0)

    # 断言失败：预期 100.0，实际得到 95.0
    assert_eq(player.position.x, 100.0, "Player should move 100 units")

# 调试方法：
# 1. 添加调试输出
func test_player_movement():
    var player = Player.new()
    player.movement_speed = 100.0

    player.move_right()
    player._process(1.0)

    # 调试输出
    print("Player position: ", player.position)
    print("Player velocity: ", player.velocity)
    print("Input direction: ", player.input_direction)
    print("Movement speed: ", player.movement_speed)

    assert_eq(player.position.x, 100.0, "Player should move 100 units")

# 2. 使用调试断点
func test_player_movement():
    var player = Player.new()
    player.movement_speed = 100.0

    player.move_right()
    player._process(1.0)

    # 在断言前设置断点检查状态
    breakpoint
    assert_eq(player.position.x, 100.0, "Player should move 100 units")
```

#### 空指针/空引用错误
```gdscript
# 问题：访问空对象
func test_enemy_targeting():
    var enemy = Enemy.new()
    var player: Player = null  # 忘记初始化

    enemy.set_target(player)  # 空指针错误

# 调试方法：
func test_enemy_targeting():
    var enemy = Enemy.new()
    var player = Player.new()  # 正确初始化

    # 添加空检查
    assert_not_null(player, "Player should not be null")
    assert_not_null(enemy, "Enemy should not be null")

    enemy.set_target(player)

    # 验证设置成功
    assert_eq(enemy.get_target(), player, "Enemy should have correct target")
```

#### 信号连接问题
```gdscript
# 问题：信号未正确连接或发射
func test_signal_communication():
    var emitter = SignalEmitter.new()
    var receiver = SignalReceiver.new()

    # 信号连接可能失败
    emitter.test_signal.connect(receiver.handle_signal)

    emitter.emit_signal("test_signal")

    # 断言失败：信号未触发
    assert_signal_emitted(emitter, "test_signal")

# 调试方法：
func test_signal_communication():
    var emitter = SignalEmitter.new()
    var receiver = SignalReceiver.new()

    # 检查信号是否存在
    assert_has_signal(emitter, "test_signal", "Emitter should have test_signal")

    # 检查方法是否存在
    assert_has_method(receiver, "handle_signal", "Receiver should have handle_signal method")

    # 检查连接是否成功
    var connection_result = emitter.test_signal.connect(receiver.handle_signal)
    assert_eq(connection_result, OK, "Signal connection should succeed")

    # 添加调试监听器
    emitter.test_signal.connect(func(): print("Signal emitted successfully"))

    emitter.emit_signal("test_signal")

    # 等待信号处理
    await get_tree().process_frame
    await get_tree().process_frame

    assert_signal_emitted(emitter, "test_signal")
    assert_called(receiver, "handle_signal")
```

### 高级调试技巧

#### 使用 GUT 内置调试功能
```gdscript
extends GutTest

func test_complex_interaction():
    var system = ComplexSystem.new()
    add_child_autofree(system)

    # 启用详细日志
    gut.logger.get_logger('test').level = gut.logger.LOG_LEVEL_ALL

    # 使用 p（print）进行调试输出
    p("Starting complex interaction test")
    p("System initial state: ", system.get_state())

    # 执行操作
    system.do_complex_operation()

    p("System after operation: ", system.get_state())
    p("System internal data: ", system._internal_debug_info())

    # 暂停执行进行检查（仅在调试模式下）
    if Input.is_key_pressed(KEY_SHIFT):
        get_tree().paused = true
        print("Test paused for debugging")

    assert_eq(system.get_state(), "expected_state")
```

#### 条件断点
```gdscript
func test_random_behavior():
    var random_generator = RandomNumberGenerator.new()
    random_generator.seed = 12345  # 固定种子保证可重现

    for i in range(100):
        var result = random_generator.randf()

        # 条件断点：只有特定值时触发
        if result > 0.95:
            print("High random value generated: ", result, " at iteration ", i)
            breakpoint  # 手动断点

        assert_lt(result, 1.0, "Random value should be less than 1.0")
```

#### 内存泄漏检测
```gdscript
func test_memory_management():
    var initial_memory = OS.get_static_memory_usage_by_type()[0]

    # 创建大量对象
    var objects = []
    for i in range(1000):
        var obj = HeavyObject.new()
        obj.initialize_large_data()
        objects.append(obj)

    var peak_memory = OS.get_static_memory_usage_by_type()[0]
    print("Memory increase: ", (peak_memory - initial_memory) / 1024.0 / 1024.0, "MB")

    # 清理对象
    for obj in objects:
        obj.queue_free()
    objects.clear()

    # 等待垃圾回收
    for i in range(3):
        await get_tree().process_frame

    var final_memory = OS.get_static_memory_usage_by_type()[0]
    var memory_released = peak_memory - final_memory
    print("Memory released: ", memory_released / 1024.0 / 1024.0, "MB")

    # 验证大部分内存被释放
    assert_gt(memory_released, (peak_memory - initial_memory) * 0.8, "Most memory should be released")
```

## 📊 性能测试和基准测试工具

### 基础性能测试框架
```gdscript
extends GutTest

class PerformanceTester:
    var start_time: float = 0.0
    var iterations: int = 0

    func start_timing():
        start_time = Time.get_ticks_msec() / 1000.0
        iterations = 0

    func record_iteration():
        iterations += 1

    func get_elapsed_time() -> float:
        return Time.get_ticks_msec() / 1000.0 - start_time

    func get_average_time() -> float:
        return get_elapsed_time() / iterations if iterations > 0 else 0.0

# 性能测试模板
var perf_tester = PerformanceTester.new()

func test_pathfinding_performance():
    var pathfinder = AStarPathfinder.new()
    var grid_size = 100
    var complexity_level = 5  # 1-10 复杂度级别

    pathfinder.setup_complex_grid(grid_size, complexity_level)

    perf_tester.start_timing()

    # 运行多次测试
    for i in range(100):
        var start = Vector2i(randi() % grid_size, randi() % grid_size)
        var end = Vector2i(randi() % grid_size, randi() % grid_size)

        var path = pathfinder.find_path(start, end)
        perf_tester.record_iteration()

        assert_not_null(path, "Path should be found")

    var total_time = perf_tester.get_elapsed_time()
    var avg_time = perf_tester.get_average_time()

    print("Pathfinding Performance:")
    print("  Total time: ", total_time, "s")
    print("  Average time per search: ", avg_time * 1000, "ms")
    print("  Iterations: ", perf_tester.iterations)

    # 性能断言
    assert_lt(avg_time, 0.001, "Average pathfinding should be under 1ms")
    assert_lt(total_time, 0.1, "Total test should complete within 100ms")
```

### 帧率性能测试
```gdscript
func test_game_loop_performance():
    var game_scene = preload("res://scenes/game.tscn").instantiate()
    add_child_autofree(game_scene)

    var frame_count = 0
    var start_time = Time.get_ticks_msec()
    var target_fps = 60.0
    var frame_time_budget = 1000.0 / target_fps  # 16.67ms per frame

    # 运行500帧测试
    for i in range(500):
        var frame_start = Time.get_ticks_msec()

        game_scene._process(1.0 / target_fps)
        game_scene._physics_process(1.0 / target_fps)

        # 模拟渲染时间
        game_scene._draw()

        var frame_end = Time.get_ticks_msec()
        var frame_time = frame_end - frame_start

        frame_count += 1

        # 检查帧时间是否超出预算
        if frame_time > frame_time_budget:
            print("Frame ", frame_count, " exceeded budget: ", frame_time, "ms")

        # 每秒报告一次
        if frame_count % target_fps == 0:
            var elapsed = (frame_end - start_time) / 1000.0
            var fps = frame_count / elapsed
            print("Current FPS: ", fps)

    var total_time = (Time.get_ticks_msec() - start_time) / 1000.0
    var average_fps = frame_count / total_time

    print("Performance Results:")
    print("  Total frames: ", frame_count)
    print("  Total time: ", total_time, "s")
    print("  Average FPS: ", average_fps)

    # 性能断言
    assert_gt(average_fps, target_fps * 0.9, "Should maintain at least 90% of target FPS")
```

### 内存使用性能测试
```gdscript
func test_memory_usage_patterns():
    var initial_memory = OS.get_static_memory_usage_by_type()[0]
    var memory_samples = []

    # 模拟游戏循环中的内存使用
    for cycle in range(10):
        var cycle_start_memory = OS.get_static_memory_usage_by_type()[0]

        # 创建临时对象
        var temp_objects = []
        for i in range(100):
            var obj = GameObject.new()
            obj.generate_large_data()
            temp_objects.append(obj)

        # 使用对象
        for obj in temp_objects:
            obj.process_simulation()

        # 清理对象
        for obj in temp_objects:
            obj.queue_free()
        temp_objects.clear()

        # 等待垃圾回收
        await get_tree().process_frame
        await get_tree().process_frame

        var cycle_end_memory = OS.get_static_memory_usage_by_type()[0]
        var cycle_memory_usage = cycle_end_memory - cycle_start_memory
        memory_samples.append(cycle_memory_usage)

        print("Cycle ", cycle + 1, " memory usage: ", cycle_memory_usage / 1024.0, "KB")

    var final_memory = OS.get_static_memory_usage_by_type()[0]
    var total_memory_increase = final_memory - initial_memory
    var average_cycle_memory = 0

    for sample in memory_samples:
        average_cycle_memory += sample

    average_cycle_memory /= memory_samples.size()

    print("Memory Analysis:")
    print("  Initial memory: ", initial_memory / 1024.0 / 1024.0, "MB")
    print("  Final memory: ", final_memory / 1024.0 / 1024.0, "MB")
    print("  Total increase: ", total_memory_increase / 1024.0 / 1024.0, "MB")
    print("  Average cycle memory: ", average_cycle_memory / 1024.0, "KB")

    # 内存泄漏检测
    assert_lt(total_memory_increase, 50 * 1024 * 1024, "Memory increase should be under 50MB")
    assert_lt(average_cycle_memory, 1024 * 1024, "Average cycle memory should be under 1MB")
```

## 📈 测试报告生成和分析

### 自动化测试报告
```gdscript
# 测试报告生成器
class TestReportGenerator:
    var test_results: Dictionary = {}
    var performance_data: Array[Dictionary] = []
    var coverage_data: Dictionary = {}

    func add_test_result(test_name: String, passed: bool, duration: float, error_message: String = ""):
        test_results[test_name] = {
            "passed": passed,
            "duration": duration,
            "error": error_message,
            "timestamp": Time.get_datetime_string_from_system()
        }

    func add_performance_data(test_name: String, metrics: Dictionary):
        performance_data.append({
            "test": test_name,
            "metrics": metrics,
            "timestamp": Time.get_datetime_string_from_system()
        })

    func generate_markdown_report() -> String:
        var report = "# Test Report\n\n"
        report += "Generated: " + Time.get_datetime_string_from_system() + "\n\n"

        # 测试结果摘要
        var total_tests = test_results.size()
        var passed_tests = 0
        var total_duration = 0.0

        for result in test_results.values():
            if result.passed:
                passed_tests += 1
            total_duration += result.duration

        var pass_rate = float(passed_tests) / total_tests * 100.0

        report += "## Summary\n\n"
        report += "- **Total Tests**: " + str(total_tests) + "\n"
        report += "- **Passed**: " + str(passed_tests) + " (" + str(pass_rate) + "%)\n"
        report += "- **Failed**: " + str(total_tests - passed_tests) + "\n"
        report += "- **Total Duration**: " + str(total_duration) + "s\n\n"

        # 详细的测试结果
        report += "## Test Results\n\n"
        for test_name in test_results:
            var result = test_results[test_name]
            var status = "✅ PASS" if result.passed else "❌ FAIL"
            report += "- " + status + " **" + test_name + "** (" + str(result.duration) + "s)\n"
            if not result.passed and result.error != "":
                report += "  - Error: " + result.error + "\n"

        # 性能数据
        if performance_data.size() > 0:
            report += "\n## Performance Data\n\n"
            for perf in performance_data:
                report += "### " + perf.test + "\n"
                for metric in perf.metrics:
                    report += "- " + metric + ": " + str(perf.metrics[metric]) + "\n"

        return report

# 使用报告生成器
var report_generator = TestReportGenerator.new()

func test_with_reporting():
    var start_time = Time.get_ticks_msec() / 1000.0

    # 执行测试逻辑
    var result = some_test_function()
    var test_passed = validate_result(result)

    var duration = Time.get_ticks_msec() / 1000.0 - start_time

    # 添加到报告
    report_generator.add_test_result("some_test_function", test_passed, duration)

    # 生成报告
    var report = report_generator.generate_markdown_report()
    FileAccess.open("res://test_reports/latest_report.md", FileAccess.WRITE).store_string(report)
```

### 持续集成报告
```gdscript
# CI 友好的测试报告
func generate_ci_report():
    var report = {
        "timestamp": Time.get_unix_time_from_system(),
        "test_results": {},
        "performance_metrics": {},
        "coverage": {}
    }

    # 收集测试结果
    var all_tests = get_all_test_methods()
    for test_name in all_tests:
        var result = run_single_test(test_name)
        report.test_results[test_name] = {
            "status": "passed" if result.passed else "failed",
            "duration": result.duration,
            "error": result.error_message
        }

    # 生成 JSON 报告
    var json_string = JSON.stringify(report)
    var file = FileAccess.open("res://test_reports/ci_report.json", FileAccess.WRITE)
    file.store_string(json_string)

    # 同时生成 JUnit XML 格式
    generate_junit_xml_report()
```

## 🛠️ 测试工具集成和扩展

### 自定义测试工具
```gdscript
# 自定义测试断言
extends GutTest

# 扩展断言方法
func assert_approximately_equal(actual: float, expected: float, tolerance: float, context: String = ""):
    var difference = abs(actual - expected)
    if difference > tolerance:
        var msg = "Values not approximately equal: expected %s ± %s, got %s" % [expected, tolerance, actual]
        if context != "":
            msg = context + ": " + msg
        fail_test(msg)

func assert_vector2_equal(actual: Vector2, expected: Vector2, tolerance: float = 0.01, context: String = ""):
    assert_approximately_equal(actual.x, expected.x, tolerance, context + ".x")
    assert_approximately_equal(actual.y, expected.y, tolerance, context + ".y")

func assert_scene_structure_valid(scene: Node, required_nodes: Array[String]):
    for node_path in required_nodes:
        var node = scene.get_node_or_null(node_path)
        assert_not_null(node, "Scene should have required node: " + node_path)

# 使用自定义断言
func test_player_position_precision():
    var player = Player.new()
    player.move_precise(Vector2(1.41421356, 1.41421356))
    player._process(1.0)

    # 使用自定义断言检查浮点数精度
    assert_approximately_equal(player.position.x, 1.414, 0.001, "Player X position")
    assert_vector2_equal(player.position, Vector2(1.414, 1.414), 0.001, "Player position")
```

### 测试数据生成器
```gdscript
# 测试数据生成器
class TestDataGenerator:
    var rng: RandomNumberGenerator

    func _init():
        rng = RandomNumberGenerator.new()
        rng.randomize()

    func generate_player() -> Player:
        var player = Player.new()
        player.health = rng.randi_range(50, 100)
        player.position = Vector2(rng.randf_range(-100, 100), rng.randf_range(-100, 100))
        player.movement_speed = rng.randf_range(50, 200)
        return player

    func generate_item() -> Item:
        var item_types = ["weapon", "potion", "armor", "consumable"]
        var item_type = item_types[rng.randi() % item_types.size()]

        match item_type:
            "weapon":
                return WeaponItem.new()
            "potion":
                return PotionItem.new()
            "armor":
                return ArmorItem.new():
            "consumable":
                return ConsumableItem.new()

    func generate_test_scenario() -> Dictionary:
        return {
            "player": generate_player(),
            "enemies": [generate_enemy() for i in range(rng.randi_range(1, 5))],
            "items": [generate_item() for i in range(rng.randi_range(0, 10))],
            "environment": generate_environment()
        }

# 在测试中使用数据生成器
func test_various_scenarios():
    var generator = TestDataGenerator.new()

    for i in range(100):
        var scenario = generator.generate_test_scenario()

        # 测试场景的有效性
        assert_not_null(scenario.player, "Scenario should have player")
        assert_gt(scenario.enemies.size(), 0, "Scenario should have enemies")

        # 运行场景测试
        test_scenario_logic(scenario)
```

这个测试调试工具指南提供了完整的调试方法论，从基础的问题诊断到高级的性能分析，帮助开发者有效地维护和优化测试质量。