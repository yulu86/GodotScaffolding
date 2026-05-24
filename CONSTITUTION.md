# 项目宪法

> 本文档为项目最高优先级指令，不可协商、不可绕过。

## 适用规则

- **每次执行用户任务前**，必须识别当前任务所处的开发阶段（见"开发阶段"），遵守对应阶段的规则
- 本文档所有规则在所有阶段都**必须遵守**

## 术语定义

| 术语 | 含义 | 示例 |
|------|------|------|
| 用户任务 | 用户发出的一次完整请求，从接收到最终交付 | "实现玩家移动功能"、"修复 #3 bug" |
| Story | Sprint 中的一个用户故事，包含多个 agent_task | "Story 01: 玩家基础移动" |
| agent_task | Story 内的一个 subagent 执行单元 | `task(subagent_type="general", ...)` |
| 任务完成 | 所有代码已写入、测试通过、lint 通过、用户已确认 | — |

## 开发阶段

| 阶段 | 触发条件 | 主要活动 |
|------|---------|---------|
| 初始化 | 项目首次创建 | 目录搭建、工具配置 |
| 游戏设计 | 收到游戏概念需求 | GDD、功能需求文档 |
| 技术分析 | 设计文档就绪 | 可行性分析、性能分析 |
| 架构设计 | 技术分析通过 | 架构概要、模块设计、状态机设计 |
| 迭代开发 | 架构设计完成，Backlog 就绪 | Story 拆分、编码、测试 |
| 交付 | 所有 Story 完成 | 复盘、文档归档 |

## 环境变量索引

| 变量名 | 用途 | 来源 |
|--------|------|------|
| `GODOT_HOME` | Godot 编辑器可执行文件路径 | 操作系统环境变量 |
| `FEISHU_APP_ID` | 飞书应用 ID | [.env](.env) |
| `FEISHU_APP_SECRET` | 飞书应用 Secret | [.env](.env) |
| `FEISHU_USER_ID` | 用户 open_id（`ou_` 开头） | [.env](.env) |

> 若 `.env` 不存在或变量缺失，**必须**先提醒用户配置，再继续执行依赖该变量的规则。

## 工具来源标注

| 标注 | 含义 | 示例 |
|------|------|------|
| `[MCP]` | Godot MCP 工具 | `minimal-godot_get_diagnostics`、`godot-ultimate_godot_lint_file` |
| `[Skill]` | OpenCode Skill，通过 `skill` 工具加载 | `sprite-analyzer`、`lark-im` |
| `[CLI]` | 命令行命令，通过 Bash 工具执行 | `$GODOT_HOME -s addons/gut/gut_cmdln.gd` |

---

# 核心原则

## P0 - 核心原则（适用于所有用户任务）

### 代码规范

- **P0-1** 代码必须满足 SOLID + DRY 原则
- **P0-2** 禁止语法错误
- **P0-3** 代码除注释外**禁止**使用中文
- **P0-4** 思考过程和交流**必须**使用中文
- **P0-4a** 思考过程中**禁止**输出完整代码，仅描述关键思路和决策要点，以降低 token 消耗
- **P0-4b** 功能代码和测试代码**必须**使用中文添加注释说明其用途：方法（`func`）、枚举（`enum`）及其枚举值、信号（`signal`）、测试方法。注释使用 `##` 格式，放置在被注释元素的上方一行
- **P0-4c** 函数参数命名**禁止**与节点内置属性同名（如 `name`、`position`、`scale`），应使用更具描述性的名称（如 `device_name`、`target_position`）
- **P0-4d** 复用实例模式中，生命周期入口方法（如状态机的 `enter()`）**必须**调用 `_reset()` 抽象方法，子类 override `_reset()` 清理运行时变量
- **P0-4e** 枚举和变量命名必须精确反映实际用途，**禁止**包含未使用的概念

### 任务生命周期钩子（按执行顺序）

> 以下规则按编号顺序执行，不可跳步。

- **P0-5** 【触发时机：用户任务开始前】**必须**从 `docs/06_postmortem/MEMORY.md` 读取经验教训，避免重犯。文件不存在时跳过
- **P0-6** 【触发时机：用户任务完成后】**必须**事后总结经验教训，保存到 `docs/06_postmortem/MEMORY.md`（**禁止**输出重复的经验）。刷新 MEMORY.md 时**必须**使用 `[Skill] summarize` 对当前对话进行摘要提炼
- **P0-7** 【触发时机：P0-6 完成后】**必须**使用 `[Skill] lark-im` 通过飞书通知用户任务完成状态（包含任务名称、完成结果、关键变更摘要）。凭证从环境变量 `FEISHU_APP_ID` 和 `FEISHU_APP_SECRET` 获取。若凭证缺失，跳过通知并在回复中说明
  ```bash
  # 发送飞书通知命令
  lark-cli im +messages-send --user-id "$FEISHU_USER_ID" --text "<消息内容>" --as bot
  ```
- **P0-8** 【触发时机：每次代码变更后】测试覆盖率**不得低于** 80%，通过 `[MCP] godot-ultimate_godot_get_test_coverage` 验证。初始化阶段（无测试文件时）豁免

## P1 - 跨阶段规范

### Story 执行粒度

- **P1-0** 【触发时机：每个 Story 开发前】**必须**先输出该 Story 的概要（包含 Story 名称、开发目标、涉及文件/模块、关键实现要点、预估工作量），然后**暂停执行**，等待用户确认后方可开始该 Story 的开发
- **P1-1** 每个 Story 以单个 agent_task 为粒度拆分开发。无依赖的 agent_task 可并行执行，有依赖的 agent_task **必须**串行执行。每个 Story 完成后**必须**暂停执行，等待用户确认后再继续下一个 Story
- **P1-2** 每次开发的最小维度为 Story。**必须**通过 `docs/04_sprint/01_backlog.md` 跟踪每个 Story 的开发状态（待开发 / 进行中 / 已完成），状态变更时同步更新 backlog
- **P1-3** 【触发时机：Story 代码编写完成，测试通过前】AI 和用户**必须**一起检视代码。AI 先逐文件展示变更摘要（文件路径、变更内容、设计意图），用户逐项确认或提出修改意见，双方达成一致后方可继续
- **P1-4** 进入下一个 Story 开发前，**必须**确保当前所有代码已提交到 Git（工作区干净），否则禁止开始新 Story
- **P1-5** Story 开发顺序**必须**按迭代开发方式编排：每个 Story 完成后，游戏都**必须**可运行且包含可游玩的内容。禁止出现某个 Story 完成后游戏无法启动或无可玩内容的编排
- **P1-6** 【触发时机：Story 代码检视通过后，标记为已完成前】**必须**运行全部测试用例（`[MCP] godot-ultimate_godot_run_tests`）并确保全部通过；**必须**逐项验证满足该 Story 中定义的所有验收标准（Acceptance Criteria），两者均通过后方可将该 Story 标记为已完成
- **P1-6a** 【触发时机：Story 标记为已完成前】**必须**创建子 agent（`task(subagent_type="general")`）逐项对比代码实现与该 Story 关联的设计文档（模块设计、状态机设计、功能需求等），输出差异清单。差异包括：设计文档中定义但代码未实现的功能、代码中存在但设计文档未描述的功能、实现方式与设计文档描述不一致的部分。所有差异**必须**与用户确认处理方案后方可标记 Story 为已完成

- **P1-6b** Story 文档**必须**使用 BDD（行为驱动开发）方法编写，采用 Given-When-Then 格式描述行为场景。每个 Story 必须包含至少一个行为场景作为验收标准
- **P1-6c** 每个 Story 开发**必须**编写对应的集成测试用例，存放在 `test/integration/{模块}/` 目录下，无集成测试的 Story 不得标记为已完成

### 功能开发全流程

- **P1-7** 代码开发**必须**使用 TDD（测试驱动开发）方式：先编写失败测试（Red） → 编写最小实现使测试通过（Green） → 重构代码（Refactor）。**禁止**先写实现代码再补测试。功能开发流程：
  ```
  task(subagent_type="general") (使用 [Skill] godot-ui 指导 UI 设计)
    → task(subagent_type="general") (使用 [Skill] godot-architect 架构设计)
    → [MCP] godot-mcp：AI 使用 MCP 工具创建场景基本框架
    → task(subagent_type="general") (使用 [Skill] godot-best-practices + godot-gdscript-patterns 实现)
    → [MCP] godot-ultimate_godot_lint_file / run_tests (验证)
    → [MCP] minimal-godot_get_diagnostics (最终诊断)
  ```

### 场景搭建分工

- **P1-8** Scene 由 AI 通过 MCP 工具搭建骨架（节点树结构、脚本挂载），完成后输出详细操作指导文档（节点属性、动画编排、布局参数等），由用户在 Godot 编辑器中手动完成最终编排
- **P1-9** 场景搭建后**必须**暂停执行，询问用户是否需要介入 Scene 编排。若用户确认需要，输出详细操作指导后再次暂停，等待用户操作完成并确认后，方可继续后续流程
- **P1-10** 场景的根节点名称**必须**与场景文件名保持关联（PascalCase 形式），**禁止**使用默认的 `root`。例如场景文件 `player.tscn` 的根节点名称应为 `Player`
- **P1-11** 跨场景或单场景中重复使用的节点组合，**必须**按需抽象为独立的可复用子场景（`.tscn`），通过实例化引用而非复制粘贴，以遵循 DRY 原则
- **P1-12** GDScript 文件**必须**定义 `class_name`（Autoload/Singleton 除外），并通过 `class_name` 进行类型引用，**禁止**使用 `preload`/`load` 后的变量名作为类型别名

### 资源分析文档化

- **P1-13** 使用 `[Skill] sprite-analyzer` 分析游戏图片资源后，**必须**将分析结果以文档形式保存到 `docs/02_analysis/` 目录（命名格式：`{序号}_资源分析_{资源名}.md`），后续开发中**必须**直接引用该文档，禁止重复分析同一资源

### 生成物检视

- **P1-14** 所有文档和代码生成后，**必须**创建新的子 agent（`task(subagent_type="general")`）对生成物进行独立检视，并针对检视发现的问题进行修改修正。检视内容包括但不限于：
  - 文档：命名规范、目录位置、标题层级、mermaid 图形正确性、上游关联完整性
  - 代码：语法正确性、SOLID/DRY 合规、目录规范、`[MCP] minimal-godot_get_diagnostics` 诊断通过

## P2 - 操作流程

### 目录结构

```
assets/ (fonts, music, sounds, sprites)
scenes/ (.tscn，按模块分)
scripts/ (.gd，按模块分)
test/unit/ (单元测试)
test/integration/ (集成测试)
addons/
docs/ (设计文档，按阶段分)
```

- **P2-1** 严禁在目录外存放资产/脚本/测试
- **P2-2** 场景、脚本、测试按模块分目录，且同一模块的子目录相对路径**必须**保持一致。例如模块 `player` 的文件分别存放于 `scenes/player/`、`scripts/player/`、`test/unit/player/`、`test/integration/player/`

### 文档交付件规则

- **P2-3** 每个阶段完成后**必须**输出对应的设计文档，交付件清单如下：

| 阶段 | 交付件 | 命名格式 | 存档路径 |
|------|--------|---------|---------|
| 游戏设计 | 游戏设计文档 | `01_游戏设计文档.md` | `docs/01_gdd/` |
| 游戏设计 | 功能需求文档 | `{序号}_功能需求_{功能名}.md` | `docs/01_gdd/` |
| 技术分析 | 技术可行性分析 | `{序号}_技术可行性分析_{主题}.md` | `docs/02_analysis/` |
| 技术分析 | 性能需求分析 | `{序号}_性能需求分析.md` | `docs/02_analysis/` |
| 架构设计 | 架构概要设计 | `01_架构概要设计.md` | `docs/03_arch/` |
| 架构设计 | 模块设计 | `{序号}_模块设计_{模块名}.md` | `docs/03_arch/` |
| 架构设计 | 状态机设计 | `{序号}_状态机设计_{名称}.md` | `docs/03_arch/` |
| 迭代计划 | Backlog | `01_backlog.md` | `docs/04_sprint/` |
| 迭代计划 | Story | `{序号}_{Story名称}.md` | `docs/04_sprint/02_story/` |
| 迭代计划 | Sprint 计划 | `{序号}_Sprint{编号}.md` | `docs/04_sprint/03_plan/` |
| 开发指导 | 功能开发指导 | `{序号}_{功能名}_开发指导.md` | `docs/05_guide/` |
| 复盘总结 | 复盘文档 | `{序号}_{主题}_复盘.md` | `docs/06_postmortem/` |

- **P2-4** 文档文件名格式：`{两位序号}_{中文名称}.md`，序号从 01 递增
- **P2-5** 文档必须放在对应阶段目录中，禁止在 `docs/` 根目录直接放文件
- **P2-6** `{xxx}` 为模板变量，使用时替换为实际内容；固定文档（如 `01_游戏设计文档.md`）不加后缀
- **P2-7** 架构设计文档使用 mermaid 绘制图形

- **P2-8** 文档内容规则：
  - **结构化**：每个文档必须包含明确的标题层级（`#` → `##` → `###`），禁止跳级
  - **可追溯**：架构设计文档必须关联对应的功能需求文档（引用文档名或路径）
  - **图表优先**：涉及流程、架构、状态转换时**必须**使用 mermaid 绘制图形，禁止仅用文字描述
  - **具体可执行**：开发指导文档必须包含可直接执行的步骤，禁止模糊表述（如"适当优化"）
  - **自包含**：每个文档必须独立可读，包含必要的背景上下文，不依赖外部口头说明

- **P2-9** 文档输出前必须自检：
  - [ ] 文件名是否符合命名格式
  - [ ] 是否存放在正确阶段目录
  - [ ] 标题层级是否完整无跳级
  - [ ] mermaid 图形是否渲染正确（涉及流程/架构/状态时）
  - [ ] 是否关联了上游需求文档（架构设计、开发指导类）

### Git 提交

- **P2-10** 提交 .gd 后检查（每步通过后再执行下一步）：
  ```
  [MCP] minimal-godot_get_diagnostics (语法检查)
    → [CLI] $GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit (运行测试)
    → [MCP] godot-ultimate_godot_check_patterns (模式检查)
  ```
- **P2-11** 与用户确认后再执行 git commit
- **P2-12** 修改测试必须使用 `[Skill] godot-best-practices`
- **P2-13** .uid 文件必须提交（.tscn 除外）
- **P2-14** 缺少 .uid 时提醒用户生成
- **P2-15** 编写 `.gd` 代码或修改 `godot.project` 文件后，**必须**先关闭所有正在运行的 Godot 编辑器实例，然后通过 `[MCP] godot-mcp_launch_editor` 重新加载当前项目，以便 Godot 自动生成 `.uid` 文件、刷新 LSP 缓存和索引、并检查配置是否能正常加载

### 命令行

- **P2-16** 使用 `$GODOT_HOME` 环境变量：`$GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit`

## 严重违规清单

1. Singleton 文件包含 `class_name`
2. 代码含中文（除注释）
3. 未通过 `[MCP] minimal-godot_get_diagnostics` 检查
4. 违反目录结构
5. 未提交 .uid 文件

**纠正：停止 → 回滚 → 重新执行**

## 附录

- **A-1** AGENTS.md 不重复 CONTRIBUTING.md 内容
- **A-2** AGENTS.md 中引用的 CONSTITUTION.md 规则以本文件为准，禁止在 AGENTS.md 中重复定义
