# 项目宪法

> 本文档为项目最高优先级指令，不可协商、不可绕过。用户指令优先级高于本文档。
> 每次任务前**必须**识别开发阶段（见 1.2），所有规则在所有阶段**必须**遵守。

---

## 一、参考数据

### 1.1 术语

| 术语 | 含义 |
|------|------|
| 用户任务 | 用户发出的一次完整请求，从接收到最终交付 |
| Story | Sprint 中的用户故事，包含多个 agent_task |
| agent_task | Story 内的子代理执行单元（如 `@godot-developer`） |
| 功能测试 | 通过按键模拟和截图验证的端到端测试 |
| 任务完成 | 代码已写入 + 测试通过 + lint 通过 + 用户已确认 |

### 1.2 开发阶段

| 阶段 | 触发条件 | 产出 |
|------|---------|------|
| 初始化 | 项目首次创建 | 目录、工具配置 |
| 游戏设计 | 收到游戏概念 | GDD、功能需求 |
| 技术分析 | 设计文档就绪 | 可行性分析、性能分析 |
| 架构设计 | 技术分析通过 | 架构概要、模块/状态机设计 |
| 迭代开发 | 架构完成 + Backlog 就绪 | Story 拆分、编码、测试 |
| 交付 | 所有 Story 完成 | 复盘、归档 |

### 1.3 环境变量

| 变量 | 用途 | 来源 |
|------|------|------|
| `GODOT_HOME` | Godot 编辑器路径 | OS 环境变量 |
| `FEISHU_APP_ID` | 飞书应用 ID | `.env` |
| `FEISHU_APP_SECRET` | 飞书应用 Secret | `.env` |
| `FEISHU_USER_ID` | 用户 open_id（`ou_` 开头） | `.env` |

> `.env` 缺失时**必须**先提醒用户配置。

### 1.4 工具标注

| 标注 | 含义 | 示例 |
|------|------|------|
| `[MCP]` | Godot MCP 工具 | `minimal-godot_get_diagnostics` |
| `[Skill]` | OpenCode Skill | `godot-best-practices`、`lark-im` |
| `[Agent]` | 子代理，通过 `task()` 调度 | `@godot-developer` |
| `[CLI]` | 命令行（Bash 工具执行） | `$GODOT_HOME -s addons/gut/gut_cmdln.gd` |

### 1.5 子代理

> 配置位于 `.opencode/agents/`，`hidden: true`，仅通过主代理 `task()` 调度。

| 代理 | 分类 | Skill | 权限 | 职责 |
|------|------|-------|------|------|
| `godot-ui-designer` | 开发 | `godot-ui` | 只读+文档 | UI 场景设计 |
| `godot-architect` | 开发 | `godot-architect` | 只读+文档 | 架构设计（仅文档，禁止输出代码） |
| `godot-developer` | 开发 | `godot-best-practices`+`godot-gdscript-patterns`+`tdd` | 全部 | TDD 编码（Red→Green→Refactor） |
| `godot-reviewer` | 质量 | `godot-code-review` | 只读 | 逐文件代码检视 |
| `godot-consistency-checker` | 质量 | `godot-best-practices` | 只读 | 代码↔设计文档一致性检查 |
| `godot-static-analyzer` | 质量 | `godot-static-analysis`+`tdd`+`godot-best-practices` | 读写+bash | 静态分析 + TDD 重构循环 |
| `godot-artifact-reviewer` | 验收 | — | 读写 | 生成物独立检视 |
| `godot-functional-tester` | 质量 | — | bash+写 | 按键模拟+截图功能测试 |
| `godot-notifier` | 验收 | `lark-im` | bash+写 | 经验归档 + 飞书收尾通知 |

**调度关系**：

```
build (主代理)
  ├─ godot-ui-designer         → P1-15S S8 场景搭建
  ├─ godot-architect           → P1-15 架构设计 / P1-15S S2
  ├─ godot-developer           → P1-15S S5-S7 TDD 编码
  ├─ godot-reviewer            → P1-15S S15 代码检视
  ├─ godot-consistency-checker → P1-15S S9/S16 一致性检查
  ├─ godot-static-analyzer     → P1-15S S13 静态分析
  ├─ godot-functional-tester   → P1-15S S12 功能测试
  ├─ godot-artifact-reviewer   → P1-22 生成物检视
  ├─ godot-notifier            → S21 收尾通知
  ├─ explore (内置)            → 快速代码搜索
  └─ general (内置)            → 通用多步骤任务
```

### 1.6 Skill 分工矩阵

| 任务类型 | 必须使用的 Skill | 禁止用于 |
|---------|-----------------|---------|
| GDScript 代码编写 | `godot-best-practices` + `godot-gdscript-patterns` | Scene 搭建、UI 布局 |
| UI 场景设计 | `godot-ui` | 非 UI 逻辑代码 |
| 架构设计 | `godot-architect` | 代码实现（仅输出文档） |
| 非 UI 场景骨架 | `[MCP] godot-mcp_*` | — |
| 代码检视 | `godot-code-review` | — |
| 静态分析 | `godot-static-analysis` | — |
| 精灵图分析 | `sprite-analyzer` | — |

### 1.7 目录结构

```
assets/             (fonts, music, sounds, sprites)
scenes/{模块}/      (.tscn)
scripts/{模块}/     (.gd)
test/unit/{模块}/        (单元测试)
test/integration/{模块}/  (集成测试)
test/functional/{模块}/   (功能测试)
test/functional/screenshots/ (功能测试截图)
addons/
docs/               (按阶段分，见 1.8)
```

同一模块的子目录路径**必须**一致（P2-2）。

### 1.8 文档交付件

| 阶段 | 交付件 | 命名格式 | 路径 |
|------|--------|---------|------|
| 游戏设计 | 游戏设计文档 | `01_游戏设计文档.md` | `docs/01_gdd/` |
| 游戏设计 | 功能需求 | `{序号}_功能需求_{名}.md` | `docs/01_gdd/` |
| 技术分析 | 可行性分析 | `{序号}_技术可行性分析_{主题}.md` | `docs/02_analysis/` |
| 技术分析 | 性能分析 | `{序号}_性能需求分析.md` | `docs/02_analysis/` |
| 架构设计 | 架构概要 | `01_架构概要设计.md` | `docs/03_arch/` |
| 迭代计划 | Backlog | `01_backlog.md` | `docs/04_sprint/` |
| 迭代计划 | Story | `{序号}_{名}.md` | `docs/04_sprint/02_story/` |
| 迭代计划 | Sprint 计划 | `{序号}_Sprint{N}.md` | `docs/04_sprint/03_plan/` |
| 迭代开发 | 模块设计 | `{序号}_模块设计_{名}.md` | `docs/03_arch/` |
| 迭代开发 | 状态机设计 | `{序号}_状态机设计_{名}.md` | `docs/03_arch/` |
| 开发指导 | 开发指导 | `{序号}_{名}_开发指导.md` | `docs/05_guide/` |
| 复盘总结 | 复盘 | `{序号}_{主题}_复盘.md` | `docs/06_postmortem/` |

---

## 二、P0 代码标准（所有任务通用）

### 2.1 编码规范

- **P0-1** SOLID + DRY 原则
- **P0-2** 禁止语法错误
- **P0-3** 代码除注释外**禁止**中文
- **P0-4** 思考和交流**必须**中文
- **P0-5** 思考中**禁止**输出完整代码，仅描述关键决策要点
- **P0-6** `func`、`enum`/枚举值、`signal`、测试方法**必须**用 `##` 中文注释用途，放在上方一行
- **P0-7** 函数参数**禁止**与节点内置属性同名（用 `target_position` 而非 `position`）
- **P0-8** 枚举/变量命名必须精确反映用途，**禁止**包含未使用概念
- **P0-9** 方法间、方法与变量间**必须**两个空行分隔

### 2.2 设计模式

- **P0-10** 复用实例模式：生命周期入口（如 `enter()`）**必须**调用 `_reset()`，子类 override `_reset()` 清理运行时变量

### 2.3 TDD 流程

- **P0-11** 修改 `.gd` **必须** Red→Green→Refactor，**禁止**先实现后补测试。适用于**所有**阶段。每步（Red/Green/Refactor）完成后**必须**运行当前类测试确认结果
- **P0-11.5** **逐类循环**：按依赖排序（最少依赖优先），每次只做一个类的完整 Red→Green→Refactor 循环
- **P0-12** 写测试前**必须**先梳理所有 BDD 验收场景，确保每条 AC 有 ≥1 个测试覆盖；AC 不具体时先与用户澄清

### 2.4 任务钩子

| 时机 | ID | 动作 |
|------|-----|------|
| 任务开始前 | **P0-13** | 读取 `docs/06_postmortem/MEMORY.md`（不存在则跳过） |
| 任务完成后 | **P0-14** | 主代理提炼经验 → 追加到 `MEMORY.md`（**禁止**重复） |
| P0-14 后 | **P0-15** | 主代理 `[Skill: lark-im]` 飞书通知完成状态。凭证缺失则跳过并说明 |
| 代码变更后 | **P0-16** | 测试覆盖率 ≥ 80%（`[MCP] godot-ultimate_godot_get_test_coverage`），初始化阶段豁免。工具不可用时手动统计 |

### 2.5 任务执行

- **P0-17** 子代理调度策略：
  - **默认**：主代理直接执行所有任务，加载对应 Skill 完成工作
  - **使用子代理的条件**（满足任一即可）：
    1. **可并行**：多个任务无依赖关系，并行调度可显著降低总执行时长
    2. **不同模型**：子代理配置了与主代理不同的 model，能提供差异化能力
  - 不满足上述条件时，主代理加载对应 Skill 直接执行，禁止不必要的子代理调度

---

## 三、P1 开发流程

### 3.1 Story 标准流程（P1-15S）

> **必须**严格按 S1→S21 顺序执行，不得跳步或调换，除非用户明确指示。

| 步骤 | 名称 | 代理 | 关键动作 |
|------|------|------|--------|
| S1 | 开发前准备 | 主代理 | 读 `MEMORY.md` → 输出 Story 概要 → **暂停等用户确认** |
| S2 | 设计文档 | `godot-architect` | 输出模块设计 + 状态机设计到 `docs/03_arch/` → **暂停等用户确认** |
| S3 | 开发指导文档 | 主代理 | 输出开发指导文档到 `docs/05_guide/`（命名 `{序号}_{名}_开发指导.md`），包含 BDD 验收场景（Given-When-Then）、实现要点、关键技术决策等 → **暂停等用户确认** |
| S4 | 依赖分析与执行规划 | 主代理 | 将 AC 拆解为 agent_task → 分析任务间依赖关系 → 按依赖最少优先排序 → 输出依赖拓扑图（mermaid DAG）→ 标注可并行任务组（每组**最多 4 个**并行 task）→ **暂停等用户确认** |
| S5 | Red | `godot-developer` | **先输出测试用例表格再写测试代码**：① 对当前类按依赖拓扑顺序逐类输出测试用例表（列：场景分类 | 场景描述 | 是否正常场景 | 输入 | 期望输出 | 测试方法名），**必须**覆盖正常和异常场景 ② 按表格逐个编写测试代码，依赖最少优先；**同一依赖层级内无相互依赖的 task 可并行调度，并行度上限 4**（子代理执行，遵循 P0-17） |
| S6 | Green | `godot-developer` | 同 S5 并行策略，最小实现使测试通过 |
| S7 | Refactor | `godot-developer` | 同 S5 并行策略，优化结构保持测试通过 → 回 S5 直到所有类完成 |
| S8 | 场景搭建 | `godot-ui-designer` | AI 通过 MCP 搭建 .tscn 主体框架（节点树、脚本绑定、属性配置等） → 输出详细操作指导 → **暂停等用户完成**可视化操作（sprite 位置、碰撞形状/位置、动画配置等） |
| S9 | 一致性检查 | `godot-consistency-checker` | 代码↔设计文档 + 场景结构对比 → 有差异**暂停**等用户决定 |
| S10 | AC 覆盖分析 | 主代理 | 逐项对比 AC 与测试，补充缺失测试 |
| S11 | 全量测试 | 主代理 | `godot-ultimate_godot_run_tests` 全部通过 |
| S12 | 功能测试 | `godot-functional-tester` | 按键模拟 + 截图验证端到端行为 |
| S13 | 静态分析 | `godot-static-analyzer` | 质量须达优秀，未达标回 S7 迭代重构（S7→S8→…→S13 循环直到达标） |
| S14 | 诊断检查 | 主代理 | `minimal-godot_get_diagnostics` 无语法错误 |
| S15 | 代码检视 | `godot-reviewer` | 总结开发内容 → 在编辑器中逐个打开文件，说明职责、修改关键点、检视关键点 → **每检视完一个文件后展示检视进度**（示例：`检视进度: [███░░░░] 3/7`，`✓` 已完成、`→` 当前、其余为待检视） → **暂停等用户检视结果** |
| S16 | 设计对比 | `godot-consistency-checker` | 代码↔设计文档差异清单 → 用户确认处理方案 |
| S17 | 场景可视化验收 | 主代理 | 用户完成可视化操作后，AI 验收 .tscn 配置正确性 → 不符预期则指导修正 → **暂停等用户确认** |
| S18 | 经验归档 | 主代理 | 检视 + 静态检查问题 → 追加到 `MEMORY.md` |
| S19 | 更新 Backlog | 主代理 | `docs/04_sprint/01_backlog.md` 标记已完成 |
| S20 | Git 提交 | 主代理 | 工作区干净 + 用户确认 → commit |
| S21 | 收尾通知 | `godot-notifier` | 经验归档 + 飞书通知 |

**约束**：Story 间**必须**暂停等用户确认（P1-2）；每 Story 完成后游戏**必须**可运行且有可玩内容（P1-3）。

### 3.2 Story 管理

- **P1-1** Story 开发前**必须**先输出设计文档 → **暂停等用户确认**
- **P1-2** 以 agent_task 为粒度，无依赖可并行，有依赖串行。Story 间**暂停等确认**
- **P1-3** 编排保证每 Story 完成后游戏可运行且有可玩内容
- **P1-4** 通过 `docs/04_sprint/01_backlog.md` 跟踪状态（待开发 / 进行中 / 已完成）
- **P1-5** 新 Story 前工作区**必须**干净（已 git commit）

### 3.3 测试与验收

- **P1-7** 标记已完成前：全量测试通过 + 逐项验证 AC，两者均通过方可标记
- **P1-7.5** 每 AC **必须**有功能测试（`test/functional/{模块}/`），按键模拟 + 截图验证，一一对应
- **P1-8** 每 Story **必须**有集成测试（`test/integration/{模块}/`）
- **P1-9** 代码开发完成后、检视前：输出 AC 覆盖分析表（AC → 覆盖状态 → 测试方法名），补充缺失测试

### 3.4 检视与一致性

- **P1-6** S15 代码检视：AI 逐文件展示变更摘要，与用户一起检视
- **P1-10** Story 文档**必须** BDD（Given-When-Then），至少一个场景
- **P1-11** Story 标记已完成前：S16 `godot-consistency-checker` 对比代码↔设计文档，差异等用户确认
- **P1-12** 静态分析须达优秀，未达标则循环：`TDD 重构 → 补充测试 → 重新分析` 直到达标
- **P1-13** 检视和静态检查问题 → 经验教训追加到 `MEMORY.md`（**禁止**重复）
- **P1-14** 每个 agent_task 完成后：一致性报告（已实现/未实现/额外/不一致），第 2/3/4 类**暂停**等用户决定：① 补代码对齐设计 ② 更新设计反映代码 ③ 确认偏差并记录

### 3.5 功能开发流程（P1-15）

```
主代理 [Skill: godot-architect]                        (S2 设计文档)
  → 主代理 [Skill: best-practices + gdscript-patterns]  (S5-S7 TDD 编码)
  → 主代理 [Skill: godot-ui] + [MCP] godot-mcp_*        (S8 场景搭建)
  → [MCP] lint + run_tests                              (S11 全量测试)
  → [MCP] minimal-godot_get_diagnostics                 (S14 诊断检查)
```

### 3.6 场景规范

- **P1-16** AI 通过 MCP 搭建骨架 → 输出操作指导 → 用户在编辑器完成最终编排
- **P1-17** 场景搭建后**暂停**，询问用户是否介入，需要则输出指导后再次暂停
- **P1-18** 根节点名 = 文件名（PascalCase），**禁止** `root`（如 `player.tscn` → `Player`）
- **P1-19** 重复节点组合**必须**抽象为可复用子场景，实例化引用（DRY）
- **P1-20** `.gd` **必须**定义 `class_name`（Autoload 除外），通过 `class_name` 引用类型，**禁止**用 preload 变量作类型别名

### 3.7 Skill 与职责

- **P1-23** Skill 映射见 [1.6 Skill 分工矩阵]
- **P1-24** `.gd` 与 `.tscn` 是独立职责，**禁止**混合处理
- **P1-25** 主代理执行 TDD 编码时**必须**同时加载 `godot-best-practices` + `godot-gdscript-patterns`

### 3.8 其他

- **P1-21** 精灵图分析结果**必须**保存到 `docs/02_analysis/`（`{序号}_资源分析_{名}.md`），后续引用文档禁止重复分析
- **P1-22** 生成物**必须**经独立检视（文档：命名/目录/标题/mermaid/关联；代码：语法/SOLID·DRY/诊断）。可并行时调度 `[Agent] artifact-reviewer`

---

## 四、P2 操作规范

### 4.1 目录

- **P2-1** 严禁在规定目录外存放资产/脚本/测试
- **P2-2** 同一模块子目录路径**必须**一致（见 1.7）

### 4.2 文档

- **P2-3** 交付件清单见 [1.8 文档交付件]
- **P2-4** 文件名：`{两位序号}_{中文名称}.md`，序号从 01 递增
- **P2-5** **必须**放在对应阶段目录，禁止 `docs/` 根目录
- **P2-6** `{xxx}` 为模板变量，固定文档不加后缀
- **P2-7** 架构/流程/状态**必须**用 mermaid 绘图
- **P2-8** 文档须：结构化标题（不跳级）、可追溯、图表优先、具体可执行、自包含
- **P2-9** 输出前自检：命名 ✓ 目录 ✓ 标题 ✓ mermaid ✓ 上游关联 ✓
- **P2-9.5** 设计文档**禁止**包含完整实现代码，**仅**定义：类名、方法签名（参数+返回值）、signal 签名、类间调用关系、职责描述。伪代码仅用于说明复杂算法逻辑

### 4.3 Git 提交

- **P2-10** 提交 .gd 前检查链（每步通过后再执行下一步）：重载项目 → `get_diagnostics` → 运行测试 → `check_patterns`
- **P2-11** 修改 `.gd`/`project.godot` 后**必须**重载项目刷新 .uid/LSP/索引（确保单实例运行）
- **P2-12** 用户确认后 commit
- **P2-13** 修改测试**必须**用 `[Skill] godot-best-practices`
- **P2-14** .uid **必须**提交（.tscn 除外）
- **P2-15** 缺 .uid 时提醒用户生成

### 4.4 Godot 编辑器

- **P2-16** 测试命令：`$GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit`
- **P2-17** 编辑器管理：
  - **单实例**：同时只允许 1 个（检测：`Get-Process "Godot*"` / 关闭：`Stop-Process "Godot*" -Force`）
  - **启动策略**：需要编辑器时先检测是否已运行（`Get-Process "Godot*"`），已运行则直接使用，未运行则异步启动（`Start-Process`），**不阻塞等待**
  - **启动超时**：启动后最多轮询等待 **30 秒**（每 5 秒检测一次进程），超时仍未检测到进程则**放弃启动**，继续任务并提示用户手动启动
  - **LSP 降级**：编辑器不可用时跳过 `get_diagnostics`，改用 `scan_workspace_diagnostics`（不依赖 LSP），并在最终报告中标注"编辑器未启动，诊断可能不完整"
  - **启动优先级**：`[MCP] godot-mcp_launch_editor` > `Start-Process $env:GODOT_HOME --path <项目>`
  - **无头模式**：`& $env:GODOT_HOME --editor --path <项目>`（仅加载索引）

### 4.5 Godot 技术约束

- **P2-18** `Resource`/`RefCounted` **禁止** `.free()`；`Node` **必须** `.free()`/`queue_free()`
- **P2-19** 新增/移动含 `class_name` 的 `.gd` 后**必须**重载项目刷新缓存；`.godot/` 目录**禁止**手动操作，刷新通过编辑器重载
- **P2-20** .tscn 手写规则：骨架可手写；视觉资源（SpriteFrames/TileSet/材质）**必须**编辑器创建；子场景根路径用 `"."`
- **P2-21** 状态模式选型：状态基类用 `Resource`，状态机管理器用 `Node`
- **P2-28** 碰撞层/掩码**禁止**代码硬编码，**必须**在 .tscn 属性配置；代码仅允许读取

### 4.6 测试技术

- **P2-22** GUT 单元测试：`load()` + `.new()` 测试纯逻辑；`@onready` 需手动赋值；`move_and_slide()` 等物理方法**禁止**在 `.new()` 模式调用，**应使用**集成测试；`AnimatedSprite2D.new()` 需预注册动画名；`-gdir` 不递归需显式指定目录
- **P2-23** 分层：单元 = 纯逻辑；集成 = 场景树依赖（动画/碰撞/输入）
- **P2-24** 功能测试：继承 `SceneTree`，`Input.parse_input_event()` 模拟，`get_viewport().get_texture().get_image()` 截图
- **P2-25** 存放：`test/functional/{模块}/test_{名}_functional.gd`，截图 `test/functional/screenshots/`
- **P2-26** 功能测试**必须**在 S11 后执行；失败则主代理修复，从 S11 重跑
- **P2-27** LSP 需 GUI 模式编辑器，`get_diagnostics` 前确认编辑器已启动

---

## 五、严重违规清单

| # | 违规 | 纠正 |
|---|------|------|
| 1 | Singleton 文件含 `class_name` | **停止 → 回滚 → 重新执行** |
| 2 | 代码含中文（除注释） | |
| 3 | 未通过 `[MCP] minimal-godot_get_diagnostics` | |
| 4 | 违反目录结构 | |
| 5 | 未提交 .uid 文件 | |

---

## 附录

- **A-1** AGENTS.md 不重复本文件内容
- **A-2** 规则以本文件为准，AGENTS.md 禁止重复定义
