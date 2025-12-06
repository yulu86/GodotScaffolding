extends "res://addons/gut/test.gd"
class_name IntegrationTestTemplate

# =============================================================================
# 集成测试模板
# 用于测试多个组件或系统的交互
# =============================================================================

# 测试场景根节点
var test_scene_root: Node

# 被测试的场景
var test_scene: PackedScene

# 场景中的关键节点引用
var scene_nodes: Dictionary = {}

# 测试配置
var test_config: Dictionary = {
    "auto_cleanup": true,
    "wait_time": 0.1,
    "timeout": 5.0
}

# -----------------------------------------------------------------------------
# 测试生命周期
# -----------------------------------------------------------------------------

func before_each():
    """每个测试前设置测试环境"""
    setup_test_scene()

func after_each():
    """每个测试后清理测试环境"""
    if test_config.auto_cleanup:
        cleanup_test_scene()

func before_all():
    """所有测试前运行一次"""
    print("开始集成测试")
    # 加载必要的资源
    load_test_resources()

func after_all():
    """所有测试后运行一次"""
    print("集成测试完成")
    cleanup_all_resources()

# -----------------------------------------------------------------------------
# 场景设置和清理
# -----------------------------------------------------------------------------

func setup_test_scene():
    """设置测试场景"""
    # 创建场景根节点
    test_scene_root = Node.new()
    test_scene_root.name = "IntegrationTestScene"
    add_child(test_scene_root)

    # 设置物理过程
    test_scene_root.set_process(true)
    test_scene_root.set_physics_process(true)

func cleanup_test_scene():
    """清理测试场景"""
    if test_scene_root and is_instance_valid(test_scene_root):
        test_scene_root.queue_free()
        await get_tree().process_frame
    test_scene_root = null
    scene_nodes.clear()

func load_test_resources():
    """加载测试所需的资源"""
    # 示例：加载场景
    # test_scene = preload("res://scenes/test/TestScene.tscn")
    pass

func cleanup_all_resources():
    """清理所有资源"""
    # 释放预加载的场景
    test_scene = null

# -----------------------------------------------------------------------------
# 场景实例化和管理
# -----------------------------------------------------------------------------

func instantiate_scene(scene_path: String) -> Node:
    """实例化场景"""
    var scene_resource = load(scene_path)
    if not scene_resource:
        push_error("无法加载场景: %s" % scene_path)
        return null

    var instance = scene_resource.instantiate()
    if not instance:
        push_error("无法实例化场景: %s" % scene_path)
        return null

    test_scene_root.add_child(instance)
    return instance

func find_node_by_name(node_name: String) -> Node:
    """在场景中查找节点"""
    if not test_scene_root:
        return null
    return test_scene_root.find_child(node_name, true, true)

func store_node_reference(name: String, node: Node):
    """存储节点引用"""
    scene_nodes[name] = node

func get_stored_node(name: String) -> Node:
    """获取存储的节点引用"""
    return scene_nodes.get(name)

# -----------------------------------------------------------------------------
# 常用测试模式
# -----------------------------------------------------------------------------

# 示例：场景加载测试
func test_scene_loading():
    """测试场景是否正确加载"""
    # arrange
    var scene_path = "res://scenes/player/Player.tscn"

    # act
    var player = instantiate_scene(scene_path)

    # assert
    assert_not_null(player, "玩家场景应该成功加载")
    assert_true(test_scene_root.has_child(player), "玩家应该在场景中")

    # cleanup
    if player:
        player.queue_free()

# 示例：节点连接测试
func test_node_connections():
    """测试节点之间的连接"""
    # arrange
    setup_player_scene()

    # act & assert
    var player = scene_nodes.get("player")
    var ui = scene_nodes.get("ui")

    assert_not_null(player, "玩家节点应该存在")
    assert_not_null(ui, "UI节点应该存在")

    # 测试信号连接
    # assert_signal_connected(player, "health_changed", ui, "_on_player_health_changed")

# 示例：输入处理测试
func test_input_handling():
    """测试输入处理"""
    # arrange
    var player = instantiate_scene("res://scenes/player/Player.tscn")
    await get_tree().process_frame  # 等待节点准备

    # act
    Input.action_press("ui_right")
    await get_tree().physics_frame  # 等待物理帧

    # assert
    assert_gt(player.velocity.x, 0, "玩家应该向右移动")

    # cleanup
    Input.action_release("ui_right")

# 示例：物理交互测试
func test_physics_interaction():
    """测试物理交互"""
    # arrange
    setup_physics_scene()
    var player = scene_nodes.get("player")
    var ground = scene_nodes.get("ground")

    # act
    player.global_position = Vector2(0, -100)
    await get_tree().physics_frame

    # assert
    assert_true(player.is_on_floor(), "玩家应该在地面")

# 示例：动画系统集成测试
func test_animation_integration():
    """测试动画系统集成"""
    # arrange
    var player = instantiate_scene("res://scenes/player/Player.tscn")
    await get_tree().process_frame

    # act
    player.move_and_slide()
    await get_tree().create_timer(0.5).timeout

    # assert
    var anim_player = player.get_node("AnimationPlayer")
    if anim_player:
        assert_ne(anim_player.current_animation, "", "应该播放动画")

# 示例：UI交互测试
func test_ui_interaction():
    """测试UI交互"""
    # arrange
    setup_ui_scene()
    var button = scene_nodes.get("start_button")
    var menu = scene_nodes.get("main_menu")

    # act
    button.emit_signal("pressed")
    await get_tree().process_frame

    # assert
    # assert_false(menu.visible, "菜单应该隐藏")

# 示例：场景切换测试
func test_scene_transition():
    """测试场景切换"""
    # arrange
    var scene_manager = find_node_by_name("SceneManager")

    # act
    # scene_manager.change_scene("res://scenes/game/Game.tscn")
    await wait_for_signal(scene_tree, "tree_changed", 1.0)

    # assert
    # assert_eq(scene_tree.current_scene.scene_file_path,
    #     "res://scenes/game/Game.tscn",
    #     "应该切换到游戏场景")

# -----------------------------------------------------------------------------
# 辅助测试方法
# -----------------------------------------------------------------------------

func setup_player_scene():
    """设置玩家测试场景"""
    var player = instantiate_scene("res://scenes/player/Player.tscn")
    store_node_reference("player", player)

    # 添加地面
    var ground = StaticBody2D.new()
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(1000, 20)
    collision.shape = shape
    ground.add_child(collision)
    ground.position = Vector2(0, 100)
    test_scene_root.add_child(ground)
    store_node_reference("ground", ground)

func setup_physics_scene():
    """设置物理测试场景"""
    setup_player_scene()

func setup_ui_scene():
    """设置UI测试场景"""
    # 创建UI容器
    var ui = Control.new()
    ui.name = "TestUI"
    ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    test_scene_root.add_child(ui)
    store_node_reference("ui", ui)

    # 创建测试按钮
    var button = Button.new()
    button.text = "Start"
    button.name = "StartButton"
    ui.add_child(button)
    store_node_reference("start_button", button)

func wait_for_time(seconds: float):
    """等待指定时间"""
    await get_tree().create_timer(seconds).timeout

func wait_for_signal(emitter: Object, signal_name: String, timeout_sec: float = 1.0):
    """等待信号，带超时"""
    var timeout = get_tree().create_timer(timeout_sec)
    await Promise.any([
        emitter.signal_emitted.connect(
            func(sig_name, args):
                if sig_name == signal_name:
                    timeout.queue_free()
        ),
        timeout.timeout
    ])

func simulate_click(node: Control):
    """模拟鼠标点击"""
    var event = InputEventMouseButton.new()
    event.pressed = true
    event.button_index = MOUSE_BUTTON_LEFT
    node._gui_input(event)

    event.pressed = false
    node._gui_input(event)

func simulate_key(key: Key, pressed: bool = true):
    """模拟按键"""
    var event = InputEventKey.new()
    event.keycode = key
    event.pressed = pressed
    Input.parse_input_event(event)

# -----------------------------------------------------------------------------
# 性能测试
# -----------------------------------------------------------------------------

func test_scene_performance():
    """测试场景性能"""
    # arrange
    var scene_path = "res://scenes/complex/ComplexScene.tscn"
    var iterations = 10

    var start_time = Time.get_ticks_msec()

    # act
    for i in range(iterations):
        var instance = instantiate_scene(scene_path)
        await get_tree().process_frame
        instance.queue_free()
        await get_tree().process_frame

    # assert
    var total_time = Time.get_ticks_msec() - start_time
    var avg_time = float(total_time) / iterations

    assert_lt(avg_time, 100.0,
        "平均场景加载时间 %.2f ms 应该小于 100 ms" % avg_time)

# -----------------------------------------------------------------------------
# 内存测试
# -----------------------------------------------------------------------------

func test_memory_usage():
    """测试内存使用情况"""
    # arrange
    var initial_memory = OS.get_static_memory_usage_by_type()[1]

    # act - 创建和销毁多个实例
    for i in range(100):
        var instance = instantiate_scene("res://scenes/effects/Effect.tscn")
        await get_tree().process_frame
        instance.queue_free()
        await get_tree().process_frame

    # 强制垃圾回收
    await get_tree().process_frame

    # assert
    var final_memory = OS.get_static_memory_usage_by_type()[1]
    var memory_increase = final_memory - initial_memory

    # 允许少量内存增长
    assert_lt(memory_increase, 1024 * 1024,  # 1MB
        "内存增长 %d bytes 应该小于 1 MB" % memory_increase)

# -----------------------------------------------------------------------------
# 网络集成测试（如果适用）
# -----------------------------------------------------------------------------

func test_network_synchronization():
    """测试网络同步"""
    pending("需要实现网络同步测试")

# -----------------------------------------------------------------------------
# 保存/加载系统测试
# -----------------------------------------------------------------------------

func test_save_load_system():
    """测试保存/加载系统"""
    # arrange
    setup_player_scene()
    var player = scene_nodes.get("player")
    player.position = Vector2(100, 200)
    player.current_health = 2

    # act - 保存
    # var save_data = SaveManager.save_game()
    # 重新加载
    # SaveManager.load_game(save_data)

    # assert
    # assert_eq(player.position, Vector2(100, 200), "位置应该保存")
    # assert_eq(player.current_health, 2, "健康值应该保存")

# -----------------------------------------------------------------------------
# 调试辅助方法
# -----------------------------------------------------------------------------

func print_scene_tree(node: Node = null, indent: int = 0):
    """打印场景树结构（调试用）"""
    if not node:
        node = test_scene_root

    var prefix = "  ".repeat(indent)
    print("%s%s" % [prefix, node.name])
    print("%s  Type: %s" % [prefix, node.get_script()])

    for child in node.get_children():
        print_scene_tree(child, indent + 1)

func capture_screenshot():
    """截取测试场景截图（调试用）"""
    var image = get_viewport().get_texture().get_image()
    image.save_png("res://debug_screenshot.png")

# =============================================================================
# 集成测试最佳实践
# =============================================================================

# 1. 测试范围：
#    - 测试组件间的交互
#    - 测试完整的功能流程
#    - 测试场景加载和切换

# 2. 性能考虑：
#    - 避免在集成测试中使用大量资源
#    - 使用轻量级测试场景
#    - 及时清理资源

# 3. 异步处理：
#    - 使用 await 等待异步操作
#    - 设置合理的超时时间
#    - 处理异步操作失败的情况

# 4. 测试隔离：
#    - 每个测试使用独立的场景
#    - 清理所有创建的节点
#    - 避免测试间的状态污染

# 5. 调试支持：
#    - 提供详细的错误信息
#    - 使用断点和打印语句
#    - 保存测试失败的场景状态