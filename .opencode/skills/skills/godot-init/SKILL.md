---
name: godot-init
description: Godot 4.x 项目初始化 Skill，创建标准目录结构、配置 MCP 服务器、生成 Autoload 单例框架、配置 .gitignore 和 project.godot。当需要创建新 Godot 项目、初始化项目结构、配置开发环境、设置 MCP 连接或生成项目模板时触发此技能。
---

# Godot 项目初始化器

使用标准化的结构和工具链初始化 Godot 4.x 项目。

## 何时使用

- 从零创建新 Godot 项目
- 重构现有项目以遵循约定
- 设置 MCP 服务器集成以支持 AI 辅助开发
- 生成 Autoload 单例框架

## 初始化清单

按顺序执行以下步骤。每步执行前需与用户确认。

### 步骤1：项目配置

收集必要信息：
- **项目名称**：用于 `project.godot` 和根目录
- **Godot 版本**：必须为 4.4+（UID 系统所需）
- **渲染引擎**：`forward_plus`（3D）或 `compatibility`（2D/移动端）
- **分辨率**：默认窗口大小

### 步骤2：创建目录结构

```
{project_name}/
├── project.godot
├── .gitignore
├── .mcp.json
├── AGENTS.md
│
├── src/
│   ├── autoload/
│   ├── actors/
│   ├── components/
│   ├── ui/
│   │   ├── hud/
│   │   ├── menus/
│   │   └── dialogs/
│   ├── levels/
│   │   └── _debug/
│   ├── resources/
│   │   ├── items/
│   │   ├── stats/
│   │   └── tables/
│   └── utils/
│
├── assets/
│   ├── sprites/
│   ├── audio/
│   │   ├── sfx/
│   │   └── music/
│   ├── fonts/
│   └── shaders/
│
├── addons/
├── tests/
└── exports/
    └── presets/
```

### 步骤3：生成 project.godot

```ini
; Engine configuration
config_version=5

[application]
config/name="{project_name}"
config/features=PackedStringArray("4.4")
run/main_scene=""
config/icon=""

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"

[rendering]
renderer/rendering_method="forward_plus"
```

### 步骤4：生成 .gitignore

```
# Godot
.godot/
*.tmp
export_presets.cfg

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp

# Exports
exports/builds/
```

### 步骤5：配置 MCP 服务器

在项目根目录创建 `.mcp.json`：

```json
{
  "mcpServers": {
    "godot": {
      "command": "npx",
      "args": ["@coding-solo/godot-mcp"],
      "env": {
        "GODOT_PATH": ""
      }
    }
  }
}
```

将 `GODOT_PATH` 设置为用户的 Godot 编辑器可执行文件路径。

### 步骤6：创建 Autoload 单例框架

在 `src/autoload/` 中创建最小化的 autoload：

**game_manager.gd**（单例，禁止 `class_name`）：
```gdscript
extends Node

signal game_paused
signal game_resumed

var _is_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func pause_game() -> void:
	_is_paused = true
	get_tree().paused = true
	game_paused.emit()

func resume_game() -> void:
	_is_paused = false
	get_tree().paused = false
	game_resumed.emit()

func is_paused() -> bool:
	return _is_paused
```

**scene_switcher.gd**（单例，禁止 `class_name`）：
```gdscript
extends Node

signal scene_changed(scene_name: String)

func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
	scene_changed.emit(path.get_file().get_basename())

func reload_current_scene() -> void:
	get_tree().reload_current_scene()
```

**audio_manager.gd**（单例，禁止 `class_name`）：
```gdscript
extends Node

var _music_players: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []

func play_music(stream: AudioStream, bus: String = "Music") -> void:
	pass

func play_sfx(stream: AudioStream, bus: String = "SFX") -> void:
	pass

func stop_music(fade_time: float = 1.0) -> void:
	pass
```

在 `project.godot` 中注册 autoload：
```ini
[autoload]
GameManager="*res://src/autoload/game_manager.gd"
SceneSwitcher="*res://src/autoload/scene_switcher.gd"
AudioManager="*res://src/autoload/audio_manager.gd"
```

### 步骤7：生成 AGENTS.md Godot 规则

追加到已有的 `AGENTS.md` 或创建新文件：

```markdown
## Godot Project Rules

### File References
- Use UID for resource references (Godot 4.4+): `load("uid://xxxxx")`
- Use %UniqueName for node references: `%Label` not `$VBox/Label`

### Scene Architecture
- Communication: top-down (parent -> child)
- Decoupling: use signal, never call get_parent() directly
- Reuse: component scenes + composition over inheritance

### Code Style
- GDScript 2.0 static typing
- @export for inspector-adjustable parameters
- class_name for main classes (NOT for singletons)
- Signal naming: snake_case (health_changed, player_died)

### Debugging
- Use MCP tools to run project and capture output
- Check debug logs before guessing error causes
- Screenshot-verify UI layouts

### Performance
- Physics in _physics_process
- Object pooling for frequent create/destroy
- No per-frame string concatenation or array allocation
```

### 步骤8：初始化 Git

```bash
git init
git add .
git commit -m "feat: initialize Godot project structure"
```

## 约束

- **禁止**在 Singleton/autoload 脚本中使用 `class_name`
- **必须**在所有生成的代码中使用静态类型
- **禁止**硬编码节点路径——使用 `%UniqueName`
- **必须**以 `*` 前缀注册 autoload 以启用全局访问
- Godot 版本必须为 4.4+（UID 支持）
- 文件命名：`snake_case`；节点命名：`PascalCase`
