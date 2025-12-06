extends Node
class_name GameStateManager

# =============================================================================
# 游戏状态管理器模板
# 负责管理游戏的全局状态、数据和持久化
# 使用说明：
# 1. 将此脚本作为自动加载（AutoLoad）
# 2. 在项目设置中设置为GameStateManager
# 3. 根据需要修改数据结构和方法
# =============================================================================

# 游戏状态枚举
enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER,
    VICTORY,
    LOADING,
    CUTSCENE
}

# 当前游戏状态
var current_state: GameState = GameState.MENU

# 玩家数据
var player_data: Dictionary = {
    "current_health": 100,
    "max_health": 100,
    "position": Vector2.ZERO,
    "rotation": 0.0,
    "inventory": [],
    "equipment": {},
    "abilities": [],
    "stats": {
        "level": 1,
        "experience": 0,
        "next_level_exp": 100,
        "skill_points": 0
    }
}

# 关卡数据
var level_data: Dictionary = {
    "current_level": 1,
    "unlocked_levels": [1],
    "level_scores": {},
    "level_times": {},
    "collectibles": {},
    "total_collectibles": {}
}

# 游戏设置
var settings: Dictionary = {
    "audio": {
        "master_volume": 1.0,
        "music_volume": 0.8,
        "sfx_volume": 0.9,
        "mute_audio": false
    },
    "graphics": {
        "fullscreen": false,
        "vsync": true,
        "resolution": Vector2i(1920, 1080),
        "window_mode": 0  # WINDOW_MODE_WINDOWED
    },
    "gameplay": {
        "mouse_sensitivity": 1.0,
        "controller_sensitivity": 1.0,
        "invert_y": false,
        "auto_save": true,
        "save_interval": 300.0  # 秒
    }
}

# 临时游戏数据（每次新游戏重置）
var temporary_data: Dictionary = {
    "score": 0,
    "coins": 0,
    "enemies_killed": 0,
    "time_played": 0.0,
    "deaths": 0,
    "current_checkpoint": null,
    "visited_areas": []
}

# 信号定义
signal state_changed(new_state: GameState, old_state: GameState)
signal player_health_changed(current: int, max: int)
signal player_died()
signal level_completed(level: int, score: int)
signal coin_collected(amount: int)
signal experience_gained(amount: int)
signal level_up(new_level: int)
signal checkpoint_reached(checkpoint_id: String)
signal settings_changed(category: String, key: String, value: Variant)
signal game_saved()
signal game_loaded()
signal game_reset()

# 内部变量
var save_file_path: String = "user://save_game.json"
var settings_file_path: String = "user://settings.json"
var auto_save_timer: Timer

# -----------------------------------------------------------------------------
# 生命周期方法
# -----------------------------------------------------------------------------

func _ready():
    """初始化游戏状态管理器"""
    initialize()

    # 设置自动保存
    setup_auto_save()

func initialize():
    """初始化游戏状态"""
    load_settings()
    reset_temporary_data()
    current_state = GameState.MENU

func setup_auto_save():
    """设置自动保存"""
    auto_save_timer = Timer.new()
    auto_save_timer.wait_time = settings.gameplay.save_interval
    auto_save_timer.timeout.connect(_on_auto_save)
    add_child(auto_save_timer)

    if settings.gameplay.auto_save:
        auto_save_timer.start()

# -----------------------------------------------------------------------------
# 状态管理
# -----------------------------------------------------------------------------

func change_state(new_state: GameState) -> void:
    """改变游戏状态"""
    if new_state == current_state:
        return

    var old_state = current_state
    current_state = new_state

    # 处理状态变化
    handle_state_change(old_state, new_state)

    state_changed.emit(new_state, old_state)

func handle_state_change(old_state: GameState, new_state: GameState) -> void:
    """处理状态变化的逻辑"""
    match new_state:
        GameState.PLAYING:
            if settings.gameplay.auto_save:
                auto_save_timer.start()
        GameState.PAUSED:
            if auto_save_timer:
                auto_save_timer.paused = true
        GameState.MENU, GameState.GAME_OVER:
            if auto_save_timer:
                auto_save_timer.stop()

func get_current_state() -> GameState:
    """获取当前状态"""
    return current_state

func is_playing() -> bool:
    """是否在游戏中"""
    return current_state == GameState.PLAYING

func is_paused() -> bool:
    """是否暂停"""
    return current_state == GameState.PAUSED

# -----------------------------------------------------------------------------
# 玩家数据管理
# -----------------------------------------------------------------------------

func set_player_health(health: int) -> void:
    """设置玩家生命值"""
    player_data.current_health = clamp(health, 0, player_data.max_health)
    player_health_changed.emit(player_data.current_health, player_data.max_health)

    if player_data.current_health <= 0:
        on_player_died()

func damage_player(damage: int) -> void:
    """玩家受到伤害"""
    set_player_health(player_data.current_health - damage)

func heal_player(amount: int) -> void:
    """治疗玩家"""
    set_player_health(player_data.current_health + amount)

func restore_full_health():
    """恢复满血"""
    set_player_health(player_data.max_health)

func on_player_died() -> void:
    """玩家死亡处理"""
    temporary_data.deaths += 1
    player_died.emit()

func update_player_position(position: Vector2) -> void:
    """更新玩家位置"""
    player_data.position = position

func update_player_rotation(rotation: float) -> void:
    """更新玩家旋转"""
    player_data.rotation = rotation

# -----------------------------------------------------------------------------
# 经验和等级系统
# -----------------------------------------------------------------------------

func add_experience(amount: int) -> void:
    """增加经验值"""
    player_data.stats.experience += amount
    experience_gained.emit(amount)

    check_level_up()

func check_level_up():
    """检查升级"""
    while player_data.stats.experience >= player_data.stats.next_level_exp:
        level_up()

func level_up():
    """升级"""
    player_data.stats.level += 1
    player_data.stats.skill_points += 1
    player_data.stats.experience -= player_data.stats.next_level_exp
    player_data.stats.next_level_exp = calculate_next_level_exp(player_data.stats.level)

    # 升级时恢复满血
    restore_full_health()

    level_up.emit(player_data.stats.level)

func calculate_next_level_exp(level: int) -> int:
    """计算下一级所需经验"""
    return int(100 * pow(1.5, level - 1))

# -----------------------------------------------------------------------------
# 收集和分数系统
# -----------------------------------------------------------------------------

func add_coins(amount: int) -> void:
    """添加金币"""
    temporary_data.coins += amount
    coin_collected.emit(amount)

func add_score(points: int) -> void:
    """添加分数"""
    temporary_data.score += points

func get_score() -> int:
    """获取当前分数"""
    return temporary_data.score

func get_coins() -> int:
    """获取金币数量"""
    return temporary_data.coins

# -----------------------------------------------------------------------------
# 背包系统
# -----------------------------------------------------------------------------

func add_item(item_id: String, quantity: int = 1) -> bool:
    """添加物品到背包"""
    # 检查背包是否已满
    if player_data.inventory.size() >= get_max_inventory_size():
        return false

    # 查找是否已有该物品
    for item in player_data.inventory:
        if item.id == item_id:
            item.quantity += quantity
            return true

    # 添加新物品
    player_data.inventory.append({
        "id": item_id,
        "quantity": quantity
    })

    return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
    """从背包移除物品"""
    for i in range(player_data.inventory.size()):
        var item = player_data.inventory[i]
        if item.id == item_id:
            if item.quantity <= quantity:
                player_data.inventory.remove_at(i)
            else:
                item.quantity -= quantity
            return true

    return false

func get_item_count(item_id: String) -> int:
    """获取物品数量"""
    for item in player_data.inventory:
        if item.id == item_id:
            return item.quantity
    return 0

func has_item(item_id: String) -> bool:
    """是否有某个物品"""
    return get_item_count(item_id) > 0

func get_max_inventory_size() -> int:
    """获取背包最大容量"""
    return 20  # 可以根据玩家等级增加

# -----------------------------------------------------------------------------
# 关卡管理
# -----------------------------------------------------------------------------

func start_level(level_id: int) -> void:
    """开始关卡"""
    level_data.current_level = level_id
    change_state(GameState.PLAYING)

    # 加载关卡
    load_level(level_id)

func complete_level(score: int = 0) -> void:
    """完成关卡"""
    var level_id = level_data.current_level

    # 更新关卡数据
    if not level_data.level_scores.has(level_id):
        level_data.level_scores[level_id] = score
        level_data.unlocked_levels.append(level_id + 1)
    else:
        level_data.level_scores[level_id] = max(
            level_data.level_scores[level_id],
            score
        )

    # 记录时间
    level_data.level_times[level_id] = temporary_data.time_played

    level_completed.emit(level_id, score)
    change_state(GameState.VICTORY)

func unlock_level(level_id: int) -> void:
    """解锁关卡"""
    if level_id not in level_data.unlocked_levels:
        level_data.unlocked_levels.append(level_id)

func get_unlocked_levels() -> Array[int]:
    """获取已解锁关卡列表"""
    return level_data.unlocked_levels

# -----------------------------------------------------------------------------
# 存档系统
# -----------------------------------------------------------------------------

func save_game(slot: int = 1) -> bool:
    """保存游戏"""
    var save_data = {
        "version": "1.0",
        "timestamp": Time.get_unix_time_from_system(),
        "play_time": temporary_data.time_played,
        "current_level": level_data.current_level,
        "player_data": player_data,
        "level_data": level_data,
        "temporary_data": temporary_data,
        "current_checkpoint": temporary_data.current_checkpoint
    }

    var file = FileAccess.open("user://save_%d.json" % slot, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
        game_saved.emit()
        return true

    return false

func load_game(slot: int = 1) -> bool:
    """加载游戏"""
    var file = FileAccess.open("user://save_%d.json" % slot, FileAccess.READ)
    if not file:
        return false

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        push_error("Failed to parse save file")
        return false

    var save_data = json.data
    player_data = save_data.player_data
    level_data = save_data.level_data
    temporary_data = save_data.temporary_data

    # 加载当前关卡
    if save_data.has("current_level"):
        start_level(save_data.current_level)

    game_loaded.emit()
    return true

func has_save_file(slot: int = 1) -> bool:
    """检查是否有存档文件"""
    return FileAccess.file_exists("user://save_%d.json" % slot)

func get_save_files() -> Array:
    """获取所有存档信息"""
    var saves = []

    for i in range(1, 6):  # 支持5个存档槽
        var file = FileAccess.open("user://save_%d.json" % i, FileAccess.READ)
        if file:
            var json_string = file.get_as_text()
            file.close()

            var json = JSON.new()
            if json.parse(json_string) == OK:
                var save_data = json.data
                saves.append({
                    "slot": i,
                    "timestamp": save_data.get("timestamp", 0),
                    "play_time": save_data.get("play_time", 0),
                    "level": save_data.get("current_level", 1)
                })

    return saves

func delete_save(slot: int = 1) -> bool:
    """删除存档"""
    if DirAccess.remove_absolute("user://save_%d.json" % slot) == OK:
        return true
    return false

# -----------------------------------------------------------------------------
# 设置管理
# -----------------------------------------------------------------------------

func save_settings() -> void:
    """保存设置"""
    var file = FileAccess.open(settings_file_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(settings))
        file.close()

func load_settings() -> void:
    """加载设置"""
    var file = FileAccess.open(settings_file_path, FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        file.close()

        var json = JSON.new()
        if json.parse(json_string) == OK:
            var loaded_settings = json.data
            # 深度合并设置
            merge_settings(settings, loaded_settings)

func merge_settings(target: Dictionary, source: Dictionary):
    """深度合并设置字典"""
    for key in source:
        if key in target and target[key] is Dictionary and source[key] is Dictionary:
            merge_settings(target[key], source[key])
        else:
            target[key] = source[key]

func update_setting(category: String, key: String, value: Variant) -> void:
    """更新设置"""
    if category in settings:
        settings[category][key] = value
        save_settings()
        settings_changed.emit(category, key, value)

        # 应用某些设置
        apply_setting(category, key, value)

func apply_setting(category: String, key: String, value: Variant):
    """应用设置"""
    match category:
        "audio":
            match key:
                "master_volume", "music_volume", "sfx_volume":
                    AudioServer.set_bus_volume_db(
                        AudioServer.get_bus_index(key),
                        linear_to_db(value)
                    )
                "mute_audio":
                    AudioServer.set_bus_mute(
                        AudioServer.get_bus_index("Master"),
                        value
                    )
        "graphics":
            match key:
                "fullscreen":
                    DisplayServer.window_set_mode(
                        DisplayServer.WINDOW_MODE_FULLSCREEN if value
                        else DisplayServer.WINDOW_MODE_WINDOWED
                    )
                "vsync":
                    RenderingServer.vsync_enabled = value
                "resolution":
                    DisplayServer.window_set_size(value)

# -----------------------------------------------------------------------------
# 游戏重置
# -----------------------------------------------------------------------------

func reset_game() -> void:
    """重置游戏"""
    reset_temporary_data()
    reset_player_data()
    reset_level_data()
    change_state(GameState.MENU)
    game_reset.emit()

func reset_temporary_data():
    """重置临时数据"""
    temporary_data = {
        "score": 0,
        "coins": 0,
        "enemies_killed": 0,
        "time_played": 0.0,
        "deaths": 0,
        "current_checkpoint": null,
        "visited_areas": []
    }

func reset_player_data():
    """重置玩家数据"""
    player_data.current_health = player_data.max_health
    player_data.position = Vector2.ZERO
    player_data.rotation = 0.0
    player_data.inventory = []
    player_data.equipment = {}

func reset_level_data():
    """重置关卡数据"""
    level_data.current_level = 1
    # 保留已解锁关卡，重置其他数据

# -----------------------------------------------------------------------------
# 检查点系统
# -----------------------------------------------------------------------------

func set_checkpoint(checkpoint_id: String, position: Vector2) -> void:
    """设置检查点"""
    temporary_data.current_checkpoint = {
        "id": checkpoint_id,
        "position": position,
        "level": level_data.current_level
    }

    # 保存游戏进度
    if settings.gameplay.auto_save:
        save_game()

    checkpoint_reached.emit(checkpoint_id)

func load_checkpoint() -> Dictionary:
    """加载最后检查点"""
    return temporary_data.current_checkpoint if temporary_data.current_checkpoint else {}

# -----------------------------------------------------------------------------
# 工具方法
# -----------------------------------------------------------------------------

func format_time(seconds: float) -> String:
    """格式化时间显示"""
    var hours = int(seconds) / 3600
    var minutes = (int(seconds) % 3600) / 60
    var secs = int(seconds) % 60

    if hours > 0:
        return "%02d:%02d:%02d" % [hours, minutes, secs]
    else:
        return "%02d:%02d" % [minutes, secs]

func _on_auto_save():
    """自动保存"""
    if is_playing():
        save_game()

func _process(delta):
    """处理计时"""
    if is_playing():
        temporary_data.time_played += delta

# -----------------------------------------------------------------------------
# 调试和开发工具
# -----------------------------------------------------------------------------

func print_current_state():
    """打印当前游戏状态（调试用）"""
    print("=== Game State ===")
    print("Current State: ", current_state)
    print("Player Health: ", player_data.current_health, "/", player_data.max_health)
    print("Score: ", temporary_data.score)
    print("Coins: ", temporary_data.coins)
    print("Level: ", level_data.current_level)
    print("=================")

func unlock_all_levels():
    """解锁所有关卡（开发用）"""
    level_data.unlocked_levels = range(1, 51)  # 解锁1-50关

func add_debug_coins():
    """添加调试金币"""
    add_coins(1000)

# =============================================================================
# 使用示例
# =============================================================================

# 在游戏中使用：

# 1. 设置为自动加载后直接访问
# GameStateManager.change_state(GameStateManager.GameState.PLAYING)

# 2. 玩家受伤
# GameStateManager.damage_player(10)

# 3. 添加金币
# GameStateManager.add_coins(5)

# 4. 保存游戏
# GameStateManager.save_game(1)

# 5. 更新设置
# GameStateManager.update_setting("audio", "master_volume", 0.8)

# 监听事件：
# GameStateManager.health_changed.connect(_on_health_changed)
# GameStateManager.level_up.connect(_on_level_up)

# =============================================================================
# 扩展建议
# =============================================================================

# 1. 添加成就系统
# 2. 实现云存档功能
# 3. 添加多语言支持
# 4. 实现统计和排行榜
# 5. 添加调试模式
# 6. 实现存档加密