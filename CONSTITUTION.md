# 项目宪法

> 本文档为项目最高优先级指令，不可协商、不可绕过。

## 项目概述

### 适用规则

- **每次执行用户任务前**，必须识别当前任务所处的开发阶段（见"开发阶段"），遵守对应阶段的规则
- 本文档所有规则在所有阶段都**必须遵守**

### 术语定义

| 术语 | 含义 | 示例 |
|------|------|------|
| 用户任务 | 用户发出的一次完整请求，从接收到最终交付 | "实现玩家移动功能"、"修复 #3 bug" |
| Story | Sprint 中的一个用户故事，包含多个 agent_task | "Story 01: 玩家基础移动" |
| agent_task | Story 内的一个子代理执行单元 | `@godot-developer`、`@godot-reviewer` |
| 功能测试 | 通过按键模拟和截图验证，对游戏进行端到端验证的测试 | 模拟按住方向键验证玩家移动 |
| 任务完成 | 所有代码已写入、测试通过、lint 通过、用户已确认 | — |

### 开发阶段

| 阶段 | 触发条件 | 主要活动 |
|------|---------|---------|
| 初始化 | 项目首次创建 | 目录搭建、工具配置 |
| 游戏设计 | 收到游戏概念需求 | GDD、功能需求文档 |
| 技术分析 | 设计文档就绪 | 可行性分析、性能分析 |
| 架构设计 | 技术分析通过 | 架构概要、模块设计、状态机设计 |
| 迭代开发 | 架构设计完成，Backlog 就绪 | Story 拆分、编码、测试 |
| 交付 | 所有 Story 完成 | 复盘、文档归档 |

### 环境变量索引

| 变量名 | 用途 | 来源 |
|--------|------|------|
| `GODOT_HOME` | Godot 编辑器可执行文件路径 | 操作系统环境变量 |
| `FEISHU_APP_ID` | 飞书应用 ID | [.env](.env) |
| `FEISHU_APP_SECRET` | 飞书应用 Secret | [.env](.env) |
| `FEISHU_USER_ID` | 用户 open_id（`ou_` 开头） | [.env](.env) |

> 若 `.env` 不存在或变量缺失，**必须**先提醒用户配置，再继续执行依赖该变量的规则。

### 工具来源标注

| 标注 | 含义 | 示例 |
|------|------|------|
| `[MCP]` | Godot MCP 工具 | `minimal-godot_get_diagnostics`、`godot-ultimate_godot_lint_file` |
| `[Skill]` | OpenCode Skill，通过 `skill` 工具加载 | `sprite-analyzer`、`lark-im` |
| `[Agent]` | OpenCode 子代理，通过 `task()` 或 `@` 调用 | `@godot-developer`、`@godot-reviewer` |
| `[CLI]` | 命令行命令，通过 Bash 工具执行 | `$GODOT_HOME -s addons/gut/gut_cmdln.gd` |

### 子代理清单

> 子代理配置文件位于 `.opencode/agents/`，均为 `hidden: true`，仅通过主代理 `task()` 调度调用。

| # | 名称 | 分类 | 使用的 Skill | 工具权限 | 职责 |
|---|------|------|-------------|---------|------|
| 1 | `godot-ui-designer` | 核心开发 | `godot-ui` | 只读 + 文档写入 | Godot UI 场景设计（Control 节点、布局、样式） |
| 2 | `godot-architect` | 核心开发 | `godot-architect` | 只读 + 文档写入 | 系统架构设计、模块划分、状态机设计 |
| 3 | `godot-developer` | 核心开发 | `godot-best-practices`、`godot-gdscript-patterns`、`test-driven-development` | 全部工具 | TDD 编码实现（Red→Green→Refactor） |
| 4 | `godot-reviewer` | 质量保障 | `godot-code-review` | 只读 | 逐文件代码检视，输出变更摘要和审查意见 |
| 5 | `godot-consistency-checker` | 质量保障 | `godot-best-practices` | 只读 | 对比代码与设计文档，输出一致性报告和差异清单 |
| 6 | `godot-static-analyzer` | 质量保障 | `godot-static-analysis`、`test-driven-development`、`godot-best-practices` | 读写 + bash | 静态分析 + TDD 迭代重构直至质量达标 |
| 7 | `godot-artifact-reviewer` | 文档验收 | — | 读写 | 对文档/代码生成物进行独立检视并修正 |
| 8 | `godot-functional-tester` | 质量保障 | — | bash + 写入 | 通过按键模拟和截图验证，执行端到端功能测试 |

#### 子代理调度关系

```
build (主代理，zhipuai-coding-plan/glm-5.1)
  ├─ [Agent] godot-ui-designer       → P1-15 UI 设计环节
  ├─ [Agent] godot-architect         → P1-15 架构设计环节
  ├─ [Agent] godot-developer         → P1-15S S3-S5 TDD 编码
  ├─ [Agent] godot-reviewer          → P1-15S S11 代码检视
  ├─ [Agent] godot-consistency-checker → P1-15S S6/S12 一致性检查
  ├─ [Agent] godot-static-analyzer   → P1-15S S9 静态分析
  ├─ [Agent] godot-functional-tester → P1-15S S8.5 功能测试
  ├─ [Agent] godot-artifact-reviewer → P1-22 生成物检视
  ├─ explore (内置)                  → 快速代码搜索
  └─ general (内置)                  → 通用多步骤任务
```

---

# 核心原则

## P0 - 核心原则（适用于所有用户任务）

### 代码规范

#### 通用原则

- **P0-1** 代码必须满足 SOLID + DRY 原则
- **P0-2** 禁止语法错误

#### 语言与注释

- **P0-3** 代码除注释外**禁止**使用中文
- **P0-4** 思考过程和交流**必须**使用中文
- **P0-5** 思考过程中**禁止**输出完整代码，仅描述关键思路和决策要点，以降低 token 消耗
- **P0-6** 功能代码和测试代码**必须**使用中文添加注释说明其用途：方法（`func`）、枚举（`enum`）及其枚举值、信号（`signal`）、测试方法。注释使用 `##` 格式，放置在被注释元素的上方一行

#### 命名规范

- **P0-7** 函数参数命名**禁止**与节点内置属性同名（如 `name`、`position`、`scale`），应使用更具描述性的名称（如 `device_name`、`target_position`）
- **P0-8** 枚举和变量命名必须精确反映实际用途，**禁止**包含未使用的概念

#### 代码格式

- **P0-9** GDScript 代码中，方法之间、方法与变量之间**必须**使用两个空行分隔，以提升代码可读性

#### 设计模式

- **P0-10** 复用实例模式中，生命周期入口方法（如状态机的 `enter()`）**必须**调用 `_reset()` 抽象方法，子类 override `_reset()` 清理运行时变量

#### 开发流程（TDD）

- **P0-11** 任何阶段对 GDScript（`.gd`）文件的修改，**必须**遵循 TDD（测试驱动开发）流程：先编写失败测试（Red） → 编写最小实现使测试通过（Green） → 重构代码（Refactor）。**禁止**先写实现代码再补测试。此规则适用于所有开发阶段（初始化、游戏设计、技术分析、架构设计、迭代开发、交付），不限于迭代开发阶段的 Story 开发
- **P0-12** 【触发时机：TDD 的 Red 阶段】在编写测试用例前，**必须**先梳理该 Story 的所有验收标准（BDD 场景），确保每条验收标准都有至少一个测试用例覆盖。禁止出现验收标准无对应测试用例的情况。若 Story 文档中的验收标准不够具体，**必须**先与用户澄清后再编写测试

### 任务生命周期钩子（按执行顺序）

> 以下规则按编号顺序执行，不可跳步。

#### 任务开始前

- **P0-13** 【触发时机：用户任务开始前】**必须**从 `docs/06_postmortem/MEMORY.md` 读取经验教训，避免重犯。文件不存在时跳过

#### 任务完成后

- **P0-14** 【触发时机：用户任务完成后】**必须**事后总结经验教训，保存到 `docs/06_postmortem/MEMORY.md`（**禁止**输出重复的经验）。刷新 MEMORY.md 时**必须**使用 `[Skill] summarize` 对当前对话进行摘要提炼
- **P0-15** 【触发时机：P0-14 完成后】**必须**使用 `[Skill] lark-im` 通过飞书通知用户任务完成状态（包含任务名称、完成结果、关键变更摘要）。凭证从环境变量 `FEISHU_APP_ID` 和 `FEISHU_APP_SECRET` 获取。若凭证缺失，跳过通知并在回复中说明
  ```bash
  # 发送飞书通知命令
  lark-cli im +messages-send --user-id "$FEISHU_USER_ID" --text "<消息内容>" --as bot
  ```

#### 代码变更后

- **P0-16** 【触发时机：每次代码变更后】测试覆盖率**不得低于** 80%，通过 `[MCP] godot-ultimate_godot_get_test_coverage` 验证。初始化阶段（无测试文件时）豁免

## P1 - 跨阶段规范

### Story 执行粒度

#### Story 开发流程

- **P1-1** 【触发时机：每个 Story 开发前】**必须**先输出该 Story 的概要（包含 Story 名称、开发目标、涉及文件/模块、关键实现要点、预估工作量），然后**暂停执行**，等待用户确认后方可开始该 Story 的开发
- **P1-2** 每个 Story 以单个 agent_task 为粒度拆分开发。无依赖的 agent_task 可并行执行，有依赖的 agent_task **必须**串行执行。每个 Story 完成后**必须**暂停执行，等待用户确认后再继续下一个 Story
- **P1-3** Story 开发顺序**必须**按迭代开发方式编排：每个 Story 完成后，游戏都**必须**可运行且包含可游玩的内容。禁止出现某个 Story 完成后游戏无法启动或无可玩内容的编排

#### 进度跟踪与提交

- **P1-4** 每次开发的最小维度为 Story。**必须**通过 `docs/04_sprint/01_backlog.md` 跟踪每个 Story 的开发状态（待开发 / 进行中 / 已完成），状态变更时同步更新 backlog
- **P1-5** 进入下一个 Story 开发前，**必须**确保当前所有代码已提交到 Git（工作区干净），否则禁止开始新 Story

#### 代码检视

- **P1-6** 【触发时机：Story 代码编写完成，测试通过前】AI 和用户**必须**一起检视代码。AI 先逐文件展示变更摘要（文件路径、变更内容、设计意图），用户逐项确认或提出修改意见，双方达成一致后方可继续

#### 测试与验收

- **P1-7** 【触发时机：Story 代码检视通过后，标记为已完成前】**必须**运行全部测试用例（`[MCP] godot-ultimate_godot_run_tests`）并确保全部通过；**必须**逐项验证满足该 Story 中定义的所有验收标准（Acceptance Criteria），两者均通过后方可将该 Story 标记为已完成
- **P1-7.5** 【触发时机：Story 开发完成后，标记为已完成前】**必须**为该 Story 中的每条验收标准创建对应的功能测试用例（`test/functional/{模块}/`），通过按键模拟和截图验证进行端到端测试。功能测试用例**必须**与验收标准（BDD 场景）一一对应，确保每条验收标准在运行时环境下表现正确。无功能测试的 Story 不得标记为已完成
- **P1-8** 每个 Story 开发**必须**编写对应的集成测试用例，存放在 `test/integration/{模块}/` 目录下，无集成测试的 Story 不得标记为已完成
- **P1-9** 【触发时机：Story 代码开发完成后，代码检视前】**必须**逐项对比该 Story 的每条验收标准（BDD 场景）与现有单元测试和集成测试用例，输出覆盖分析表（验收标准 → 已覆盖/未覆盖/部分覆盖 → 对应测试方法名）。若存在未覆盖或部分覆盖的验收标准，**必须**补充测试用例并重新运行全部测试确保通过，方可进入代码检视环节

#### Story 文档规范

- **P1-10** Story 文档**必须**使用 BDD（行为驱动开发）方法编写，采用 Given-When-Then 格式描述行为场景。每个 Story 必须包含至少一个行为场景作为验收标准

#### 设计文档对比

- **P1-11** 【触发时机：Story 标记为已完成前】**必须**创建子代理（`[Agent] godot-consistency-checker`）逐项对比代码实现与该 Story 关联的设计文档（模块设计、状态机设计、功能需求等），输出差异清单。差异包括：设计文档中定义但代码未实现的功能、代码中存在但设计文档未描述的功能、实现方式与设计文档描述不一致的部分。所有差异**必须**与用户确认处理方案后方可标记 Story 为已完成

#### 静态分析与经验归档

- **P1-12** 【触发时机：Story 标记为已完成前】**必须**使用 `[Skill] godot-static-analysis` 对该 Story 涉及的所有代码文件执行静态分析，确保整体质量达到**优秀**级别。若未达成，**必须**按以下循环迭代直至达标：
  1. 使用 `[Skill] test-driven-development` 对未达标项进行 TDD 重构（Red → Green → Refactor）
  2. 补充测试用例覆盖重构涉及的逻辑，运行 `[MCP] godot-ultimate_godot_run_tests` 确保全部通过
  3. 重新执行 `[Skill] godot-static-analysis` 检查
  4. 若仍未达标，回到步骤 1 继续
- **P1-13** 【触发时机：代码检视（P1-6）和静态检查（P1-12）完成后】代码检视和静态检查中发现的问题（代码规范违反、设计模式偏差、性能隐患、测试缺失等），**必须**总结为经验教训追加到 `docs/06_postmortem/MEMORY.md`，格式遵循该文件已有的"实例"结构（场景 + 教训 + 规则）。**禁止**与已有经验重复

### 代码与设计一致性检查

- **P1-14** 【触发时机：每个 agent_task 代码实现完成后，进入下一个 agent_task 前】**必须**创建子代理（`[Agent] godot-consistency-checker`）对比本次代码变更与对应的设计文档（模块设计、状态机设计、功能需求等），输出一致性报告。报告内容包括：
  1. **已实现且一致**：代码实现与设计文档描述完全匹配的功能项
  2. **设计文档中有但未实现**：设计文档中定义但代码中遗漏的功能项
  3. **代码中有但设计文档未描述**：代码中额外添加但设计文档未涉及的功能项
  4. **实现方式不一致**：代码实现方式与设计文档描述存在偏差的功能项（需标注偏差细节）
  
  对于第 2、3、4 类差异，**必须**暂停执行并告知用户，由用户决定：
  - 补充/修改代码以对齐设计文档
  - 更新设计文档以反映代码实现
  - 确认差异为预期行为并记录偏差原因
  
  用户确认后方可继续后续流程

### 功能开发全流程

- **P1-15** 代码开发**必须**使用 TDD（测试驱动开发）方式：先编写失败测试（Red） → 编写最小实现使测试通过（Green） → 重构代码（Refactor）。**禁止**先写实现代码再补测试。功能开发流程：
  ```
  task(@godot-ui-designer) (使用 [Skill] godot-ui 指导 UI 设计)
    → task(@godot-architect) (使用 [Skill] godot-architect 架构设计)
    → [MCP] godot-mcp：AI 使用 MCP 工具创建场景基本框架
    → task(@godot-developer) (使用 [Skill] godot-best-practices + godot-gdscript-patterns 实现)
    → [MCP] godot-ultimate_godot_lint_file / run_tests (验证)
    → [MCP] minimal-godot_get_diagnostics (最终诊断)
  ```

### Story 开发标准流程（P1-15S）

> 生成 Story 开发 todo 列表时，**必须**严格按以下步骤编排，不得遗漏或调换顺序。

| 步骤 | 名称 | 规则依据 | 关键动作 |
|------|------|---------|---------|
| **S1** | 开发前准备 | P0-13、P1-1 | 读取 `MEMORY.md` 经验教训 → 输出 Story 概要（名称、目标、涉及文件/模块、关键实现要点、预估工作量） → **暂停等待用户确认** |
| **S2** | 梳理验收标准 | P0-12、P1-10 | 列出所有 BDD 场景（Given-When-Then），确保每条验收标准有对应测试用例。不够具体时**必须**先与用户澄清 |
| **S3** | 编写失败测试（红） | P0-11 | `[Agent] godot-developer` 先编写单元测试和集成测试框架（`test/unit/` + `test/integration/`），确保测试失败 |
| **S4** | 编写最小实现（绿） | P0-11 | `[Agent] godot-developer` 写最少的代码使测试通过。使用 `[Skill] godot-best-practices` + `[Skill] godot-gdscript-patterns` 指导实现 |
| **S5** | 重构代码（重构） | P0-11 | `[Agent] godot-developer` 优化代码结构，保持测试通过。遵循 SOLID + DRY 原则 |
| **S6** | 代码与设计一致性检查 | P1-14 | `[Agent] godot-consistency-checker` 对比代码变更与设计文档，输出一致性报告（已实现/未实现/额外实现/实现不一致）。存在差异时**暂停**，由用户决定处理方案 |
| **S7** | 验收标准覆盖分析 | P1-9 | 逐项对比验收标准与测试用例，输出覆盖分析表。补充缺失测试并重新运行全部测试 |
| **S8** | 运行全部测试 | P1-7 | `[MCP] godot-ultimate_godot_run_tests` 确保全部通过 |
| **S8.5** | 功能测试 | P1-7.5 | `[Agent] godot-functional-tester` 通过按键模拟和截图验证，对游戏进行端到端功能测试，确保验收场景在运行时环境下表现正确 |
| **S9** | 静态分析 | P1-12 | `[Agent] godot-static-analyzer` 执行静态分析，未达标则回到 S5 迭代 TDD 重构循环 |
| **S10** | 诊断检查 | P2-10 | `[MCP] minimal-godot_get_diagnostics` 确保无语法错误 |
| **S11** | 代码检视 | P1-6 | `[Agent] godot-reviewer` 逐文件展示变更摘要（文件路径、变更内容、设计意图），和用户一起逐个文件进行代码检视，用户逐项确认或提出修改意见 |
| **S12** | 设计文档对比 | P1-11 | `[Agent] godot-consistency-checker` 逐项对比代码实现与设计文档，输出差异清单，用户确认处理方案 |
| **S13** | 经验教训归档 | P1-13 | 将代码检视和静态检查中的问题总结为经验教训，追加到 `docs/06_postmortem/MEMORY.md` |
| **S14** | 更新 Backlog | P1-4 | 将该 Story 标记为已完成 |
| **S15** | Git 提交 | P1-5、P2-10、P2-12 | 确保工作区干净，与用户确认后执行 git commit |
| **S16** | 收尾通知 | P0-14、P0-15 | `[Skill] summarize` 提炼经验 → `[Skill] lark-im` 飞书通知用户完成状态 |

**约束**：
- 每个 Story 完成后**必须**暂停，等待用户确认后再开始下一个 Story（P1-2）
- Story 编排必须保证每个 Story 完成后游戏可运行且包含可游玩内容（P1-3）
- 步骤 S1-S16 不可跳步、不可调换顺序，除非用户明确指示

### 场景搭建分工

#### AI 与用户分工

- **P1-16** Scene 由 AI 通过 MCP 工具搭建骨架（节点树结构、脚本挂载），完成后输出详细操作指导文档（节点属性、动画编排、布局参数等），由用户在 Godot 编辑器中手动完成最终编排
- **P1-17** 场景搭建后**必须**暂停执行，询问用户是否需要介入 Scene 编排。若用户确认需要，输出详细操作指导后再次暂停，等待用户操作完成并确认后，方可继续后续流程

#### 场景命名与复用

- **P1-18** 场景的根节点名称**必须**与场景文件名保持关联（PascalCase 形式），**禁止**使用默认的 `root`。例如场景文件 `player.tscn` 的根节点名称应为 `Player`
- **P1-19** 跨场景或单场景中重复使用的节点组合，**必须**按需抽象为独立的可复用子场景（`.tscn`），通过实例化引用而非复制粘贴，以遵循 DRY 原则

#### 脚本规范

- **P1-20** GDScript 文件**必须**定义 `class_name`（Autoload/Singleton 除外），并通过 `class_name` 进行类型引用，**禁止**使用 `preload`/`load` 后的变量名作为类型别名

### 资源分析文档化

- **P1-21** 使用 `[Skill] sprite-analyzer` 分析游戏图片资源后，**必须**将分析结果以文档形式保存到 `docs/02_analysis/` 目录（命名格式：`{序号}_资源分析_{资源名}.md`），后续开发中**必须**直接引用该文档，禁止重复分析同一资源

### 生成物检视

- **P1-22** 所有文档和代码生成后，**必须**创建子代理（`[Agent] godot-artifact-reviewer`）对生成物进行独立检视，并针对检视发现的问题进行修改修正。检视内容包括但不限于：
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
test/functional/ (功能测试)
addons/
docs/ (设计文档，按阶段分)
```

- **P2-1** 严禁在目录外存放资产/脚本/测试
- **P2-2** 场景、脚本、测试按模块分目录，且同一模块的子目录相对路径**必须**保持一致。例如模块 `player` 的文件分别存放于 `scenes/player/`、`scripts/player/`、`test/unit/player/`、`test/integration/player/`、`test/functional/player/`

### 文档交付件规则

#### 交付件清单

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

#### 命名与存放

- **P2-4** 文档文件名格式：`{两位序号}_{中文名称}.md`，序号从 01 递增
- **P2-5** 文档必须放在对应阶段目录中，禁止在 `docs/` 根目录直接放文件
- **P2-6** `{xxx}` 为模板变量，使用时替换为实际内容；固定文档（如 `01_游戏设计文档.md`）不加后缀

#### 图表规范

- **P2-7** 架构设计文档使用 mermaid 绘制图形

#### 内容规范

- **P2-8** 文档内容规则：
  - **结构化**：每个文档必须包含明确的标题层级（`#` → `##` → `###`），禁止跳级
  - **可追溯**：架构设计文档必须关联对应的功能需求文档（引用文档名或路径）
  - **图表优先**：涉及流程、架构、状态转换时**必须**使用 mermaid 绘制图形，禁止仅用文字描述
  - **具体可执行**：开发指导文档必须包含可直接执行的步骤，禁止模糊表述（如"适当优化"）
  - **自包含**：每个文档必须独立可读，包含必要的背景上下文，不依赖外部口头说明

#### 自检清单

- **P2-9** 文档输出前必须自检：
  - [ ] 文件名是否符合命名格式
  - [ ] 是否存放在正确阶段目录
  - [ ] 标题层级是否完整无跳级
  - [ ] mermaid 图形是否渲染正确（涉及流程/架构/状态时）
  - [ ] 是否关联了上游需求文档（架构设计、开发指导类）

### Git 提交

#### 提交前检查

- **P2-10** 提交 .gd 前检查（每步通过后再执行下一步）：
  ```
  [MCP] godot-mcp_reload_scene / 在 Godot 编辑器中重新加载项目（刷新 .uid、LSP 缓存、索引）
    → [MCP] minimal-godot_get_diagnostics (语法检查)
    → [CLI] $GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit (运行测试)
    → [MCP] godot-ultimate_godot_check_patterns (模式检查)
  ```
- **P2-11** 编写 `.gd` 代码或修改 `godot.project` 文件后，**必须**通过重新加载当前项目（见 P2-17）来刷新自动生成的 `.uid` 文件、LSP 缓存和索引，并检查配置是否能正常加载。重新加载前**必须**确保只有 1 个 Godot 编辑器实例在运行

#### 提交流程

- **P2-12** 与用户确认后再执行 git commit
- **P2-13** 修改测试必须使用 `[Skill] godot-best-practices`

#### .uid 文件

- **P2-14** .uid 文件必须提交（.tscn 除外）
- **P2-15** 缺少 .uid 时提醒用户生成

### 命令行

- **P2-16** 使用 `$GODOT_HOME` 环境变量：`$GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit`
- **P2-17** Godot 编辑器操作方法：
  - **保持运行**：编辑器启动后**禁止关闭**，需保持运行以维持 LSP 服务和诊断功能。整个开发会话期间编辑器应始终处于打开状态
  - **打开编辑器**（按优先级排序）：
    1. **MCP 工具**（推荐）：`[MCP] godot-mcp_launch_editor`（传入 `projectPath` 参数）
    2. **CLI 命令**（Windows PowerShell）：`& $env:GODOT_HOME --path <项目路径>`
    3. **CLI 命令**（macOS/Linux）：`$GODOT_HOME --path <项目路径>`
  - **无头模式打开项目**（不渲染，仅加载索引）：
    - Windows PowerShell：`& $env:GODOT_HOME --editor --path <项目路径>`
    - macOS/Linux：`$GODOT_HOME --editor --path <项目路径>`

### Godot 开发经验

#### 内存与缓存管理

- **P2-18** 内存管理：`Resource`（含 `RefCounted`）子类**禁止**调用 `.free()`，由引用计数自动释放；`Node` 子类**必须**调用 `.free()` 或 `queue_free()`
- **P2-19** `class_name` 缓存管理：新增或移动含 `class_name` 的 `.gd` 文件后，**必须**通过 Godot 编辑器重载项目（见 P2-17）来刷新缓存。未刷新缓存会导致 "Identifier not declared" 或 "Class X hides a global script class" 错误。**禁止**手动修改 `.godot/` 目录下的任何文件（见 P2-29）

#### 场景文件

- **P2-20** 场景文件 (.tscn) 手写规则：
  - 场景骨架（节点树 + 脚本挂载 + 碰撞形状 + 信号连接）可手写
  - 视觉资源（SpriteFrames / TileSet / 材质）**必须**在 Godot 编辑器中创建
  - 子场景根节点路径用 `"."` 而非父节点名

#### 设计模式

- **P2-21** 状态模式选型：状态基类用 `Resource`（轻量、无需场景树），状态机管理器用 `Node`（可挂载为子节点）

#### 测试经验

- **P2-22** GUT 单元测试模式：
  - `load("res://...")` + `script.new()` 可独立测试脚本的常量和纯逻辑方法
  - `@onready` 变量在 `script.new()` 模式下**不会执行**，测试中需手动赋值（如 `player.animated_sprite = AnimatedSprite2D.new()`）
  - `CharacterBody2D.move_and_slide()` 需要物理空间（场景树），纯 `script.new()` 实例**禁止**调用；依赖物理引擎的方法用集成测试验证
  - `AnimatedSprite2D.new()` 默认只有 `"default"` 空动画，测试中需用 `SpriteFrames.add_animation()` 预注册所需动画名
  - `GUT` 的 `-gdir` 参数**不会递归**搜索子目录，需显式指定每个测试目录
- **P2-23** 测试分层策略：单元测试只验证纯逻辑（速度设置、状态切换、属性变更）；依赖场景树的行为（动画播放、物理碰撞、输入检测）用集成测试（场景实例化 + `add_child`）验证

#### 功能测试

- **P2-24** 功能测试分层策略：单元测试和集成测试无法验证的运行时行为（按键响应、画面渲染、场景切换效果、实际游戏手感），**必须**通过功能测试（`[Agent] godot-functional-tester`）进行端到端验证。功能测试脚本继承 `SceneTree`，通过 `Input.parse_input_event()` 模拟按键输入，通过 `get_viewport().get_texture().get_image()` 截图验证
- **P2-25** 功能测试脚本存放于 `test/functional/{模块}/` 目录，命名格式：`test_{功能名}_functional.gd`。截图存放于 `test/functional/screenshots/` 目录
- **P2-26** 功能测试执行顺序：**必须**在单元测试（S8）全部通过后执行（S8.5），不得跳过。功能测试失败时，**必须**将缺陷交由 `[Agent] godot-developer` 修复后重新执行全部测试流程（从 S8 开始）

#### LSP 与诊断

- **P2-27** LSP/Diagnostics 需要编辑器以 GUI 模式运行（非 headless `--editor`），运行 `[MCP] minimal-godot_get_diagnostics` 前确认编辑器已启动；若 LSP 不可用，应先启动编辑器再重试

#### 碰撞配置

- **P2-28** 碰撞层/掩码解耦：`collision_layer` 和 `collision_mask` **禁止**在 GDScript 代码中硬编码赋值（如 `_ready()` 中设置），**必须**在场景文件（`.tscn`）的节点属性中配置。代码与碰撞配置解耦，便于不同场景复用同一脚本。代码中**仅允许**读取碰撞层值用于运行时判断（如 `get_collision_layer()` 检查）

#### .godot 目录

- **P2-29** `.godot/` 目录下的所有文件（包括 `.uid`、缓存、索引等）由 Godot 编辑器自动生成和管理，**禁止**手动创建、修改或删除。如需刷新，**必须**通过 Godot 编辑器重载项目（见 P2-17）实现

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
