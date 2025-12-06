extends "res://addons/gut/test.gd"
class_name UnitTestTemplate

# =============================================================================
# 单元测试模板
# 使用说明：
# 1. 复制此文件到 test/unit/[模块]/test_[类名].gd
# 2. 修改类名为有意义的名称
# 3. 实现具体的测试用例
# =============================================================================

# 测试目标类（需要修改）
var target_class_name = "YourClass"
var test_instance

# 测试数据
var test_data: Dictionary = {}

# -----------------------------------------------------------------------------
# 测试生命周期方法
# -----------------------------------------------------------------------------

func before_each():
    """每个测试前运行，设置测试环境"""
    # 创建测试实例
    # test_instance = target_class_name.new()
    # add_child_autofree(test_instance)  # 自动清理
    pass

func after_each():
    """每个测试后运行，清理测试环境"""
    # 清理操作
    pass

func before_all():
    """所有测试开始前运行一次"""
    print("开始测试 %s" % target_class_name)

func after_all():
    """所有测试结束后运行一次"""
    print("%s 测试完成" % target_class_name)

# -----------------------------------------------------------------------------
# 基础测试模板（复制并修改）
# -----------------------------------------------------------------------------

# 示例：初始化测试
func test_initialization():
    """测试对象初始化是否正确"""
    # arrange - 准备测试数据
    var expected_value = 42

    # act - 执行被测试的方法
    # test_instance = target_class_name.new(expected_value)

    # assert - 验证结果
    # assert_eq(test_instance.value, expected_value,
    #     "初始化后属性值应该正确")
    pending("需要实现初始化测试")

# 示例：方法调用测试
func test_method_call():
    """测试方法调用是否产生预期结果"""
    # arrange
    var input_data = "test input"
    var expected_output = "expected output"

    # act
    # var result = test_instance.some_method(input_data)

    # assert
    # assert_eq(result, expected_output,
    #     "方法应该返回预期结果")
    pending("需要实现方法调用测试")

# 示例：状态变化测试
func test_state_change():
    """测试对象状态是否正确改变"""
    # arrange
    # var initial_state = test_instance.get_state()

    # act
    # test_instance.change_state()

    # assert
    # assert_ne(test_instance.get_state(), initial_state,
    #     "状态应该发生变化")
    pending("需要实现状态变化测试")

# 示例：错误处理测试
func test_error_handling():
    """测试错误输入的处理"""
    # arrange
    var invalid_input = null

    # act & assert
    # assert_raises(func(): test_instance.process(invalid_input),
    #     "应该对无效输入抛出错误")
    pending("需要实现错误处理测试")

# 示例：边界条件测试
func test_boundary_conditions():
    """测试边界条件"""
    # 测试最小值
    # test_instance.set_value(0)
    # assert_eq(test_instance.get_value(), 0, "应该处理最小值")

    # 测试最大值
    # test_instance.set_value(MAX_VALUE)
    # assert_eq(test_instance.get_value(), MAX_VALUE, "应该处理最大值")

    pending("需要实现边界条件测试")

# 示例：信号测试
func test_signal_emission():
    """测试信号是否正确发出"""
    # arrange
    var signal_received = false
    # test_instance.some_signal.connect(func(): signal_received = true)

    # act
    # test_instance.trigger_signal()

    # assert
    # await get_tree().process_frame
    # assert_true(signal_received, "应该发出信号")
    pending("需要实现信号测试")

# -----------------------------------------------------------------------------
# 常用测试辅助方法
# -----------------------------------------------------------------------------

func create_test_instance(params = {}):
    """创建测试实例的辅助方法"""
    # return target_class_name.new()
    pass

func assert_time_elapsed(action: Callable, max_ms: int):
    """断言操作时间不超过指定毫秒"""
    var start_time = Time.get_ticks_msec()
    action.call()
    var elapsed = Time.get_ticks_msec() - start_time
    assert_lt(elapsed, max_ms, "操作应该在 %d ms 内完成" % max_ms)

func assert_no_warnings(action: Callable):
    """断言操作不产生警告"""
    var initial_warnings = gut.get_logger().get_warnings().size()
    action.call()
    var final_warnings = gut.get_logger().get_warnings().size()
    assert_eq(final_warnings, initial_warnings, "不应该产生警告")

func assert_no_errors(action: Callable):
    """断言操作不产生错误"""
    var initial_errors = gut.get_logger().get_errors().size()
    action.call()
    var final_errors = gut.get_logger().get_errors().size()
    assert_eq(final_errors, initial_errors, "不应该产生错误")

# -----------------------------------------------------------------------------
# 参数化测试示例
# -----------------------------------------------------------------------------

func test_parameterized_example():
    """参数化测试示例"""
    var test_cases = [
        {"input": 1, "expected": 2, "name": "基本测试"},
        {"input": 0, "expected": 1, "name": "边界测试"},
        {"input": -1, "expected": 0, "name": "负值测试"}
    ]

    for case in test_cases:
        print("运行测试用例: %s" % case.name)
        # var result = test_instance.process(case.input)
        # assert_eq(result, case.expected,
        #     "[%s] 输入 %d 应该得到 %d" % [case.name, case.input, case.expected])

    pending("需要实现参数化测试")

# -----------------------------------------------------------------------------
# 性能测试示例
# -----------------------------------------------------------------------------

func test_performance_example():
    """性能测试示例"""
    var iterations = 1000
    var max_time_ms = 100

    var start_time = Time.get_ticks_msec()

    # 执行被测试的操作
    for i in range(iterations):
        # test_instance.expensive_operation()
        pass

    var elapsed_time = Time.get_ticks_msec() - start_time

    # 断言平均每次操作时间
    var avg_time = float(elapsed_time) / iterations
    assert_lt(avg_time, max_time_ms,
        "平均操作时间 %.2f ms 应该小于 %d ms" % [avg_time, max_time_ms])

# -----------------------------------------------------------------------------
# 异步测试示例
# -----------------------------------------------------------------------------

func test_async_example():
    """异步测试示例"""
    # arrange
    var async_operation = func():
        # await get_tree().create_timer(0.1).timeout
        pass

    # act
    # await async_operation()

    # assert
    # assert_true(test_instance.operation_completed)
    pending("需要实现异步测试")

# -----------------------------------------------------------------------------
# 模拟和存根示例
# -----------------------------------------------------------------------------

func test_with_mock_example():
    """使用模拟对象的测试示例"""
    # 创建模拟对象
    # var mock_dependency = double(DependencyClass).new()
    # mock_dependency.mock_method = "mocked_value"

    # 注入模拟对象
    # test_instance.dependency = mock_dependency

    # 测试行为
    # test_instance.use_dependency()

    # 验证交互
    # assert_called(mock_dependency, "mock_method")
    pending("需要实现模拟测试")

# =============================================================================
# 测试开发指南
# =============================================================================

# 1. 测试命名规范：
#    - 测试方法以 "test_" 开头
#    - 使用描述性名称：test_player_should_jump_when_on_ground
#    - 避免缩写：test_init 而不是 test_in

# 2. 测试结构（AAA模式）：
#    - Arrange：准备测试数据和条件
#    - Act：执行被测试的操作
#    - Assert：验证结果

# 3. 断言选择：
#    - 使用最具体的断言
#    - 提供有意义的错误消息
#    - 一个测试一个主要断言

# 4. 测试独立性：
#    - 测试之间不应有依赖
#    - 使用 before_each 清理状态
#    - 避免使用全局变量

# 5. 性能考虑：
#    - 保持测试快速运行
#    - 复杂操作放在集成测试中
#    - 使用轻量级测试数据

# 6. 覆盖率：
#    - 测试正常路径
#    - 测试错误条件
#    - 测试边界情况