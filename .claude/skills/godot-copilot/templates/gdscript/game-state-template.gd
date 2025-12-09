extends Node
## 游戏状态管理器（Singleton模板）
##
## ⚠️ 重要提醒：Singleton 文件禁止写 class_name！
## Singleton 脚本通过文件名在项目中访问，不需要 class_name
## 例如：game.gd → 在项目中直接通过 Game 访问（如果在 project.godot 中配置为 Game）
##
## 此模板文件不包含 class_name，这是正确的做法

# 游戏状态枚举
enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER,
    VICTORY
}

# 游戏统计数据
var score: int = 0
var lives: int = 3
var level: int = 1
var coins_collected: int = 0
var enemies_defeated: int = 0

# 游戏配置
var max_lives: int = 3
var starting_level: int = 1

# 游戏状态
var current_state: GameState = GameState.MENU
var is_game_active: bool = false

# 玩家数据
var player_position: Vector2 = Vector2.ZERO
var player_health: float = 100.0
var player_max_health: float = 100.0

# 游戏进度
var levels_unlocked: Array[int] = [1]
var current_checkpoint: String = ""

# 信号定义
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal victory_achieved
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_changed(new_level: int)
signal player_health_changed(current_health: float, max_health: float)

# ===== 游戏控制方法 =====

func start_new_game():
    """开始新游戏"""
    reset_game_data()
    current_state = GameState.PLAYING
    is_game_active = true
    game_started.emit()

func pause_game():
    """暂停游戏"""
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true
        game_paused.emit()

func resume_game():
    """恢复游戏"""
    if current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false
        game_resumed.emit()

func end_game():
    """结束游戏"""
    current_state = GameState.GAME_OVER
    is_game_active = false
    get_tree().paused = false
    game_over.emit()

func win_game():
    """游戏胜利"""
    current_state = GameState.VICTORY
    is_game_active = false
    victory_achieved.emit()

# ===== 数据管理方法 =====

func reset_game_data():
    """重置游戏数据"""
    score = 0
    lives = max_lives
    level = starting_level
    coins_collected = 0
    enemies_defeated = 0
    player_health = player_max_health
    current_checkpoint = ""

func add_score(points: int):
    """增加分数"""
    score += points
    score_changed.emit(score)

func lose_life():
    """失去生命"""
    lives -= 1
    lives_changed.emit(lives)

    if lives <= 0:
        end_game()

func heal_player(amount: float):
    """治疗玩家"""
    player_health = min(player_health + amount, player_max_health)
    player_health_changed.emit(player_health, player_max_health)

func damage_player(amount: float):
    """对玩家造成伤害"""
    player_health = max(player_health - amount, 0)
    player_health_changed.emit(player_health, player_max_health)

    if player_health <= 0:
        lose_life()

# ===== 关卡管理 =====

func next_level():
    """进入下一关"""
    level += 1
    if level not in levels_unlocked:
        levels_unlocked.append(level)
    level_changed.emit(level)

func set_checkpoint(checkpoint_name: String):
    """设置检查点"""
    current_checkpoint = checkpoint_name

# ===== 数据持久化 =====

func save_game():
    """保存游戏"""
    var save_data = {
        "score": score,
        "lives": lives,
        "level": level,
        "coins_collected": coins_collected,
        "enemies_defeated": enemies_defeated,
        "levels_unlocked": levels_unlocked,
        "player_health": player_health
    }

    # 使用Godot的文件系统保存
    var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
    if file:
        file.store_var(save_data)
        file.close()

func load_game():
    """加载游戏"""
    var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
    if file:
        var save_data = file.get_var()
        file.close()

        # 恢复游戏数据
        score = save_data.get("score", 0)
        lives = save_data.get("lives", max_lives)
        level = save_data.get("level", 1)
        coins_collected = save_data.get("coins_collected", 0)
        enemies_defeated = save_data.get("enemies_defeated", 0)
        levels_unlocked = save_data.get("levels_unlocked", [1])
        player_health = save_data.get("player_health", player_max_health)

        # 发送更新信号
        score_changed.emit(score)
        lives_changed.emit(lives)
        level_changed.emit(level)
        player_health_changed.emit(player_health, player_max_health)