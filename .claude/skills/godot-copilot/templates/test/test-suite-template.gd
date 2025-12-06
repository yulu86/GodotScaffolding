extends "res://addons/gut/test.gd"
class_name TestSuiteTemplate

# =============================================================================
# 测试套件模板
# 用于组织和运行项目的所有测试
# =============================================================================

# 测试目录配置
var test_directories: Array[String] = [
    "res://test/unit/",
    "res://test/integration/"
]

# 测试脚本配置
var test_scripts: Array[String] = []

# 排除的测试文件（模式匹配）
var exclude_patterns: Array[String] = [
    "*_template.gd",
    "*_example.gd"
]

# 测试配置
var test_config: Dictionary = {
    "include_subdirs": true,
    "should_exit": true,
    "log_level": 3,  # LOG_LEVEL_ALL
    "ignore_pause": true,
    "double_strategy": "INCLUDE_NATIVE",
    "yield_between_tests": true
}

# -----------------------------------------------------------------------------
# 测试套件初始化
# -----------------------------------------------------------------------------

func _init():
    """初始化测试套件"""
    name = "ProjectTestSuite"
    configure_test_settings()

func configure_test_settings():
    """配置测试设置"""
    # 设置测试目录
    for dir in test_directories:
        gut.add_directory(dir)

    # 设置测试脚本
    for script in test_scripts:
        gut.add_script(script)

    # 应用配置
    for key in test_config:
        gut.set(key, test_config[key])

# -----------------------------------------------------------------------------
# 测试运行控制
# -----------------------------------------------------------------------------

func run_all_tests():
    """运行所有测试"""
    print("=" * 50)
    print("开始运行项目测试套件")
    print("=" * 50)

    # 运行测试
    gut.test()

    # 等待测试完成
    await gut.test_script_finished

    print_test_summary()

func run_unit_tests_only():
    """只运行单元测试"""
    clear_tests()
    gut.add_directory("res://test/unit/")
    gut.test()

func run_integration_tests_only():
    """只运行集成测试"""
    clear_tests()
    gut.add_directory("res://test/integration/")
    gut.test()

func run_specific_test(test_path: String):
    """运行特定测试"""
    clear_tests()
    gut.add_script(test_path)
    gut.test()

func clear_tests():
    """清除所有已添加的测试"""
    gut.clear()

# -----------------------------------------------------------------------------
# 测试结果处理
# -----------------------------------------------------------------------------

func print_test_summary():
    """打印测试总结"""
    var summary = gut.get_summary()

    print("\n" + "=" * 50)
    print("测试总结")
    print("=" * 50)

    print("总测试数: %d" % summary.tests)
    print("通过: %d" % summary.passing)
    print("失败: %d" % summary.failing)
    print("pending: %d" % summary.pending)

    var success_rate = 0.0
    if summary.tests > 0:
        success_rate = float(summary.passing) / summary.tests * 100

    print("成功率: %.1f%%" % success_rate)

    if summary.failing > 0:
        print("\n失败的测试:")
        for test in gut.get_failures():
            print("  - %s: %s" % [test.name, test.get_fail_text()])

    print("\n" + "=" * 50)

# -----------------------------------------------------------------------------
# 测试报告生成
# -----------------------------------------------------------------------------

func generate_xml_report() -> String:
    """生成XML格式的测试报告（用于CI/CD）"""
    var xml = '<?xml version="1.0" encoding="UTF-8"?>\n'
    xml += '<testsuite name="%s" tests="%d" failures="%d" time="%f">\n' % [
        name,
        gut.get_summary().tests,
        gut.get_summary().failing,
        gut.get_elapsed_time()
    ]

    # 添加测试用例
    for test in gut.get_test_collector().tests:
        xml += '  <testcase classname="%s" name="%s" time="%f"' % [
            test.inner_class.get_script().get_global_name(),
            test.name,
            test.time_to_run
        ]

        if test.fail_text != "":
            xml += '>\n    <failure message="%s"/>\n  </testcase>\n' % test.fail_text
        else:
            xml += '/>\n'

    xml += '</testsuite>'

    # 保存到文件
    var file = FileAccess.open("res://test_report.xml", FileAccess.WRITE)
    if file:
        file.store_string(xml)
        file.close()

    return xml

func generate_json_report() -> String:
    """生成JSON格式的测试报告"""
    var report = {
        "suite": name,
        "summary": {
            "total": gut.get_summary().tests,
            "passed": gut.get_summary().passing,
            "failed": gut.get_summary().failing,
            "pending": gut.get_summary().pending,
            "time": gut.get_elapsed_time()
        },
        "tests": []
    }

    # 添加测试详情
    for test in gut.get_test_collector().tests:
        report.tests.append({
            "name": test.name,
            "class": test.inner_class.get_script().get_global_name(),
            "status": "passed" if test.passed else "failed",
            "time": test.time_to_run,
            "message": test.fail_text if test.fail_text else ""
        })

    var json = JSON.new()
    var json_string = json.stringify(report, "\t")

    # 保存到文件
    var file = FileAccess.open("res://test_report.json", FileAccess.WRITE)
    if file:
        file.store_string(json_string)
        file.close()

    return json_string

# -----------------------------------------------------------------------------
# 测试覆盖率分析
# -----------------------------------------------------------------------------

func analyze_test_coverage():
    """分析测试覆盖率（需要额外工具）"""
    print("\n分析测试覆盖率...")

    # 这里可以集成覆盖率工具
    # 例如：使用 Python 的 coverage.py 或其他工具

    var coverage_data = {
        "scripts_analyzed": 0,
        "lines_covered": 0,
        "total_lines": 0,
        "coverage_percentage": 0.0
    }

    # 模拟覆盖率分析
    print("覆盖率分析完成:")
    print("  脚本数: %d" % coverage_data.scripts_analyzed)
    print("  覆盖率: %.1f%%" % coverage_data.coverage_percentage)

    return coverage_data

# -----------------------------------------------------------------------------
# 自定义测试运行器
# -----------------------------------------------------------------------------

func create_test_runner_scene() -> PackedScene:
    """创建测试运行器场景（可在编辑器中使用）"""
    var scene = PackedScene.new()

    # 创建根节点
    var root = Node.new()
    root.name = "TestRunner"
    root.set_script(load("res://test/TestRunner.gd"))

    scene.pack(root)
    return scene

# -----------------------------------------------------------------------------
# 性能基准测试
# -----------------------------------------------------------------------------

func run_performance_benchmarks():
    """运行性能基准测试"""
    print("\n运行性能基准测试...")

    var benchmarks = [
        {"name": "场景加载", "test": benchmark_scene_loading},
        {"name": "对象创建", "test": benchmark_object_creation},
        {"name": "物理计算", "test": benchmark_physics_calculation}
    ]

    for benchmark in benchmarks:
        print("\n基准测试: %s" % benchmark.name)
        var result = benchmark.test.call()
        print("  结果: %s" % result)

func benchmark_scene_loading() -> String:
    """场景加载基准测试"""
    var iterations = 100
    var scene_path = "res://scenes/player/Player.tscn"

    var start_time = Time.get_ticks_msec()

    for i in range(iterations):
        var scene = load(scene_path)
        var instance = scene.instantiate()
        instance.queue_free()

    var elapsed = Time.get_ticks_msec() - start_time
    var avg = float(elapsed) / iterations

    return "平均 %.2f ms/次 (%d 次)" % [avg, iterations]

func benchmark_object_creation() -> String:
    """对象创建基准测试"""
    var iterations = 10000

    var start_time = Time.get_ticks_msec()

    for i in range(iterations):
        var obj = Node.new()
        obj.queue_free()

    var elapsed = Time.get_ticks_msec() - start_time
    var avg = float(elapsed) / iterations * 1000  # 转换为微秒

    return "平均 %.2f μs/次 (%d 次)" % [avg, iterations]

func benchmark_physics_calculation() -> String:
    """物理计算基准测试"""
    var iterations = 1000
    var start_time = Time.get_ticks_msec()

    for i in range(iterations):
        # 模拟物理计算
        var pos = Vector2(i, i * 2)
        var vel = Vector2(i * 0.5, i * 0.3)
        pos += vel * 0.016

    var elapsed = Time.get_ticks_msec() - start_time
    var avg = float(elapsed) / iterations * 1000

    return "平均 %.2f μs/次 (%d 次)" % [avg, iterations]

# -----------------------------------------------------------------------------
# CI/CD 集成
# -----------------------------------------------------------------------------

func export_test_results_for_ci():
    """导出CI/CD需要的测试结果"""
    # 生成 JUnit XML 报告
    generate_xml_report()

    # 生成 JSON 报告
    generate_json_report()

    # 创建退出码
    var exit_code = 0 if gut.get_summary().failing == 0 else 1

    # 写入退出码文件
    var file = FileAccess.open("res://test_exit_code.txt", FileAccess.WRITE)
    if file:
        file.store_string(str(exit_code))
        file.close()

    return exit_code

# -----------------------------------------------------------------------------
# 热重载测试
# -----------------------------------------------------------------------------

func setup_hot_reload():
    """设置热重载测试支持"""
    # 监听文件变化
    get_tree().files_dropped.connect(_on_files_changed)

func _on_files_changed(files: PackedStringArray):
    """文件变化时的处理"""
    for file in files:
        if file.ends_with(".gd") and file.begins_with("res://test/"):
            print("检测到测试文件变化: %s" % file)
            # 重新运行相关测试
            # run_specific_test(file)

# -----------------------------------------------------------------------------
# 使用示例
# -----------------------------------------------------------------------------

# 运行所有测试
# var suite = TestSuiteTemplate.new()
# await suite.run_all_tests()

# 只运行单元测试
# await suite.run_unit_tests_only()

# 运行性能测试
# suite.run_performance_benchmarks()

# 生成测试报告
# suite.generate_xml_report()
# suite.generate_json_report()

# =============================================================================
# 测试套件最佳实践
# =============================================================================

# 1. 组织结构：
#    - 按模块组织测试
#    - 使用清晰的命名约定
#    - 定期清理过时的测试

# 2. 运行策略：
#    - 本地开发：运行快速测试
#    - CI/CD：运行完整测试套件
#    - 发布前：运行性能基准测试

# 3. 报告和监控：
#    - 生成详细的测试报告
#    - 监控测试覆盖率
#    - 跟踪性能指标

# 4. 维护：
#    - 定期更新测试套件
#    - 优化慢速测试
#    - 保持测试独立性