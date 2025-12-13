extends CanvasLayer
class_name UIManager

## UI管理器模板
## 管理游戏中的所有UI界面
##
## ⚠️ 命名规范提醒：
## 如果此脚本附加到场景文件，类名必须与场景文件名保持一致！
## 例如：ui_manager.tscn → class_name UiManager
## 当前模板使用 UIManager 作为示例，实际使用时请修改为与场景文件名一致的类名

# UI层级枚举
enum UILayer {
    BACKGROUND,
    GAME,
    MENU,
    POPUP,
    NOTIFICATION
}

# UI容器字典
var ui_containers: Dictionary = {}
var active_windows: Array[Control] = []

# 信号定义
signal window_opened(window_name: String)
signal window_closed(window_name: String)
signal ui_layer_changed(layer: UILayer)

# ===== 生命周期 =====

func _ready():
    """初始化UI管理器"""
    setup_ui_containers()
    connect_ui_signals()

# ===== UI容器管理 =====

func setup_ui_containers():
    """设置UI容器"""
    # 为每个UI层级创建容器
    for layer in UILayer.values():
        var container = Control.new()
        container.name = "UIContainer_" + UILayer.keys()[layer]
        container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

        # 设置容器的绘制层级
        container.z_index = layer * 10

        add_child(container)
        ui_containers[layer] = container

# ===== 窗口管理 =====

func open_window(window_scene: PackedScene, layer: UILayer = UILayer.MENU) -> Control:
    """打开UI窗口"""
    var window = window_scene.instantiate()
    if not window is Control:
        push_error("Window scene must inherit from Control")
        window.queue_free()
        return null

    # 添加到指定层级的容器
    var container = ui_containers[layer]
    container.add_child(window)

    # 设置窗口属性
    window.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    # 添加到活动窗口列表
    active_windows.append(window)

    # 连接关闭信号
    if window.has_signal("close_requested"):
        window.close_requested.connect(_on_window_close_requested.bind(window))

    # 发出信号
    window_opened.emit(window.name)
    ui_layer_changed.emit(layer)

    return window

func close_window(window: Control):
    """关闭UI窗口"""
    if window and window in active_windows:
        active_windows.erase(window)

        # 发出信号
        window_closed.emit(window.name)

        # 播放关闭动画（如果有）
        if window.has_method("play_close_animation"):
            await window.play_close_animation()

        window.queue_free()

func close_all_windows():
    """关闭所有窗口"""
    var windows_to_close = active_windows.duplicate()
    for window in windows_to_close:
        close_window(window)

# ===== UI层级管理 =====

func set_layer_visibility(layer: UILayer, visible: bool):
    """设置UI层级的可见性"""
    var container = ui_containers[layer]
    if container:
        container.visible = visible

func get_topmost_layer() -> UILayer:
    """获取最顶层的UI层级"""
    var top_layer = UILayer.BACKGROUND
    for layer in UILayer.values():
        var container = ui_containers[layer]
        if container and container.visible and layer > top_layer:
            top_layer = layer
    return top_layer

# ===== UI工具方法 =====

func show_notification(message: String, duration: float = 2.0):
    """显示通知"""
    var notification = preload("res://scenes/ui/notification.tscn").instantiate()
    if notification:
        notification.set_message(message)
        open_window(notification, UILayer.NOTIFICATION)

        # 自动关闭
        await get_tree().create_timer(duration).timeout
        close_window(notification)

func show_confirmation_dialog(title: String, message: String) -> bool:
    """显示确认对话框"""
    var dialog = preload("res://scenes/ui/confirmation_dialog.tscn").instantiate()
    if not dialog:
        return false

    dialog.set_title(title)
    dialog.set_message(message)
    open_window(dialog, UILayer.POPUP)

    # 等待用户选择
    var confirmed = await dialog.confirmed
    close_window(dialog)

    return confirmed

# ===== 虚方法（可重写） =====

func connect_ui_signals():
    """连接UI信号 - 子类可重写"""
    pass

# ===== 信号处理 =====

func _on_window_close_requested(window: Control):
    """处理窗口关闭请求"""
    close_window(window)

# ===== 辅助方法 =====

func find_window_by_name(window_name: String) -> Control:
    """通过名称查找窗口"""
    for window in active_windows:
        if window.name == window_name:
            return window
    return null

func is_window_open(window_name: String) -> bool:
    """检查窗口是否打开"""
    return find_window_by_name(window_name) != null