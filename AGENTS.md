# Godot 游戏开发宪法（项目级）

> **Godot 4.x / GDScript 专属宪法**，条款为最高优先级指令，不可协商、不可绕过。
> 用户指令优先级高于 Skill；与全局通用宪法互补（语言、工具、ComfyUI、飞书、Git 等通用条款遵从全局约定）。
> 此文档**禁止**修改。

---

## 第〇章 元信息与适用范围

### 0.1 适用范围

- **适用**：Godot 4.x + GDScript（当前：Forward Plus、Jolt Physics）。被 Codex / OpenCode / Claude Code / ZCode 等主流 AI 编码工具默认读取，是协作的唯一行为基线。
- **例外**：C#、GDExtension / C++、Visual Script、编辑器插件开发——不适用本文件，须先与用户确认方案，不擅自套用 GDScript 规则。

### 0.2 规则标签与门禁标注

| 标签 | 含义 | 标注 | 含义 |
|------|------|------|------|
| `[P0]` | MVP 与正式开发均**强制**，违反即阻断提交 | `【命令】` | 可执行 CLI（如 headless 测试） |
| `[P1]` | 正式开发**强制**，MVP 强烈建议 | `【MCP】` | Godot MCP 诊断（minimal-godot / godot-ultimate / godot-mcp） |
| 无标签 | 最佳实践，建议遵守 | `【Skill】` | 项目内 Skill（architect / best-practices / patterns / code-review / static-analysis / ui） |

> **阶段原则**：MVP 满足所有 `[P0]`；正式开发满足全部 `[P0]+[P1]`。

---

## 第一章 核心心智模型

1. **四要素**：`Node`（构建块）→ `Scene`（可复用节点树 `.tscn`）→ `Resource`（数据容器 `.tres`）→ `Signal`（事件通信）。
2. **`[P0]` 信号向上、调用向下（signal up, call down）**：子节点只发信号、不知父节点存在；父节点连接子信号并向下调用。禁止子节点反向调用父方法。
3. **`[P0]` 组合优于继承**：用 has-a（组合/组件）表达能力，而非 is-a。
4. **`[P0]` 数据驱动优于硬编码**：配置/数值/参数走 `@export` / `Resource`，不在代码里写死。
5. **三原则**：单一职责、松耦合（最小依赖、接口通信）、高内聚（相关功能集中）。

---

## 第二章 项目结构规范

### 2.1 `[P0]` 标准目录树

```
res://
├── scenes/            # .tscn，按模块分子目录
├── scripts/           # .gd，与场景一一对应
├── assets/            # sprites/ sounds/ music/ fonts/ resources/(.tres)
├── addons/            # 第三方插件（GdUnit4 等）
├── test/              # unit/ integration/{模块}/ functional/+screenshots/
├── docs/              # 文档（.gdignore 屏蔽），目录规划见 §13.1
└── tmp/               # 临时文件（.gitignore 屏蔽，任务结束删除，见 §2.3）
```

### 2.2 `[P0]` 命名 / 路径 / 版本控制

- 文件名 `snake_case`，节点名 PascalCase；场景与脚本**一一对应**（`player.tscn` ↔ `player.gd`），避免孤儿脚本。
- `res://` 只读（随包发布）；`user://` 可读写（存档/设置/最高分）。
- `.godot/`、`.import/`、`export_presets.cfg`、`tmp/`、构建产物须在 `.gitignore`；`.tres`/`.tscn` 文本格式提交；`docs/` 加 `.gdignore`。

### 2.3 `[P0]` 临时文件管理

- **统一存放**：任务执行中生成的临时文件（中间产物、缓存、调试文件、临时脚本等）**必须**保存到项目根 `tmp/` 目录，**禁止**散落到 `res://` 其他位置或系统临时目录。
- **任务结束必删**：任务结束后**必须**删除本次产生的全部临时文件；仅当用户**明确**要求保留或该文件已成为最终交付物时方可保留。
- **版本控制**：`tmp/` 一律 `.gitignore` 屏蔽（见 §2.2），**禁止**提交。

---

## 第三章 GDScript 编码规范

> **门禁**：`【MCP】` `minimal-godot_get_diagnostics`（0 错误）、`godot-ultimate_godot_lint_file`（0 error 0 warning）、`【Skill】` `godot-best-practices`。

### 3.1 `[P0]` 命名约定 + 静态类型全标注

```gdscript
class_name PlayerController            # 类名 PascalCase
signal health_changed(new_hp: int)     # 信号 past_tense + 类型参数
const MAX_SPEED: float = 200.0         # 常量 SCREAMING_SNAKE_CASE
var current_health: int = 100          # 变量 snake_case
var _private_count: int = 0            # 私有 _ 前缀
func calculate_damage(base: int) -> int: pass   # 函数 snake_case + 返回类型
@onready var sprite: Sprite2D = $Sprite2D        # @onready + 类型标注
```

> 变量、函数签名、返回值、信号参数、`@onready` 引用**必须**显式类型标注。

### 3.2 `[P0]` class_name 规则

- **Autoload / Singleton 脚本**：**禁止** `class_name`（用全局名访问）。
- **非 Singleton 脚本**：**必须** `class_name`，**禁止**用 `preload`/`load` 后的变量名当类型别名。

### 3.3 `[P0]` 脚本结构顺序（自上而下）

```
@tool / class_name / extends → ##文档注释 → # === Signals ===
→ # === Enums === → # === Exports ===(用 @export_group 分组) → # === Constants ===
→ # === Public Variables === → # === Private Variables ===(_前缀)
→ # === Onready === → # === Lifecycle ===(_ready/_process/_physics_process)
→ # === Public Methods === → # === Private Methods ===
```

### 3.4 `[P0]` 文档与卫生

- **代码除注释外无中文**（标识符/字符串字面量用英文/拼音，注释可中文）。
- 每个 `func`、`enum` 及枚举值、`signal` 须有 `##` 注释。
- 参数名**不与节点内置属性冲突**（`name`、`position`、`scale`）；命名精确反映用途，删不可达代码。

---

## 第四章 场景与节点规范

> **门禁**：`【MCP】` `godot-ultimate_godot_validate_scenes`（断裂引用 = 0）。

### 4.1 `[P0]` 节点引用

```gdscript
@onready var health_bar: ProgressBar = $UI/HealthBar   # ✅ @onready + 类型
@onready var player: Player = %Player                  # ✅ 关键节点 %UniqueName
# ❌ 禁止：get_node() in _ready()、深路径 $A/B/C/D、get_parent().get_parent() 链
```

### 4.2 `[P0]` 场景设计

- 每个场景**自包含、可复用、可实例化**，不依赖特定父节点路径。
- 关键跨场景节点用 `%UniqueName`；`queue_free()` 前用 `is_instance_valid(node)` 检查，**禁止** `!= null` 判已释放节点。

### 4.3 `[P0]` 动画节点选择

- **优先 `AnimationPlayer`**：动画需求一律首选 `AnimationPlayer`。它可驱动任意节点的任意属性（变换/材质/可见性/方法调用）、支持多轨并行与多节点编排、动画融合/队列/事件轨，扩展性远超 `AnimatedSprite2D`。
- **`AnimatedSprite2D` 受限使用**：仅当**纯逐帧切换**且无任何属性联动时方可独立使用；**禁止**以 `AnimatedSprite2D` 作为场景的主动画驱动。需要逐帧动画时，由 `AnimationPlayer` 通过 `SpriteFrames` 轨或调用其 `play()` 统一编排。
- **推荐组合**：`Sprite2D`/`AnimatedSprite2D`（负责显示）+ `AnimationPlayer`（负责编排）的 has-a 结构，符合「组合优于继承」（§1.3）。

---

## 第五章 信号与通信

### 5.1 `[P0]` 信号驱动（.emit() / connect，非字符串）

```gdscript
# 子节点：只发信号
signal died
func take_damage(a: int) -> void:
    if _hp <= 0: died.emit()          # ✅ .emit()，非 emit_signal("died")
# 父节点：连接并向下调用
func _ready() -> void:
    health.died.connect(_on_died)     # ✅ connect，非 .connect("died", ...)
signal score_updated(new: int, old: int)   # ✅ 类型化信号
# ❌ 禁止 emit_signal("x") / connect("x", ...) 字符串形式
```

### 5.2 通信解耦

- `[P0]` 禁止子节点直接调用父节点方法。
- `[P1]` **EventBus**：Autoload 全局信号总线，**仅放精简跨系统事件**，不塞业务逻辑。
- `[P1]` **组件系统**：`HealthComponent`/`HitboxComponent`/`HurtboxComponent` 等 has-a 组合。

---

## 第六章 资源与数据驱动（`[P1]`）

- **Resource 承载数据**：`@export var damage: int = 10`，配置存 `.tres`（可 Inspector 编辑/复用/继承）；**运行时须 `duplicate()` 副本**避免污染共享数据。

| 场景 | 方法 |
|------|------|
| 小/关键资源（编译期） | `preload("res://...")` |
| 大/可选资源（运行期） | `load("res://...")` 并缓存 |
| 异步防卡顿 | `ResourceLoader.load_threaded_request` + 轮询 status |

---

## 第七章 架构模式

### 7.1 `[P0]` 状态机

- **简单状态**：`enum State { IDLE, WALK }` + `match current_state`。
- **复杂状态**：`StateMachine`(Node) + `State`(Node 子类) 节点模式，每状态 `enter/exit/update/physics_update/handle_input`。详见 `【Skill】` `godot-gdscript-patterns`。

### 7.2 `[P1]` 对象池 / 组件 / Autoload（正式开发）

- **对象池**：高频创建销毁对象（子弹/特效）用 `ObjectPool` 复用，禁 `_process` 内 `load`/`instantiate`。
- **Autoload**：仅真全局服务（GameManager / SaveManager / AudioManager / EventBus），**禁止**塞游戏逻辑。
- **组件系统**：能力以组件挂载，`has_method()`/`is` 判定能力而非类型硬依赖。

---

## 第八章 UI 规范（`[P1]`，详见 `【Skill】` `godot-ui`）

- **布局**：`Control` + 容器（VBox/HBox/Grid/Margin/Scroll）自适应，避免手算坐标；`CanvasLayer` 分层（HUD=10、Pause=100）；`Theme` 存 `.tres`（`assets/resources/theme/`）。
- **可访问性**：所有交互控件须支持键盘/手柄（`focus_neighbor_*` focus 链 + 入口 `grab_focus()`）；隐藏 UI 用 `process_mode = PROCESS_MODE_DISABLED`。

---

## 第九章 测试规范

### 9.1 `[P0]` 框架与分层

默认 **GdUnit4**（[godot-gdunit-labs/gdUnit4](https://github.com/godot-gdunit-labs/gdUnit4)）。三层：`test/unit/`（单类/函数）、`test/integration/{模块}/`（多模块协作）、`test/functional/`（端到端 + 截图）。

### 9.2 `[P0]` TDD 小循环（Red-Green-Refactor，单测驱动）

> **强制小步快跑**：每次只生成 **1 个测试方法** → 编码使其通过 → 重构，循环推进。禁止"先写一批测试再实现"。

```
[Skill] test-driven-development:
1.Red 写1个失败测试(单一行为/边界) → 2.Green 写刚好满足的最小实现(不过度设计)
→ 3.Refactor 测试保护下重构保持绿 → 4.回到1写下个测试
```

- 每个公开方法/分支/边界至少 1 个测试；命名描述行为 `test_take_damage_reduces_health()`。
- 用 `add_child_autoqfree(child)` 自动清理；浮点比较用 `assert_almost_eq`，**禁止** `assert_eq` 比浮点。

### 9.3 `[P0]` Headless CI 两步流水线

> **入口路径以当前 GdUnit4 版本为准**：v4.6 起命令行入口为 `addons/gdUnit4/bin/GdUnitCmdTool.gd`（旧版 `src/runner/GdUnitRunnerCmd.gd` 已移除）。新版在 `--headless` 下默认以 exit 103 拒绝运行（UI 交互测试在 headless 不可靠），**必须**加 `--ignoreHeadlessMode` 才能跑。测试目录为 `test/`（非 `tests/`）。

```bash
$GODOT_HOME --headless --import                                                                # Step1 预热导入
$GODOT_HOME --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a test/ --ignoreHeadlessMode   # Step2 跑套件
```

### 9.4 覆盖率

`[P1]`（正式开发）≥ 80%；`[P0]`（MVP）覆盖关键逻辑路径。门禁 `【MCP】` `godot-ultimate_godot_get_test_coverage`。

---

## 第十章 质量门禁（提交前必过）

> 指标体系复用 `【Skill】` `godot-static-analysis` 的 C01–C12，提交前**必须**全部达标。

| 编号 | 门禁项 | 阈值 | 命令 / MCP | 阶段 |
|------|--------|------|-----------|:---:|
| G01 | 语法/类型错误 | 0 | `【MCP】` `minimal-godot_scan_workspace_diagnostics` | P0 |
| G02 | Lint（error+warning） | 各 0 | `【MCP】` `godot-ultimate_godot_lint_project` | P0 |
| G03 | 场景断裂引用 | 0 | `【MCP】` `godot-ultimate_godot_validate_scenes` | P0 |
| G04 | 项目全局验证 | 全通过 | `【MCP】` `godot-ultimate_godot_validate_project` | P0 |
| G05 | 未定义 Input Action | 0 | `【MCP】` `godot-ultimate_godot_validate_inputs` | P0 |
| G06 | headless 测试套件 | 全绿 | `【命令】` `godot --headless`（§9.3） | P0 |
| G07 | 函数圈复杂度 | ≤ 10 | `godot-ultimate_godot_get_complexity` | P1 |
| G08 | 代码重复（≥5 行） | 0 组 | `godot-ultimate_godot_find_duplication` | P1 |
| G09 | 死代码（未用 func/var/signal） | 0 | `godot-ultimate_godot_detect_dead_code` | P1 |
| G10 | 未用文件 | 0 | `godot-ultimate_godot_find_unused_files` | P1 |
| G11 | 测试覆盖率 | ≥ 80% | `godot-ultimate_godot_get_test_coverage` | P1 |
| G12 | 项目健康度评分 | ≥ 80 | `godot-ultimate_godot_project_health` | P1 |
| G13 | 代码模式合规 | 0 违规 | `godot-ultimate_godot_check_patterns` | P1 |

---

## 第十一章 性能规范（`[P1]` 正式开发强制，MVP 量力而行）

1. `_process` / `_physics_process` 内**禁止** `load`、频繁内存分配、轮询未变状态。
2. 缓存 `@onready` 引用与计算结果，避免每帧重复求值。
3. 高频对象用对象池；离屏节点 `process_mode = DISABLED` 或 `visible = false`。
4. 大资源用 `ResourceLoader.load_threaded_*` 异步加载防卡顿。
5. 静态类型全标注利于 GDScript 性能。

---

## 第十二章 AI Agent 协作与工作流

> 本章合并协作守则与完整工作流。**前置·必做**：每个任务开始前**必须**先读 `docs/99_postmortem/MEMORY.md` 吸取历史教训（§12.6）。

### 12.1 `[P0]` 场景文件必须由工具生成，禁止手写

`.tscn` / `.tres` **禁止**纯手工编写文本（极易产生 UID/sub_resource 引用错误），必须用：Godot 编辑器可视化编辑；或 `【MCP】` `godot-mcp`（`create_scene`/`add_node`/`save_scene`/`load_sprite`）；或 `【MCP】` `godot-ultimate`（`godot_generate_feature`/`godot_generate_from_template`）。

### 12.2 `[P0]` Skill 链不可绕过

CLI/Skill 已提供能力时**禁止**绕过直接调底层 API 或手写封装。Godot 开发协作链：

```
架构设计  →【Skill】godot-architect（只设计，不写码）
编码实现  →【Skill】godot-best-practices / godot-gdscript-patterns
TDD 循环 →【Skill】test-driven-development（§9.2 单测小循环）
代码检视 →【Skill】godot-code-review（逐文件，用户确认）
质量验证 →【Skill】godot-static-analysis（§10 门禁）
UI 开发  →【Skill】godot-ui
可视化搭建 → AI 用 MCP 写视觉初值 + 出指导，用户在编辑器精调（§12.4）—— 最终视觉/手感以用户为准
```

### 12.3 `[P0]` 增量与小步验证

- 每个改动**小步可验证**：一次只动一个职责，立即跑测试/诊断。
- 架构级变更**必须**先经 `【Skill】` `godot-architect` 出设计再实现；完成后**必须**经 `【Skill】` `godot-code-review` 与用户逐文件确认。

### 12.4 `[P0]` 可视化搭建协作（强制关卡）

> **理由**：AI 无法"看见"渲染/物理结果，但可凭命名约定、美术规范、设计文档给出**合理初值**；"最终好不好看/手感对不对"只能靠人眼与试玩判定。故采用「AI 用 MCP/编辑器写入初值 → 用户精调到最终效果」两段式。

**触发条件**（满足任一）：新建或修改含可见节点的场景（`Sprite2D`/`AnimatedSprite2D`/`CollisionShape2D`/`Camera2D`/`Control`/`TileMapLayer`/`AudioStreamPlayer`/`GPUParticles2D` 等），或需配置动画/碰撞/变换/纹理/摄像机/布局/瓦片/音频/粒子等视觉属性。

**分工**：

| 类别 | AI 写入初值（可自动化） | 用户精调到最终（眼看手调/试玩） |
|------|----------------------|------------------------------|
| 脚本/数据/骨架 | `.gd` 逻辑、`.tscn` 节点树骨架、`.tres` 数值、挂 `CollisionShape2D`+默认形状、按约定指定 `texture`、设默认 zoom/limit、建空 `SpriteFrames`+动画名 | — |
| 动画/碰撞/变换/纹理/摄像机/布局/瓦片/音频/粒子 | 建资源与动画名、设默认 fps/音量/参数 | 拖入实际素材帧、按实际外形精调形状尺寸、试玩后微调位置/取景/音量、绘制 TileMap 格子等 |

**AI 先做（初配）**：用 `【MCP】` `godot-mcp` 为视觉属性写入合理初值。

**输出「可视化搭建指导」须含 5 部分**：①场景与节点（路径+类型）；②已写入初值清单；③需精调项+参考规格；④编辑器精调操作步骤；⑤反馈要求。

**反馈机制**：用 `question` 给两选项后**立即停止**：①✅已完成精调，继续后续门禁（推荐）；②❌需 AI 调整骨架/脚本/初值。**用户精调结果以编辑器最终值为准，AI 不得回退覆盖。**

### 12.5 `[P0]` 玩家手工验证（强制关卡）

> **编辑器重载后、提交代码前必须执行**（见 §12.7 前置）。**禁止**跳过，**禁止**用自动化测试替代。

**黑盒验证**：玩家以用户视角操作**现有实现**（现有场景/关卡），对照 **story 验收标准**（`docs/07_story/`，无 story 则用需求/架构功能点）逐条核验；**禁止**另建测试关卡/临时场景，AI **不得**臆造验收标准。

**输出「验证指导」须含 5 部分**：①运行方式（启动**现有**游戏，F5/F6/命令行，不另建场景）；②验收标准映射（列 story 的 AC1/AC2…）；③验证步骤（针对②逐步操作，全部走现有实现，给具体 Input Action）；④预期表现（每条 AC 的 Pass 判据：画面/动画/音效/数值）；⑤异常判定（失败现象 + 玩家需提供的反馈：报错截图/日志/复现步骤）。

**反馈机制**：用 `question` 给两选项后**立即停止**：①✅验证通过，继续提交（推荐）；②❌有问题，需修复。通过→提交；失败→修复循环（最小改动→重跑诊断/lint→重载编辑器→**再次**输出验证指导+`question`），由玩家驱动，AI 不得擅自宣布通过。

### 12.6 `[P0]` 经验沉淀与收尾闭环

每次任务/检视后，将经验追加到 `docs/99_postmortem/MEMORY.md`，按**双区**区分：**通用经验**（跨 Godot 项目可复用，如"浮点用 assert_almost_eq"）、**项目专属经验**（仅适用本项目）。

**收尾闭环（强制，不可跳过）**：

1. **提交经验文档**：**独立 commit** MEMORY.md（与代码 commit 分开），消息 `docs: 沉淀本次{任务}经验`（遵从全局 §4.2）。
2. **飞书通知**：用 `【Skill】` `lark-im` 发送任务完成通知。凭证**全部从项目根 `.env` 读取**（遵从全局 §1.4/§2.4），**禁止**硬编码：`FEISHU_APP_ID`（鉴权）、`FEISHU_APP_SECRET`（鉴权）、`FEISHU_USER_ID`（接收人 open_id）。通知内容至少含：任务摘要、变更文件数、是否全部门禁通过、经验沉淀要点。

> **顺序约束**：代码提交 → 经验沉淀 → 经验文档提交 → 飞书通知（见 §12.7）。禁止在经验文档提交前发送完成通知。

### 12.7 工作流总览

> **`[P0]` 开发收尾前置**：代码开发完成后、提交前**必须**在 Godot 编辑器重新加载当前项目（Project → Reload Current Project，或 `$GODOT_HOME -e` 重启），刷新资源导入与场景/脚本引用，避免 `.import`/缓存漂移。

```
【前置·必做】读取 docs/99_postmortem/MEMORY.md 吸取经验教训（§12.6）

需求 →【任务简报】总结任务概要/简报和验收标准
     →【Skill: architect】架构设计文档(含 Mermaid 图)
     →【Skill: best-practices + TDD 小循环】1个测试→最小实现→重构(循环) +【MCP】搭场景节点骨架
     →【可视化协作 §12.4】AI 用 MCP 写视觉初值 + 输出「可视化搭建指导」+ question 暂停 ⚠️涉及可见节点时强制
     →【MCP: minimal-godot/godot-ultimate】诊断 + lint
     →【Skill: code-review】自行逐文件检视
     →【Skill: code-review】在编辑器中(vscode)逐个文件打开，和用户一起检视
     →【设计-实现一致性】确认设计-实现一致性(§13.3)
     →【命令: headless】测试套件全绿（§9.3）
     →【Skill: static-analysis】§10 全部门禁达标
     →【收尾·必做】Godot 编辑器重新加载当前项目（刷新资源导入与场景/脚本引用）
     →【玩家手工验证 §12.5】输出验证指导 + question 等玩家反馈 ⚠️验证通过前禁止提交
     → 提交代码（全局 §4.2 commit 规范）
     → 经验沉淀 docs/99_postmortem/MEMORY.md（§12.6）
     → 提交经验文档（独立 commit）
     →【Skill: lark-im】飞书通知用户任务完成
```

> **两强制关卡不可互相替代**：§12.4 是**搭建期**配置（AI 写初值+用户精调视觉属性）；§12.5 是**运行期**验证（玩家试玩黑盒验收）。

---

## 第十三章 文档交付与一致性校验

### 13.1 `[P0]` docs/ 目录规划与两阶段维护

`docs/` 顶层按文档类型/生命周期编号分目录，文件命名 `{两位序号}_{中文名称}.md`（遵从全局 §3.1）。设计文档须用 **Mermaid** 绘制架构图/状态机图/流程图（遵从全局 §3.3）；架构类文档须含场景树结构、核心接口/信号定义、状态机图、依赖关系。

| 目录 | 职责 | 典型文件 | MVP `[P0]` | 正式 `[P1]` |
|------|------|---------|:---:|:---:|
| `README.md` | **游戏主题介绍（面向玩家/访客的门面）**：仅含游戏名称、简介、核心玩法亮点；**禁止**技术性/进度内容（详见 §13.4） | `README.md` | ✅ 必备 | ✅ 持续维护 |
| `00_开发指南/` | **开发者入口**：环境/怎么跑/技术栈/项目结构/文档索引/开发约定/里程碑（README 剥离出的全部技术性内容归宿） | `01_快速开始.md` | ✅ 必备 | ✅ 持续维护 |
| `01_需求/` | 需求与玩法设计（GDD） | `01_核心玩法.md`、`02_操作设计.md`、`03_关卡设计.md` | ✅ 核心玩法必备 | ✅ 持续维护 |
| `02_架构/` | 技术架构/场景树/状态机/接口/ADR | `01_技术架构.md`、`02_{模块}架构.md`、`03_ADR决策记录/{NN}_{决策}.md` | ✅ 技术架构必备；模块架构/ADR 🟡 按需 | ✅ 每模块必备 + 重要决策必记 |
| `03_美术规范/` | 美术风格/精灵命名尺寸/导入/调色板 | `01_美术总览.md`、`02_精灵规范.md`、`03_调色板.md` | 🟡 大纲即可 | ✅ 完整规范 |
| `04_音频规范/` | 音效音乐清单/Bus 路由/音量基线 | `01_音频总览.md`、`02_音频清单.md`、`03_Bus路由.md` | 🟡 大纲即可 | ✅ 完整规范 |
| `05_测试策略/` | 测试分层/覆盖率/CI/约定 | `01_测试总览.md`、`02_覆盖率目标.md`、`03_CI流水线.md` | 🟡 测试约定（本宪法 §9） | ✅ 完整策略 + 覆盖率 |
| `06_构建发布/` | 导出预设/多平台/版本/检查清单 | `01_导出预设.md`、`02_多平台发布.md`、`03_发布检查.md` | 🟡 MVP 导出预设 | ✅ 多平台完整 |
| `07_story/` | 用户故事（按模块分子目录，可选） | `01_{模块}/01_{故事名}.md` | ⬜ 按需 | ⬜ 按需 |
| `99_postmortem/` | 经验沉淀（通用/项目专属双区） | `MEMORY.md`（§12.6） | ✅ 必备 | ✅ 持续沉淀 |

> 图例：✅ 强制维护 ｜ 🟡 按需/大纲即可 ｜ ⬜ 该阶段不强制
> **MVP 最小必备集合（5 件）**：`README.md`（纯游戏主题）+ `00_开发指南/01_快速开始.md`（技术性内容归宿）+ `01_需求/01_核心玩法.md` + `02_架构/01_技术架构.md` + `99_postmortem/MEMORY.md`。其余 🟡 项须在对应功能实现前先出大纲，避免"先写码后补文档"。

### 13.2 `[P0]` 文档交付索引（按阶段读取/产出，禁止跳过）

| 阶段 | 应读文档 | 应产文档 | 位置约定 |
|------|---------|---------|---------|
| 需求/架构 | `01_需求/`、历史 `02_架构/`、`MEMORY.md` | 架构设计文档（含 Mermaid） | `02_架构/{NN}_{模块}架构.md` |
| Story 拆分（可选） | `01_需求/`、`02_架构/{模块}` | Story 文档 | `07_story/{NN}_{模块}/{NN}_{故事}.md` |
| 编码实现 | 对应 `02_架构/`、`MEMORY.md` | 代码 + 注释 | `scripts/` `scenes/` |
| 测试 | `05_测试策略/`、本宪法 §9 | 测试用例 | `test/{unit,integration,functional}/` |
| 检视/复盘 | 本宪法 §3-§8、`MEMORY.md` | 检视总结 | `99_postmortem/MEMORY.md` |
| 构建发布 | `06_构建发布/` | 发布产物 + 版本 | `build/` |

### 13.3 `[P0]` 设计-实现一致性校验

每个功能交付前**必须**对比"设计文档"与"实际代码"：①读模块设计文档（架构图/接口/状态机）；②对照实际 `.gd`/`.tscn`（节点结构/信号/接口/状态枚举）；③不一致即修正（代码偏离改代码；设计过时更新文档并说明原因）；④在代码检视（§12.3）中**显式声明一致性结论**。

### 13.4 `[P0]` README 内容约束

> 本节为 2026-06-21 用户授权新增（见开头变更记录）。**README.md 是项目的「游戏门面」**，面向玩家与外部访客，定位与 `docs/` 下技术文档严格区分。

**允许的内容**（面向玩家/访客的题材表达）：
- 游戏名称、代号、副标题、宣传语
- 游戏画面/封面图
- 项目简介、世界观、角色设定
- 核心玩法亮点（玩法层面，非技术实现）
- 指向开发文档的单一入口链接（如「开发者入口 → 开发指南」）

**禁止的内容**（技术性 / 进度性，一律迁移至 `docs/00_开发指南/`）：
- ❌ 技术栈、引擎/语言/框架选型、渲染管线、物理引擎等
- ❌ 环境要求、依赖版本、环境变量（`GODOT_HOME` 等）
- ❌ 如何运行、命令行、构建/导出步骤、headless/CI 流程
- ❌ 项目结构、目录树、文件清单
- ❌ 文档索引、开发约定、编码规范、质量门禁、工作流
- ❌ 里程碑、进度状态（✅/🟡/⬜）、开发阶段标记
- ❌ 任何代码块、命令、脚本、配置示例

**迁移与维护规则**：
- 原 README 中的全部技术性内容归宿为 `docs/00_开发指南/01_快速开始.md`，保持相对链接正确（从 `docs/00_开发指南/` 视角：`../` 进 `docs/`，`../../` 进项目根）。
- 后续新增任何技术性/进度性信息，**必须**写入 `00_开发指南/`（或对应 `docs/` 子目录），**禁止**回流 README。
- README 仅在「游戏主题本身变更」（改名/换题材/玩法调整）时才更新；技术迭代不触动 README。
- 检视（§12.3）时须显式校验：README 是否混入技术/进度内容，违规即迁移修正。

---

## 附录

### A. 命令速查

> **`godot` 命令路径从系统环境变量 `$GODOT_HOME` 读取**
> `mac`上从 `~/.zshrc` 获取

```bash
$GODOT_HOME --headless --import                                                                        # 预热导入（§9.3 Step1）
$GODOT_HOME --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a test/ --ignoreHeadlessMode   # 跑测试（Step2）
$GODOT_HOME --headless --check-only --script scripts/xxx.gd                                            # 语法检查（备选）
```

### B. MCP / Skill 索引

- **MCP（项目已配）**：`minimal-godot`（`get_diagnostics`/`scan_workspace_diagnostics`，G01）；`godot-ultimate`（lint/validate_scenes/validate_project/get_test_coverage/project_health 等，G02–G13）；`godot-mcp`（`create_scene`/`add_node`/`save_scene`/`load_sprite`，场景生成）。
- **Skill（项目内）**：`godot-architect` · `godot-best-practices` · `godot-gdscript-patterns` · `godot-code-review` · `godot-static-analysis` · `godot-ui`。
- **业界参考**：[AGENTS.md 规范](https://agents.md/) · [GdUnit4](https://github.com/godot-gdunit-labs/gdUnit4) · [GodotPrompter](https://github.com/jame581/GodotPrompter) · [Godot Autoload 文档](https://docs.godotengine.org/en/latest/tutorials/scripting/singletons_autoload.html)。

```

> 隐藏/工具目录（不纳入版本管理或自动生成）：`.opencode/`（OpenCode agents+skills）、`.zcode/`（ZCode 配置）、`.godot/`（引擎缓存）、`tmp/`（任务临时文件，任务结束删除，见 §2.3）、`.env`（本地环境变量，勿提交）、`.gitignore` / `.gitattributes` / `.editorconfig`。
