# 项目宪法

> 最高优先级指令，不可协商、不可绕过。所有规则在所有阶段都必须遵守。每次执行用户任务前须识别当前开发阶段。

## 术语

| 术语 | 含义 |
|------|------|
| 用户任务 | 用户发出的一次完整请求，从接收到最终交付 |
| Story | Sprint 中的用户故事，包含多个 agent_task |
| agent_task | Story 内的 subagent 执行单元（`task(subagent_type="general")`）|
| 任务完成 | 代码写入 + 测试通过 + lint 通过 + 用户确认 |

## 开发阶段

初始化 → 游戏设计（GDD/功能需求）→ 技术分析（可行性/性能）→ 架构设计（概要/模块/状态机）→ 迭代开发（Story/编码/测试）→ 交付（复盘/归档）

## 环境变量

| 变量 | 用途 | 来源 |
|------|------|------|
| `GODOT_HOME` | Godot 编辑器路径 | OS 环境变量 |
| `FEISHU_APP_ID` / `FEISHU_APP_SECRET` / `FEISHU_USER_ID` | 飞书应用凭证 | .env |

> .env 不存在或变量缺失时，先提醒用户配置。

## 工具标注

| 标注 | 含义 | 示例 |
|------|------|------|
| `[MCP]` | Godot MCP 工具 | `minimal-godot_get_diagnostics` |
| `[Skill]` | OpenCode Skill | `sprite-analyzer`、`lark-im` |
| `[CLI]` | 命令行（Bash） | `$GODOT_HOME -s addons/gut/gut_cmdln.gd` |

---

# P0 — 核心原则

## 代码规范

| ID | 规则 |
|----|------|
| P0-1 | SOLID + DRY |
| P0-2 | 禁止语法错误 |
| P0-3 | 代码除注释外禁止中文；思考和交流使用中文 |
| P0-4a | 思考过程禁止输出完整代码，仅描述关键思路和决策要点 |
| P0-4b | func/enum/enum值/signal/测试方法用 `##` 中文注释说明用途，放在元素上方一行 |
| P0-4c | 函数参数禁止与节点内置属性同名（用 `target_position` 而非 `position`）|
| P0-4d | 复用实例模式的 `enter()` 必须调用 `_reset()`，子类 override `_reset()` 清理运行时变量 |
| P0-4e | 枚举/变量命名精确反映用途，禁止包含未使用概念 |
| P0-4f | 任何阶段对 .gd 的修改必须 TDD：Red → Green → Refactor。禁止先写实现再补测试 |

## 任务生命周期（按序执行，不可跳步）

| ID | 时机 | 规则 |
|----|------|------|
| P0-5 | 任务开始前 | 读取 `docs/06_postmortem/MEMORY.md`（不存在则跳过）|
| P0-6 | 任务完成后 | 总结经验教训到 MEMORY.md（禁止重复），用 `[Skill] summarize` 提炼 |
| P0-7 | P0-6 后 | `[Skill] lark-im` 飞书通知完成状态；凭证缺失则跳过并说明 |
| P0-8 | 每次代码变更后 | 测试覆盖率 ≥ 80%（`[MCP] godot-ultimate_godot_get_test_coverage`），初始化阶段豁免 |

---

# P1 — 跨阶段规范

## Story 管理

| ID | 时机 | 规则 |
|----|------|------|
| P1-0 | Story 开发前 | 输出概要（名称/目标/文件/要点/工作量），暂停等用户确认 |
| P1-1 | Story 执行中 | 以 agent_task 粒度拆分，无依赖并行、有依赖串行；完成后暂停等确认 |
| P1-2 | Story 跟踪 | `docs/04_sprint/01_backlog.md` 跟踪状态（待开发/进行中/已完成）|
| P1-3 | 代码编写完成后 | AI 逐文件展示变更摘要，用户逐项确认 |
| P1-4 | 进入下个 Story 前 | 当前代码必须已 Git 提交（工作区干净）|
| P1-5 | Story 编排 | 每个 Story 完成后游戏必须可运行且可游玩 |
| P1-6 | 检视通过后 | 运行全部测试 + 逐项验证验收标准，均通过后标记已完成 |
| P1-6a | Story 完成前 | 子 agent 对比代码与设计文档输出差异清单，用户确认处理方案 |
| P1-6b | Story 文档 | BDD Given-When-Then 格式，至少一个行为场景 |
| P1-6c | Story 测试 | 必须编写集成测试 `test/integration/{模块}/` |
| P1-6d | 代码完成后 | 对比验收标准与测试用例输出覆盖分析表，未覆盖则补充 |
| P1-6e | Story 完成前 | `[Skill] godot-static-analysis` 达"优秀"；未达标则 TDD 重构循环 |
| P1-6f | agent_task 完成后 | 子 agent 对比代码与设计文档输出一致性报告，差异暂停由用户决定 |
| P1-6g | 检视+静态检查后 | 发现的问题总结为经验教训追加到 MEMORY.md（场景+教训+规则，禁止重复）|

## 功能开发流程

TDD + 开发管线：
```
[Skill] godot-ui → [Skill] godot-architect → [MCP] 场景骨架
→ [Skill] godot-best-practices + godot-gdscript-patterns
→ [MCP] lint / run_tests → [MCP] diagnostics
```

## 场景搭建

| ID | 规则 |
|----|------|
| P1-8 | AI 通过 MCP 搭建骨架，输出操作指导由用户在编辑器编排 |
| P1-9 | 场景搭建后暂停，询问用户是否介入 |
| P1-10 | 根节点名称与文件名关联（PascalCase），禁止用 `root` |
| P1-11 | 重复节点组合抽象为子场景（.tscn），实例化引用 |
| P1-12 | .gd 必须定义 `class_name`（Autoload 除外），通过 class_name 类型引用，禁止 preload/load 变量作类型别名 |

## 资源与生成物

| ID | 规则 |
|----|------|
| P1-13 | sprite-analyzer 结果保存 `docs/02_analysis/{序号}_资源分析_{名}.md`，禁止重复分析 |
| P1-14 | 文档和代码生成后，子 agent 独立检视（命名/目录/标题/mermaid/语法/SOLID/DRY/diagnostics）|

---

# P2 — 操作流程

## 目录结构

```
assets/ scenes/{模块}/ scripts/{模块}/ test/unit/{模块}/ test/integration/{模块}/ addons/ docs/
```

- **P2-1**: 严禁目录外存放资产/脚本/测试
- **P2-2**: 同一模块的 scenes/scripts/test 子目录路径保持一致

## 文档交付件

文件名格式：`{两位序号}_{中文名称}.md`，放在对应阶段目录（禁止放 docs/ 根目录）。

| 阶段 | 交付件 | 路径 |
|------|--------|------|
| 游戏设计 | `01_游戏设计文档.md` / `{序号}_功能需求_{名}.md` | `docs/01_gdd/` |
| 技术分析 | `{序号}_技术可行性分析_{主题}.md` / `性能需求分析.md` | `docs/02_analysis/` |
| 架构设计 | `01_架构概要设计.md` / `{序号}_模块设计_{名}.md` / `{序号}_状态机设计_{名}.md` | `docs/03_arch/` |
| 迭代计划 | `01_backlog.md` / `{序号}_{Story名}.md` / `{序号}_Sprint{N}.md` | `docs/04_sprint/` |
| 开发指导 | `{序号}_{功能名}_开发指导.md` | `docs/05_guide/` |
| 复盘总结 | `{序号}_{主题}_复盘.md` | `docs/06_postmortem/` |

文档内容：结构化标题（禁止跳级）| 可追溯（关联上游需求）| 流程/架构/状态用 mermaid | 具体可执行 | 自包含

## Git 提交

- **P2-10** 提交 .gd 前检查（每步通过后再执行下一步）：
  ```
  [MCP] 重载项目（刷新 .uid/LSP/索引）→ [MCP] diagnostics → [CLI] 测试 → [MCP] check_patterns
  ```
- **P2-11**: 确认后 commit | **P2-12**: 改测试用 `[Skill] godot-best-practices`
- **P2-13**: .uid 必须提交（.tscn 除外）| **P2-14**: 缺 .uid 提醒生成
- **P2-15**: 编写 .gd 或修改 project.godot 后，重载项目刷新 .uid/LSP/索引（确保仅 1 个编辑器实例）

## Godot 开发经验

| ID | 规则 |
|----|------|
| P2-18 | Resource/RefCounted 禁止 .free()；Node 必须 .free()/queue_free() |
| P2-19 | 移动 class_name 脚本后更新 `global_script_class_cache.cfg` + 重载项目 |
| P2-20 | .tscn 骨架可手写（节点树+脚本+碰撞+信号）；视觉资源（SpriteFrames/TileSet/材质）必须在编辑器创建；子场景根节点路径用 `"."` |
| P2-21 | 状态基类用 Resource，状态机管理器用 Node |
| P2-22 | GUT：`script.new()` 不执行 @onready 需手动赋值；`move_and_slide()` 需场景树禁止纯 new 调用；AnimatedSprite2D 需预注册动画名；`-gdir` 不递归需显式指定 |
| P2-23 | 单元测试=纯逻辑；集成测试=场景树依赖行为（动画/物理/输入）|
| P2-24 | LSP 需 GUI 模式编辑器运行，不可用则先启动编辑器 |

## 命令行

- 测试：`$GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit`
- 关闭编辑器：`pkill -f "Godot"`
- 打开编辑器：`[MCP] godot-mcp_launch_editor` > `$GODOT_HOME --path <项目>`
- 无头模式：`$GODOT_HOME --editor --path <项目>`

---

## 严重违规

1. Singleton 含 `class_name`  2. 代码中文（注释外） 3. diagnostics 未通过  4. 目录违规  5. .uid 未提交

**纠正：停止 → 回滚 → 重新执行**

## 附录

- **A-1**: AGENTS.md 不重复 CONTRIBUTING 内容
- **A-2**: 规则以本文件为准，禁止 AGENTS.md 重复定义
