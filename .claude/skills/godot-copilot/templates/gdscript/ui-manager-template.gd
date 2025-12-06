extends Node
class_name UIManager

# =============================================================================
# UI管理器模板
# 负责管理游戏中的所有UI元素
# 使用说明：
# 1. 将此脚本挂载到场景的UI根节点
# 2. 根据需要添加和修改UI引用
# 3. 实现具体的UI逻辑
# =============================================================================

# UI根节点引用
@onready var ui_root: Control = get_parent() if get_parent() is Control else null

# 主要UI元素引用（需要根据实际场景修改）
@onready var main_menu: Control = $MainMenu
@onready var pause_menu: Control = $PauseMenu
@onready var game_over_menu: Control = $GameOverMenu
@onready var hud: Control = $HUD

# HUD元素
@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var score_label: Label = $HUD/ScoreLabel
@onready var coin_label: Label = $HUD/CoinLabel
@onready var level_label: Label = $HUD/LevelLabel

# 按钮
@onready var start_button: Button = $MainMenu/StartButton
@onready var continue_button: Button = $PauseMenu/ContinueButton
@onready var restart_button: Button = $GameOverMenu/RestartButton
@onready var quit_button: Button = $MainMenu/QuitButton

# 弹窗和对话框
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog
@onready var message_dialog: AcceptDialog = $MessageDialog

# 动画
@onready var menu_transition: AnimationPlayer = $MenuTransition
@onready var ui_animation: AnimationPlayer = $UIAnimation

# UI状态管理
enum UIState {
    MAIN_MENU,
    GAMEPLAY,
    PAUSED,
    GAME_OVER,
    SETTINGS,
    LOADING
}

var current_state: UIState = UIState.MAIN_MENU
var previous_state: UIState = UIState.MAIN_MENU

# 游戏数据引用
var game_data: Dictionary = {}

# 信号定义
signal ui_state_changed(new_state: UIState)
signal menu_closed(menu_name: String)
signal action_confirmed(action: String)
signal action_cancelled(action: String)

# -----------------------------------------------------------------------------
# 生命周期方法
# -----------------------------------------------------------------------------

func _ready():
    """初始化UI管理器"""
    setup_ui()
    connect_signals()
    show_main_menu()

func setup_ui():
    """设置UI初始状态"""
    if not ui_root:
        push_error("UI Manager must be attached to a Control node")
        return

    # 隐藏所有UI面板
    hide_all_menus()

    # 初始化HUD
    if hud:
        hud.visible = false

    # 设置初始状态
    current_state = UIState.MAIN_MENU

func connect_signals():
    """连接所有UI信号"""
    # 主菜单按钮
    if start_button:
        start_button.pressed.connect(_on_start_button_pressed)
    if quit_button:
        quit_button.pressed.connect(_on_quit_button_pressed)

    # 暂停菜单按钮
    if continue_button:
        continue_button.pressed.connect(_on_continue_button_pressed)

    # 游戏结束菜单按钮
    if restart_button:
        restart_button.pressed.connect(_on_restart_button_pressed)

    # 对话框
    if confirm_dialog:
        confirm_dialog.confirmed.connect(_on_dialog_confirmed)
        confirm_dialog.canceled.connect(_on_dialog_cancelled)

# -----------------------------------------------------------------------------
# UI状态管理
# -----------------------------------------------------------------------------

func change_state(new_state: UIState) -> void:
    """改变UI状态"""
    if new_state == current_state:
        return

    previous_state = current_state
    current_state = new_state

    # 清理当前状态的UI
    cleanup_current_state()

    # 设置新状态的UI
    setup_new_state()

    ui_state_changed.emit(new_state)

func cleanup_current_state():
    """清理当前状态的UI元素"""
    match current_state:
        UIState.MAIN_MENU:
            hide_main_menu()
        UIState.PAUSED:
            hide_pause_menu()
        UIState.GAME_OVER:
            hide_game_over_menu()

func setup_new_state():
    """设置新状态的UI元素"""
    match current_state:
        UIState.MAIN_MENU:
            show_main_menu()
        UIState.GAMEPLAY:
            show_gameplay_ui()
        UIState.PAUSED:
            show_pause_menu()
            pause_game()
        UIState.GAME_OVER:
            show_game_over_menu()

# -----------------------------------------------------------------------------
# 主菜单管理
# -----------------------------------------------------------------------------

func show_main_menu():
    """显示主菜单"""
    if main_menu:
        main_menu.visible = true

    if menu_transition:
        menu_transition.play("menu_fade_in")

func hide_main_menu():
    """隐藏主菜单"""
    if main_menu:
        main_menu.visible = false

func _on_start_button_pressed():
    """开始按钮点击事件"""
    change_state(UIState.GAMEPLAY)
    start_game()

func _on_quit_button_pressed():
    """退出按钮点击事件"""
    show_confirm_dialog("确定要退出游戏吗？", "quit")

# -----------------------------------------------------------------------------
# 暂停菜单管理
# -----------------------------------------------------------------------------

func show_pause_menu():
    """显示暂停菜单"""
    if pause_menu:
        pause_menu.visible = true
        pause_menu.grab_focus()

func hide_pause_menu():
    """隐藏暂停菜单"""
    if pause_menu:
        pause_menu.visible = false

func _on_continue_button_pressed():
    """继续游戏按钮点击"""
    change_state(UIState.GAMEPLAY)
    resume_game()

# -----------------------------------------------------------------------------
# 游戏结束菜单管理
# -----------------------------------------------------------------------------

func show_game_over_menu():
    """显示游戏结束菜单"""
    if game_over_menu:
        game_over_menu.visible = true

func hide_game_over_menu():
    """隐藏游戏结束菜单"""
    if game_over_menu:
        game_over_menu.visible = false

func _on_restart_button_pressed():
    """重新开始按钮点击"""
    change_state(UIState.MAIN_MENU)
    restart_game()

# -----------------------------------------------------------------------------
# HUD管理
# -----------------------------------------------------------------------------

func show_gameplay_ui():
    """显示游戏界面UI"""
    if hud:
        hud.visible = true

func hide_hud():
    """隐藏HUD"""
    if hud:
        hud.visible = false

func update_health_bar(current: int, maximum: int) -> void:
    """更新生命值显示"""
    if health_bar:
        health_bar.max_value = maximum
        health_bar.value = current
        # 可以根据生命值改变颜色
        var percentage = float(current) / maximum
        if percentage < 0.3:
            health_bar.modulate = Color.RED
        elif percentage < 0.6:
            health_bar.modulate = Color.YELLOW
        else:
            health_bar.modulate = Color.WHITE

func update_score(new_score: int) -> void:
    """更新分数显示"""
    if score_label:
        score_label.text = "Score: %d" % new_score

func update_coin_count(count: int) -> void:
    """更新金币数量显示"""
    if coin_label:
        coin_label.text = "Coins: %d" % count

func update_level(level: int) -> void:
    """更新关卡显示"""
    if level_label:
        level_label.text = "Level: %d" % level

# -----------------------------------------------------------------------------
# 对话框管理
# -----------------------------------------------------------------------------

func show_message_dialog(message: String, title: String = "提示") -> void:
    """显示消息对话框"""
    if message_dialog:
        message_dialog.dialog_text = message
        message_dialog.title = title
        message_dialog.popup_centered()

func show_confirm_dialog(message: String, action: String = "confirm") -> void:
    """显示确认对话框"""
    if confirm_dialog:
        confirm_dialog.dialog_text = message
        confirm_dialog.set_meta("action", action)
        confirm_dialog.popup_centered()

func _on_dialog_confirmed():
    """对话框确认"""
    var action = confirm_dialog.get_meta("action", "")
    action_confirmed.emit(action)
    handle_dialog_action(action, true)

func _on_dialog_cancelled():
    """对话框取消"""
    var action = confirm_dialog.get_meta("action", "")
    action_cancelled.emit(action)
    handle_dialog_action(action, false)

func handle_dialog_action(action: String, confirmed: bool):
    """处理对话框动作"""
    match action:
        "quit":
            if confirmed:
                quit_game()
        "restart":
            if confirmed:
                restart_game()

# -----------------------------------------------------------------------------
# 游戏控制接口
# -----------------------------------------------------------------------------

func start_game():
    """开始游戏"""
    # 发送给游戏管理器开始新游戏
    get_tree().call_group("Game", "start_new_game")

func pause_game():
    """暂停游戏"""
    get_tree().paused = true

func resume_game():
    """恢复游戏"""
    get_tree().paused = false

func restart_game():
    """重新开始游戏"""
    get_tree().reload_current_scene()

func quit_game():
    """退出游戏"""
    get_tree().quit()

# -----------------------------------------------------------------------------
# 输入处理
# -----------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
    """处理未处理的输入"""
    if event.is_action_pressed("ui_cancel"):  # ESC键
        handle_escape_key()

func handle_escape_key():
    """处理ESC键"""
    match current_state:
        UIState.GAMEPLAY:
            change_state(UIState.PAUSED)
        UIState.PAUSED:
            change_state(UIState.GAMEPLAY)
        UIState.SETTINGS:
            change_state(UIState.MAIN_MENU)

# -----------------------------------------------------------------------------
# 动画效果
# -----------------------------------------------------------------------------

func play_ui_animation(animation_name: String):
    """播放UI动画"""
    if ui_animation and ui_animation.has_animation(animation_name):
        ui_animation.play(animation_name)

func fade_in_ui(duration: float = 0.5):
    """淡入UI"""
    if ui_root:
        var tween = create_tween()
        ui_root.modulate = Color.TRANSPARENT
        tween.tween_property(ui_root, "modulate", Color.WHITE, duration)

func fade_out_ui(duration: float = 0.5):
    """淡出UI"""
    if ui_root:
        var tween = create_tween()
        tween.tween_property(ui_root, "modulate", Color.TRANSPARENT, duration)

# -----------------------------------------------------------------------------
# 通用UI功能
# -----------------------------------------------------------------------------

func hide_all_menus():
    """隐藏所有菜单面板"""
    if main_menu:
        main_menu.visible = false
    if pause_menu:
        pause_menu.visible = false
    if game_over_menu:
        game_over_menu.visible = false

func show_loading_screen():
    """显示加载界面"""
    # 实现加载界面显示逻辑
    pass

func hide_loading_screen():
    """隐藏加载界面"""
    # 实现加载界面隐藏逻辑
    pass

# -----------------------------------------------------------------------------
# 辅助方法
# -----------------------------------------------------------------------------

func set_button_focus(button: Button):
    """设置按钮焦点"""
    if button:
        button.grab_focus()

func get_current_state() -> UIState:
    """获取当前UI状态"""
    return current_state

func is_in_game() -> bool:
    """是否在游戏中"""
    return current_state == UIState.GAMEPLAY

func is_paused() -> bool:
    """是否暂停"""
    return current_state == UIState.PAUSED or get_tree().paused

# -----------------------------------------------------------------------------
# 工具方法
# -----------------------------------------------------------------------------

func format_time(seconds: int) -> String:
    """格式化时间显示"""
    var minutes = seconds / 60
    var secs = seconds % 60
    return "%02d:%02d" % [minutes, secs]

func format_number(number: int) -> String:
    """格式化数字（添加千位分隔符）"""
    return str(number).insert_commas()

# -----------------------------------------------------------------------------
# 扩展接口（根据需要实现）
# -----------------------------------------------------------------------------

func show_settings_menu():
    """显示设置菜单"""
    # 实现设置菜单逻辑
    pass

func save_settings():
    """保存设置"""
    # 实现设置保存逻辑
    pass

func load_settings():
    """加载设置"""
    # 实现设置加载逻辑
    pass

# =============================================================================
# 使用示例
# =============================================================================

# 在游戏中使用：
# 1. 将UIManager脚本挂载到场景的UI节点
# 2. 在场景中添加相应的UI子节点
# 3. 调用UI方法更新显示

# 更新生命值：
# ui_manager.update_health_bar(player.health, player.max_health)

# 显示游戏结束：
# ui_manager.change_state(UIManager.UIState.GAME_OVER)

# 监听UI事件：
# ui_manager.action_confirmed.connect(_on_ui_action_confirmed)

# =============================================================================
# 扩展建议
# =============================================================================

# 1. 添加更多UI元素（背包、技能栏、任务列表等）
# 2. 实现UI数据绑定
# 3. 添加UI主题系统
# 4. 实现UI动画队列
# 5. 添加本地化支持
# 6. 实现UI预设系统