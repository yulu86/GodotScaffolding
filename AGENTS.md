# Godot 游戏开发宪法（项目级）

> **Godot 4.x / GDScript 专属宪法**，条款为最高优先级指令，不可协商、不可绕过。
> 用户指令优先级高于 Skill；与全局通用宪法互补（语言、工具、ComfyUI、飞书、Git 等通用条款遵从全局约定）。
> **文档结构**：PART A 速查 → PART B 主流程 → PART C 协作关卡 → PART D 领域详解 → PART E 附录。AI 可只读 A 即获全貌。
> 本文件结构于 2026-07-05 经用户授权重构（v1→v2），语义零删减。

---

# PART A · 全局速查

> AI 接到任务后**先读本 PART**，30 秒拿到全部强制约束与工具索引。

## A0 元信息与适用范围

- **适用**：Godot 4.x + GDScript（当前：Forward Plus、Jolt Physics）。被 Codex / OpenCode / Claude Code / ZCode 等主流 AI 编码工具默认读取，是协作的唯一行为基线。
- **例外**：C#、GDExtension / C++、Visual Script、编辑器插件开发——不适用本文件，须先与用户确认方案，不擅自套用 GDScript 规则。

**规则标签与门禁标注**：

| 标签 | 含义 | 标注 | 含义 |
|------|------|------|------|
| `[P0]` | MVP 与正式开发均**强制**，违反即阻断提交 | `【命令】` | 可执行 CLI（如 headless 测试） |
| `[P1]` | 正式开发**强制**，MVP 强烈建议 | `【MCP】` | Godot MCP 诊断（minimal-godot / godot-ultimate / godot-mcp） |
| 无标签 | 最佳实践，建议遵守 | `【Skill】` | 项目内 Skill（architect / best-practices / patterns / code-review / static-analysis / ui） |

> **阶段原则**：MVP 满足所有 `[P0]`；正式开发满足全部 `[P0]+[P1]`。

## A1 `[P0]` 强制规则全清单（34 条）

> 详解见各条末尾 `→ Dx`。AI 判断"某事受哪条约束"时查本表，无需全文扫描。

| # | 规则 | 详解 |
|---|------|------|
| P0-01 | 信号向上、调用向下（signal up, call down） | → D5 |
| P0-02 | 组合优于继承（has-a 而非 is-a） | → D3 |
| P0-03 | 数据驱动优于硬编码（@export / Resource） | → D6 |
| P0-04 | 标准目录树（scenes/scripts/assets/...） | → D1 |
| P0-05 | snake_case 文件名 + 版本控制规则 | → D1 |
| P0-06 | 临时文件必存 `tmp/`、任务结束必删 | → D1 |
| P0-07 | Aseprite 产物必存 `aseprite-assets/`（清单见 D1） | → D1 |
| P0-08 | 静态类型全标注（变量/签名/返回值/信号参数/@onready） | → D2 |
| P0-09 | class_name 规则（Singleton 禁，非 Singleton 必须） | → D2 |
| P0-10 | 脚本结构顺序（Signals→Enums→Exports→...→Private） | → D2 |
| P0-11 | 文档与卫生（每 func/enum/signal 有 `##`；代码除注释外无中文） | → D2 |
| P0-12 | 节点引用用 `@onready`+类型 / `%UniqueName` | → D4 |
| P0-13 | 场景自包含可复用；`queue_free` 前用 `is_instance_valid` | → D4 |
| P0-14 | 动画首选 `AnimationPlayer`，`AnimatedSprite2D` 受限 | → D4 |
| P0-15 | 碰撞层名必须中文（项目设置 Layer Names） | → D4 |
| P0-16 | 信号驱动用 `.emit()` / `.connect()`，禁字符串形式 | → D5 |
| P0-17 | 禁止子节点直接调用父节点方法 | → D5 |
| P0-18 | 状态机（简单 enum+match；复杂 StateMachine+State 节点） | → D3 |
| P0-19 | 测试框架 GdUnit4，三层（unit/integration/functional） | → D7 |
| P0-20 | TDD 小循环（Red 1 个测试→Green 最小实现→Refactor） | → D7 / B3 |
| P0-21 | Headless CI 两步流水线（import → GdUnitCmdTool） | → D7 / E1 |
| P0-22 | 质量门禁 G01–G06（提交前必过，见 A2） | → A2 |
| P0-23 | `.tscn`/`.tres` 禁手写，必由工具/MCP 生成 | → D4 / B2 |
| P0-24 | Skill 链不可绕过（CLI/Skill 能力优先） | → A3 |
| P0-25 | 增量小步验证（一次一职责，立即测） | → B 主流程 |
| P0-26 | 可视化搭建协作（强制关卡①，见 C1） | → C1 / B4 |
| P0-27 | 玩家手工验证（强制关卡②，见 C2） | → C2 / B6 |
| P0-28 | 经验沉淀与收尾闭环（MEMORY.md + 飞书） | → C3 / B7 |
| P0-29 | 提交前编辑器重载 + 任务始读 MEMORY.md | → B1 / B7 |
| P0-30 | Wiki 经验优先查询（动手前先查本地 Wiki） | → C4 |
| P0-31 | `docs/` 目录规划与两阶段维护 | → D11 |
| P0-32 | 文档交付索引（按阶段读/产） | → D11 |
| P0-33 | 设计-实现一致性校验（交付前必对比） | → D11 / B5 |
| P0-34 | README 内容约束（纯游戏门面，禁技术/进度） | → D11 |

## A2 质量门禁速查（G01–G13）

> 提交前**必须**全部达标。指标体系复用 `【Skill】` `godot-static-analysis` 的 C01–C12。

| 编号 | 门禁项 | 阈值 | 命令 / MCP | 阶段 |
|------|--------|------|-----------|:---:|
| G01 | 语法/类型错误 | 0 | `【MCP】` `minimal-godot_scan_workspace_diagnostics` | P0 |
| G02 | Lint（error+warning） | 各 0 | `【MCP】` `godot-ultimate_godot_lint_project` | P0 |
| G03 | 场景断裂引用 | 0 | `【MCP】` `godot-ultimate_godot_validate_scenes` | P0 |
| G04 | 项目全局验证 | 全通过 | `【MCP】` `godot-ultimate_godot_validate_project` | P0 |
| G05 | 未定义 Input Action | 0 | `【MCP】` `godot-ultimate_godot_validate_inputs` | P0 |
| G06 | headless 测试套件 | 全绿 | `【命令】` `godot --headless`（D7） | P0 |
| G07 | 函数圈复杂度 | ≤ 10 | `godot-ultimate_godot_get_complexity` | P1 |
| G08 | 代码重复（≥5 行） | 0 组 | `godot-ultimate_godot_find_duplication` | P1 |
| G09 | 死代码（未用 func/var/signal） | 0 | `godot-ultimate_godot_detect_dead_code` | P1 |
| G10 | 未用文件 | 0 | `godot-ultimate_godot_find_unused_files` | P1 |
| G11 | 测试覆盖率 | ≥ 80% | `godot-ultimate_godot_get_test_coverage` | P1 |
| G12 | 项目健康度评分 | ≥ 80 | `godot-ultimate_godot_project_health` | P1 |
| G13 | 代码模式合规 | 0 违规 | `godot-ultimate_godot_check_patterns` | P1 |

## A3 工具速查

**Skill 协作链**（P0-24，不可绕过）：

```
架构设计  →【Skill】godot-architect（只设计，不写码）
编码实现  →【Skill】godot-best-practices / godot-gdscript-patterns
TDD 循环 →【Skill】test-driven-development（D7 小循环）
代码检视 →【Skill】godot-code-review（逐文件，用户确认）
质量验证 →【Skill】godot-static-analysis（A2 门禁）
UI 开发  →【Skill】godot-ui
可视化搭建 → AI 用 MCP 写视觉初值 + 出指导，用户在编辑器精调（C1）—— 最终视觉/手感以用户为准
```

**MCP（项目已配）**：`minimal-godot`（G01）· `godot-ultimate`（G02–G13）· `godot-mcp`（`create_scene`/`add_node`/`save_scene`/`load_sprite`）· `aseprite`（像素美术，产物存 `aseprite-assets/`，见 D1）。

**命令入口**：完整命令见 **E1**（godot / qmd）。

---

# PART B · 主流程（AI 执行流水线）

> AI 接到任务后按 B1→B7 顺序执行。每节点：**做什么** + **调用什么** + **强制要点** + **详解链接**。

## B0 流程总览

```
B1 启动准备 → B2 架构设计 → B3 编码实现 → B4 可视化搭建(关卡①)
            → B5 质量验证 → B6 手工验证(关卡②) → B7 交付收尾
```

> **两强制关卡不可互相替代**：B4 是搭建期配置（AI 写初值+用户精调视觉属性）；B6 是运行期验证（玩家试玩黑盒验收）。

## B1 启动准备（P0-29）

- **做什么**：读 `docs/99_postmortem/MEMORY.md` 吸取教训；总结任务简报与验收标准；用 `【Skill】wiki-query` 检索本地 Wiki 中可借鉴的 Godot 经验（P0-30，详见 C4）。
- **强制**：每个任务开始前**必须**先读 MEMORY.md；涉及 Godot 技术/经验时**强制**先查 Wiki。

## B2 架构设计（P0-23, P0-25）

- **做什么**：架构级变更**必须**先经 `【Skill】godot-architect` 出设计文档（含 Mermaid 图）；用 `【MCP】godot-mcp` 搭场景节点骨架。
- **强制**：`.tscn`/`.tres` 禁手写（P0-23）；一次一职责小步推进（P0-25）。详见 D3。

## B3 编码实现（P0-20, P0-24）

- **做什么**：`【Skill】test-driven-development` 小循环（1 个测试→最小实现→重构）；`【Skill】godot-best-practices` / `godot-gdscript-patterns` 指导编码；`【MCP】godot-mcp` 搭骨架。
- **强制**：TDD 小循环（P0-20，详 D7）；Skill 链不可绕过（P0-24）。编码规范见 D2，场景节点见 D4。

## B4 可视化搭建（强制关卡①，P0-26）

- **做什么**：AI 用 `【MCP】godot-mcp` 为视觉属性写入合理初值；输出「可视化搭建指导」5 部分；用 `question` 给两选项后**立即停止**。
- **强制**：涉及可见节点（Sprite2D/AnimatedSprite2D/CollisionShape2D/Camera2D/Control/TileMapLayer/AudioStreamPlayer/GPUParticles2D 等）或视觉属性配置时**强制**触发。详 C1。

## B5 质量验证（P0-22, P0-33）

- **做什么**：跑 A2 全部门禁（诊断/lint/validate_scenes/validate_project/headless）；自行逐文件 `【Skill】godot-code-review`；与用户在编辑器逐文件共检；设计-实现一致性校验（P0-33，详 D11）。
- **检视强制输出**：AI 检视每个文件时**必须**先说明：①**修改目的**（为什么要做这个修改，解决什么问题）②**修改点**（具体改了哪些地方，每个修改点对应的代码位置与变更内容）。然后才能进入逐条审查项。
- **强制**：G01–G06 必过；修复所有代码警告。

## B6 手工验证（强制关卡②，P0-27）

- **做什么**：编辑器重载项目（P0-29 前置）后，输出「验证指导」5 部分；玩家对照 story 验收标准黑盒验证**现有实现**；用 `question` 给两选项后**立即停止**。
- **强制**：**禁止**跳过；**禁止**用自动化测试替代；**禁止**另建测试关卡；验证通过前禁止提交。详 C2。

## B7 交付收尾（P0-28）

- **做什么**：提交代码（全局 §4.2 commit 规范）→ 经验沉淀 MEMORY.md（独立 commit）→ `【Skill】lark-im` 飞书通知。
- **顺序约束**：代码提交 → 经验沉淀 → 经验文档提交 → 飞书通知。禁止在经验文档提交前发完成通知。详 C3。

---

# PART C · 协作机制（横切强制关卡）

> C1–C5 是贯穿流程的强制协作机制。**边界声明**（合一）：C4 检索**外部 LLM Wiki**（跨项目复用经验）；C5 检索**当前项目自身 markdown**（需求/架构/规范/MEMORY 等）。两者互补，不可互相替代。

## C1 `[P0]` 可视化搭建协作（强制关卡①）

> **理由**：AI 无法"看见"渲染/物理结果，但可凭命名约定、美术规范、设计文档给出**合理初值**；"最终好不好看/手感对不对"只能靠人眼与试玩判定。故采用「AI 用 MCP/编辑器写入初值 → 用户精调到最终效果」两段式。

**触发条件**（满足任一）：新建或修改含可见节点的场景（`Sprite2D`/`AnimatedSprite2D`/`CollisionShape2D`/`Camera2D`/`Control`/`TileMapLayer`/`AudioStreamPlayer`/`GPUParticles2D` 等），或需配置动画/碰撞/变换/纹理/摄像机/布局/瓦片/音频/粒子等视觉属性。

**分工**：

| 类别 | AI 写入初值（可自动化） | 用户精调到最终（眼看手调/试玩） |
|------|----------------------|------------------------------|
| 脚本/数据/骨架 | `.gd` 逻辑、`.tscn` 节点树骨架、`.tres` 数值、挂 `CollisionShape2D`+默认形状、按约定指定 `texture`、设默认 zoom/limit、建空 `SpriteFrames`+动画名 | — |
| 动画/碰撞/变换/纹理/摄像机/布局/瓦片/音频/粒子 | 建资源与动画名、设默认 fps/音量/参数 | 拖入实际素材帧、按实际外形精调形状尺寸、试玩后微调位置/取景/音量、绘制 TileMap 格子等 |

**输出「可视化搭建指导」须含 5 部分**：①场景与节点（路径+类型）；②已写入初值清单；③需精调项+参考规格；④编辑器精调操作步骤；⑤反馈要求。

**反馈机制**：用 `question` 给两选项后**立即停止**：①✅已完成精调，继续后续门禁（推荐）；②❌需 AI 调整骨架/脚本/初值。**用户精调结果以编辑器最终值为准，AI 不得回退覆盖。**

## C2 `[P0]` 玩家手工验证（强制关卡②）

> 编辑器重载后、提交代码前**必须**执行（见 B7 前置）。**禁止**跳过，**禁止**用自动化测试替代。

**黑盒验证**：玩家以用户视角操作**现有实现**（现有场景/关卡），对照 **story 验收标准**（`docs/07_story/`，无 story 则用需求/架构功能点）逐条核验；**禁止**另建测试关卡/临时场景，AI **不得**臆造验收标准。

**输出「验证指导」须含 5 部分**：①运行方式（启动**现有**游戏，F5/F6/命令行，不另建场景）；②验收标准映射（列 story 的 AC1/AC2…）；③验证步骤（针对②逐步操作，全部走现有实现，给具体 Input Action）；④预期表现（每条 AC 的 Pass 判据：画面/动画/音效/数值）；⑤异常判定（失败现象 + 玩家需提供的反馈：报错截图/日志/复现步骤）。

**反馈机制**：用 `question` 给两选项后**立即停止**：①✅验证通过，继续提交（推荐）；②❌有问题，需修复。通过→提交；失败→修复循环（最小改动→重跑诊断/lint→重载编辑器→**再次**输出验证指导+`question`），由玩家驱动，AI 不得擅自宣布通过。

## C3 `[P0]` 经验沉淀与收尾闭环

每次任务/检视后，将经验追加到 `docs/99_postmortem/MEMORY.md`，按**双区**区分：**通用经验**（跨 Godot 项目可复用，如"浮点用 assert_almost_eq"）、**项目专属经验**（仅适用本项目）。

**收尾闭环（强制，不可跳过）**：

1. **提交经验文档**：**独立 commit** MEMORY.md（与代码 commit 分开），消息 `docs: 沉淀本次{任务}经验`（遵从全局 §4.2）。
2. **飞书通知**：用 `【Skill】` `lark-im` 发送任务完成通知。凭证**全部从项目根 `.env` 读取**（遵从全局 §1.4/§2.4），**禁止**硬编码：`FEISHU_APP_ID`（鉴权）、`FEISHU_APP_SECRET`（鉴权）、`FEISHU_USER_ID`（接收人 open_id）。通知内容至少含：任务摘要、变更文件数、是否全部门禁通过、经验沉淀要点。

> **顺序约束**：代码提交 → 经验沉淀 → 经验文档提交 → 飞书通知（见 B7）。禁止在经验文档提交前发送完成通知。

## C4 `[P0]` Wiki 经验优先查询（Godot 知识检索）

> **遵从全局 §2.5**（知识获取 wiki-query 优先）。本条针对 Godot 开发场景显式约束：动手前**先查本地 LLM Wiki**，复用已沉淀经验，避免重复踩坑或臆造方案。

**触发条件**（满足任一，**禁止跳过**）：
- 开始任何 Godot 功能/模块开发前（架构设计、编码实现、场景搭建、动画/碰撞/UI/性能优化等）；
- 遇到 Godot API 用法、节点选型、模式选择（如状态机/对象池/组件/EventBus）、性能调优、渲染/物理配置等**技术决策点**；
- 排查 Godot 相关报错、断裂引用、导入异常、行为与预期不符等问题。

**查询方式**：用 `【Skill】` `wiki-query` 向本地 LLM Wiki 知识库检索，查询词须精确反映当前技术点（如「Godot AnimationPlayer 多轨编排」「Jolt Physics 碰撞层配置」「GdUnit4 headless 测试退出码 103」）。

**结果处理**：
- **有命中**：优先采纳已沉淀经验作为方案依据；在架构设计/实现/检视中**显式引用**来源（如"据 Wiki《xxx》经验，采用 yyy 方案"）。
- **无命中或不足**：方可从其他源（Godot 官方文档、网络搜索、网页抓取等）获取；若产出有价值分析，须**询问用户**是否用 `【Skill】` `wiki-collect` 回填 Wiki 作为素材（遵从全局 §2.5）。
- **任务完成后**：本次产生的可复用 Godot 经验，除按 C3 沉淀到 `MEMORY.md` 外，鼓励回填 Wiki 供后续任务检索。

## C5 `[P1]` 项目 Markdown 文档索引优先用 qmd

> **效率工具，非阻断**：qmd 不可用时可降级 `grep`/`read`，不阻断任务；但可用时**必须**优先使用以提升检索效率。
> **与 C4 的边界**：C4 检索**外部 LLM Wiki 知识库**（跨项目复用经验）；本条检索**当前项目自身的 markdown 文档**（需求/架构/规范/story/MEMORY 等）。两者互补，不可互相替代。

**索引范围**：项目内全部 `.md` 文档，**强制排除** `tmp/`、`addons/`、`.godot/`、`.qmd/`、`.opencode/`、`.zcode/`、`.git/` 等临时/第三方/工具目录。

**初始化（首次或新机器）**：

```bash
qmd --version                                                        # 前置：确认 qmd 可用
qmd init                                                             # 建立项目本地 .qmd 索引（.qmd/ 须 .gitignore，见 D1）
qmd collection add {this-project-name} "docs/,AGENTS.md,README.md"      # 添加项目文档集合（ {this-project-name} 为占位符，需要替换成当前项目名称）
qmd embed -c  {this-project-name}                                                 # 生成向量嵌入({this-project-name} 为占位符，需要替换成当前项目名称)
```

**查询优先级**（满足任一触发，**必须**优先 qmd 而非 `grep`/`read` 多文件试错）：
- 跨多个 `.md` 文件定位概念/接口/约定/历史决策（如「玩家状态枚举定义在哪」「ADR 有没有讨论物理引擎选型」）；
- P0-33 设计-实现一致性校验时检索设计文档；
- B1 启动准备阶段快速定位 `MEMORY.md` 与模块架构文档。

```bash
qmd query "玩家状态机的状态枚举定义"              # 推荐：混合检索（关键词+向量+重排）
qmd search "GdUnit4 headless" -c project          # 全文关键词 BM25（无需 LLM，最快）
qmd get docs/02_架构/01_技术架构.md               # 读取单文档（带行号，定位精准）
```

**索引更新（强制触发）**：
- 新增/修改/删除任何项目 `.md` 文档后（含 C3 `MEMORY.md` 沉淀、D11 架构/需求/story 文档产出），**必须**立即刷新索引，确保后续查询命中最新内容：

  ```bash
  qmd update && qmd embed -c project
  ```

- 提交代码前若改动了 `.md`，commit 前**必须**先跑一次索引更新。

**降级与约束**：
- **降级**：qmd 不可用 → 退回 `grep`/`read`，不阻断任务；任务结束后补跑 `qmd update`。
- **防幻觉**：qmd 语义检索结果**必须**用 `qmd get` 或 `read` 核对原文后再引用，**禁止**直接采信片段摘要。
- **版本控制**：`.qmd/` 一律 `.gitignore`（见 D1），**禁止**提交索引缓存。

---

# PART D · 领域规则详解

> 按领域完整保留所有强制规则。AI 在 B 流程对应节点按需查阅。

## D1 `[P0]` 项目结构规范

### 标准目录树（P0-04）

```
res://
├── scenes/            # .tscn，按模块分子目录
├── scripts/           # .gd，与场景一一对应
├── assets/            # sprites/ sounds/ music/ fonts/ resources/(.tres)
├── aseprite-assets/   # Aseprite 产物（.aseprite 源文件 + 导出 PNG/GIF/精灵表），见下
├── addons/            # 第三方插件（GdUnit4 等）
├── test/              # unit/ integration/{模块}/ functional/+screenshots/
├── docs/              # 文档（.gdignore 屏蔽），目录规划见 D11
└── tmp/               # 临时文件（.gitignore 屏蔽，任务结束删除，见下）
```

### 命名 / 路径 / 版本控制（P0-05）

- 文件名 `snake_case`，节点名 PascalCase；场景与脚本**一一对应**（`player.tscn` ↔ `player.gd`），避免孤儿脚本。
- `res://` 只读（随包发布）；`user://` 可读写（存档/设置/最高分）。
- `.godot/`、`.import/`、`export_presets.cfg`、`tmp/`、`.qmd/`、构建产物须在 `.gitignore`；`.tres`/`.tscn` 文本格式提交；`docs/` 加 `.gdignore`。

### 临时文件管理（P0-06）

- **统一存放**：任务执行中生成的临时文件（中间产物、缓存、调试文件、临时脚本等）**必须**保存到项目根 `tmp/` 目录，**禁止**散落到 `res://` 其他位置或系统临时目录。
- **任务结束必删**：任务结束后**必须**删除本次产生的全部临时文件；仅当用户**明确**要求保留或该文件已成为最终交付物时方可保留。
- **版本控制**：`tmp/` 一律 `.gitignore` 屏蔽（见上），**禁止**提交。

### Aseprite 产物管理（P0-07）

- **统一存放**：所有 Aseprite 相关产物——`.aseprite` 工程源文件（`create_canvas`/`copy_sprite` 的 `filename`/`output_filename`）及导出的 PNG/GIF/JPG、精灵表 PNG + JSON 数据（`export_sprite`/`export_frame`/`export_tag`/`export_spritesheet`/`export_layers` 的 `output_filename`/`output_directory`）——**必须**保存到项目根 `aseprite-assets/` 目录下，**禁止**散落到项目根、`assets/` 其他位置、`tmp/` 或系统临时目录。
- **产出物清单（强制）**：每次绘制任务**必须**交付以下产物，缺一即阻断（#3 仅动画任务强制）：

  | # | 产物 | 生成工具 | 存放路径 | 是否必须 |
  |---|------|---------|---------|:-------:|
  | 1 | `.aseprite` 工程源文件 | `create_canvas`/`copy_sprite` 的 `filename` | `aseprite-assets/source/` | ✅ 总是 |
  | 2 | 导出 PNG（静态帧 / 关键帧） | `export_sprite`/`export_frame` 的 `output_filename` | `aseprite-assets/export/` | ✅ 总是 |
  | 3 | 动画 GIF | `export_tag`（`output_filename` 取 `.gif`） | `aseprite-assets/export/` | 🎬 仅绘制动画时 |

  > 静态精灵交付 #1+#2；动画精灵交付 #1+#2+#3（PNG 取首帧/关键帧供游戏引擎贴图，GIF 供预览动画效果与文档演示）。精灵表（`export_spritesheet` + JSON）按需补充，不强制。
- **游戏资源引用**：导出的 PNG/GIF 直接被 Godot 场景以 `load("res://aseprite-assets/...")` 引用，**无需**再复制到 `assets/sprites/`；`assets/sprites/` 仅存放非 Aseprite 产出的外部素材。
- **版本控制**：`.aseprite` 源文件与导出产物（PNG/GIF/精灵表）均**纳入**版本控制（遵从上文），确保 clone 即可用、不依赖重新导出。
- **内部细分（建议）**：`aseprite-assets/` 内可按 `source/`（`.aseprite` 源文件）与 `export/`（导出产物）分子目录，或按模块/角色分子目录，保持可检索；不做强制层级。
- **临时预览例外**：仅为 AI/用户视觉反馈而导出的大尺度预览图（如 `export_frame` scale 8-10 用于检查画面）按 P0-06 走 `tmp/`，任务结束删除，**禁止**落入 `aseprite-assets/`。

## D2 `[P0]` GDScript 编码规范

> **门禁**：`【MCP】` `minimal-godot_get_diagnostics`（0 错误）、`godot-ultimate_godot_lint_file`（0 error 0 warning）、`【Skill】` `godot-best-practices`。

### 命名约定 + 静态类型全标注（P0-08）

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

### class_name 规则（P0-09）

- **Autoload / Singleton 脚本**：**禁止** `class_name`（用全局名访问）。
- **非 Singleton 脚本**：**必须** `class_name`，**禁止**用 `preload`/`load` 后的变量名当类型别名。

### 脚本结构顺序（P0-10）

```
@tool / class_name / extends → ##文档注释 → # === Signals ===
→ # === Enums === → # === Exports ===(用 @export_group 分组) → # === Constants ===
→ # === Public Variables === → # === Private Variables ===(_前缀)
→ # === Onready === → # === Lifecycle ===(_ready/_process/_physics_process)
→ # === Public Methods === → # === Private Methods ===
```

### 文档与卫生（P0-11）

- **代码除注释外无中文**（标识符/字符串字面量用英文/拼音，注释可中文）。
- 每个 `func`、`enum` 及枚举值、`signal` 须有 `##` 注释。
- 参数名**不与节点内置属性冲突**（`name`、`position`、`scale`）；命名精确反映用途，删不可达代码。

## D3 架构模式

### 核心心智模型

1. **四要素**：`Node`（构建块）→ `Scene`（可复用节点树 `.tscn`）→ `Resource`（数据容器 `.tres`）→ `Signal`（事件通信）。
2. **`[P0-02]` 组合优于继承**：用 has-a（组合/组件）表达能力，而非 is-a。
3. **三原则**：单一职责、松耦合（最小依赖、接口通信）、高内聚（相关功能集中）。

### `[P0]` 状态机（P0-18）

- **简单状态**：`enum State { IDLE, WALK }` + `match current_state`。
- **复杂状态**：`StateMachine`(Node) + `State`(Node 子类) 节点模式，每状态 `enter/exit/update/physics_update/handle_input`。详见 `【Skill】` `godot-gdscript-patterns`。

### `[P1]` 对象池 / 组件 / Autoload（正式开发）

- **对象池**：高频创建销毁对象（子弹/特效）用 `ObjectPool` 复用，禁 `_process` 内 `load`/`instantiate`。
- **Autoload**：仅真全局服务（GameManager / SaveManager / AudioManager / EventBus），**禁止**塞游戏逻辑。
- **组件系统**：能力以组件挂载，`has_method()`/`is` 判定能力而非类型硬依赖。

## D4 `[P0]` 场景与节点规范

> **门禁**：`【MCP】` `godot-ultimate_godot_validate_scenes`（断裂引用 = 0）。

### 节点引用（P0-12）

```gdscript
@onready var health_bar: ProgressBar = $UI/HealthBar   # ✅ @onready + 类型
@onready var player: Player = %Player                  # ✅ 关键节点 %UniqueName
# ❌ 禁止：get_node() in _ready()、深路径 $A/B/C/D、get_parent().get_parent() 链
```

### 场景设计（P0-13）

- 每个场景**自包含、可复用、可实例化**，不依赖特定父节点路径。
- 关键跨场景节点用 `%UniqueName`；`queue_free()` 前用 `is_instance_valid(node)` 检查，**禁止** `!= null` 判已释放节点。

### 动画节点选择（P0-14）

- **优先 `AnimationPlayer`**：动画需求一律首选 `AnimationPlayer`。它可驱动任意节点的任意属性（变换/材质/可见性/方法调用）、支持多轨并行与多节点编排、动画融合/队列/事件轨，扩展性远超 `AnimatedSprite2D`。
- **`AnimatedSprite2D` 受限使用**：仅当**纯逐帧切换**且无任何属性联动时方可独立使用；**禁止**以 `AnimatedSprite2D` 作为场景的主动画驱动。需要逐帧动画时，由 `AnimationPlayer` 通过 `SpriteFrames` 轨或调用其 `play()` 统一编排。
- **推荐组合**：`Sprite2D`/`AnimatedSprite2D`（负责显示）+ `AnimationPlayer`（负责编排）的 has-a 结构，符合 P0-02 组合优于继承。

### 碰撞层（Physics Layers）命名规范（P0-15）

- **碰撞层/碰撞遮罩的层名称必须用中文配置**：在 `项目设置 → Layer Names → 2D Physics` / `3D Physics`（写入 `project.godot` 的 `[layer_names]` 段）为每一层填入**中文语义名称**（如「玩家」「敌人」「地形」「子弹」「道具」「触发器」），**禁止**保留默认空名或填英文。
- **语义优先、一物一层**：层名须精确反映该层用途（实体类别/功能域），避免「层1/层2」这类无意义命名；同一实体类别不得跨层重复定义。
- **例外说明**：碰撞层名属于引擎配置（`project.godot`），非代码标识符，故不受 P0-11「代码除注释外无中文」约束；脚本中以 `collision_layer` / `collision_mask` 写入的**位掩码值**仍按代码规范处理（优先用具名常量/枚举表达，注释可中文）。

### `[P0]` 场景文件必须由工具生成（P0-23）

`.tscn` / `.tres` **禁止**纯手工编写文本（极易产生 UID/sub_resource 引用错误），必须用：Godot 编辑器可视化编辑；或 `【MCP】` `godot-mcp`（`create_scene`/`add_node`/`save_scene`/`load_sprite`）；或 `【MCP】` `godot-ultimate`（`godot_generate_feature`/`godot_generate_from_template`）。

## D5 `[P0]` 信号与通信

### 信号驱动（P0-16, P0-17）

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
# ❌ 禁止子节点直接调用父节点方法（P0-17）
```

### 通信解耦

- `[P1]` **EventBus**：Autoload 全局信号总线，**仅放精简跨系统事件**，不塞业务逻辑。
- `[P1]` **组件系统**：`HealthComponent`/`HitboxComponent`/`HurtboxComponent` 等 has-a 组合。

## D6 资源与数据驱动（`[P1]`，含 P0-03）

- **`[P0-03]` 数据驱动优于硬编码**：配置/数值/参数走 `@export` / `Resource`，不在代码里写死。
- **Resource 承载数据**：`@export var damage: int = 10`，配置存 `.tres`（可 Inspector 编辑/复用/继承）；**运行时须 `duplicate()` 副本**避免污染共享数据。

| 场景 | 方法 |
|------|------|
| 小/关键资源（编译期） | `preload("res://...")` |
| 大/可选资源（运行期） | `load("res://...")` 并缓存 |
| 异步防卡顿 | `ResourceLoader.load_threaded_request` + 轮询 status |

## D7 `[P0]` 测试规范

### 框架与分层（P0-19）

默认 **GdUnit4**（[godot-gdunit-labs/gdUnit4](https://github.com/godot-gdunit-labs/gdUnit4)）。三层：`test/unit/`（单类/函数）、`test/integration/{模块}/`（多模块协作）、`test/functional/`（端到端 + 截图）。

### TDD 小循环（P0-20，Red-Green-Refactor，单测驱动）

> **强制小步快跑**：每次只生成 **1 个测试方法(单个`gdscript`函数)** → 编码使其通过 → 重构，循环推进。禁止"先写一批测试再实现"。

```
[Skill] test-driven-development:
1.Red 写1个失败测试(单一`gdscript`函数) → 2.Green 写刚好满足的最小实现(不过度设计)
→ 3.Refactor 测试保护下重构保持绿 → 4.回到1写下个测试
```

- 每个公开方法/分支/边界至少 `2` 个测试，覆盖正常和异常场景，需要根据实际参数组合出多种测试用例；命名描述行为 `test_take_damage_reduces_health()`。
- 用 `add_child_autoqfree(child)` 自动清理；浮点比较用 `assert_almost_eq`，**禁止** `assert_eq` 比浮点。

### Headless CI 两步流水线（P0-21）

> **入口路径以当前 GdUnit4 版本为准**：v4.6 起命令行入口为 `addons/gdUnit4/bin/GdUnitCmdTool.gd`（旧版 `src/runner/GdUnitRunnerCmd.gd` 已移除）。新版在 `--headless` 下默认以 exit 103 拒绝运行（UI 交互测试在 headless 不可靠），**必须**加 `--ignoreHeadlessMode` 才能跑。测试目录为 `test/`（非 `tests/`）。完整命令见 **E1**。

### 覆盖率（`[P1]`）

`[P1]`（正式开发）≥ 80%；`[P0]`（MVP）覆盖关键逻辑路径。门禁 `【MCP】` `godot-ultimate_godot_get_test_coverage`。

## D8 交付规范

**commit 规范**（遵从全局 §4.2）：
- 格式：`{type}: {description}`
- 类型：feat, fix, perf, refactor, test, docs, config, delete
- 示例：`feat: 添加用户登录功能`

> 经验沉淀与飞书通知流程见 **C3**。

## D9 `[P1]` UI 规范（详见 `【Skill】` `godot-ui`）

- **布局**：`Control` + 容器（VBox/HBox/Grid/Margin/Scroll）自适应，避免手算坐标；`CanvasLayer` 分层（HUD=10、Pause=100）；`Theme` 存 `.tres`（`assets/resources/theme/`）。
- **可访问性**：所有交互控件须支持键盘/手柄（`focus_neighbor_*` focus 链 + 入口 `grab_focus()`）；隐藏 UI 用 `process_mode = PROCESS_MODE_DISABLED`。

## D10 `[P1]` 性能规范（正式开发强制，MVP 量力而行）

1. `_process` / `_physics_process` 内**禁止** `load`、频繁内存分配、轮询未变状态。
2. 缓存 `@onready` 引用与计算结果，避免每帧重复求值。
3. 高频对象用对象池；离屏节点 `process_mode = DISABLED` 或 `visible = false`。
4. 大资源用 `ResourceLoader.load_threaded_*` 异步加载防卡顿。
5. 静态类型全标注利于 GDScript 性能。

## D11 `[P0]` 文档交付与一致性校验

### docs/ 目录规划与两阶段维护（P0-31）

`docs/` 顶层按文档类型/生命周期编号分目录，文件命名 `{两位序号}_{中文名称}.md`（遵从全局 §3.1）。设计文档须用 **Mermaid** 绘制架构图/状态机图/流程图（遵从全局 §3.3）；架构类文档须含场景树结构、核心接口/信号定义、状态机图、依赖关系。

| 目录 | 职责 | 典型文件 | MVP `[P0]` | 正式 `[P1]` |
|------|------|---------|:---:|:---:|
| `README.md` | **游戏主题介绍（面向玩家/访客的门面）**：仅含游戏名称、简介、核心玩法亮点；**禁止**技术性/进度内容（详见 P0-34） | `README.md` | ✅ 必备 | ✅ 持续维护 |
| `00_开发指南/` | **开发者入口**：环境/怎么跑/技术栈/项目结构/文档索引/开发约定/里程碑（README 剥离出的全部技术性内容归宿） | `01_快速开始.md` | ✅ 必备 | ✅ 持续维护 |
| `01_需求/` | 需求与玩法设计（GDD） | `01_核心玩法.md`、`02_操作设计.md`、`03_关卡设计.md` | ✅ 核心玩法必备 | ✅ 持续维护 |
| `02_架构/` | 技术架构/场景树/状态机/接口/ADR | `01_技术架构.md`、`02_{模块}架构.md`、`03_ADR决策记录/{NN}_{决策}.md` | ✅ 技术架构必备；模块架构/ADR 🟡 按需 | ✅ 每模块必备 + 重要决策必记 |
| `03_美术规范/` | 美术风格/精灵命名尺寸/导入/调色板 | `01_美术总览.md`、`02_精灵规范.md`、`03_调色板.md` | 🟡 大纲即可 | ✅ 完整规范 |
| `04_音频规范/` | 音效音乐清单/Bus 路由/音量基线 | `01_音频总览.md`、`02_音频清单.md`、`03_Bus路由.md` | 🟡 大纲即可 | ✅ 完整规范 |
| `05_测试策略/` | 测试分层/覆盖率/CI/约定 | `01_测试总览.md`、`02_覆盖率目标.md`、`03_CI流水线.md` | 🟡 测试约定（本宪法 D7） | ✅ 完整策略 + 覆盖率 |
| `06_构建发布/` | 导出预设/多平台/版本/检查清单 | `01_导出预设.md`、`02_多平台发布.md`、`03_发布检查.md` | 🟡 MVP 导出预设 | ✅ 多平台完整 |
| `07_story/` | 用户故事（按模块分子目录，可选） | `01_{模块}/01_{故事名}.md` | ⬜ 按需 | ⬜ 按需 |
| `99_postmortem/` | 经验沉淀（通用/项目专属双区） | `MEMORY.md`（C3） | ✅ 必备 | ✅ 持续沉淀 |

> 图例：✅ 强制维护 ｜ 🟡 按需/大纲即可 ｜ ⬜ 该阶段不强制
> **MVP 最小必备集合（5 件）**：`README.md`（纯游戏主题）+ `00_开发指南/01_快速开始.md`（技术性内容归宿）+ `01_需求/01_核心玩法.md` + `02_架构/01_技术架构.md` + `99_postmortem/MEMORY.md`。其余 🟡 项须在对应功能实现前先出大纲，避免"先写码后补文档"。

### 文档交付索引（按阶段读取/产出，禁止跳过，P0-32）

| 阶段 | 应读文档 | 应产文档 | 位置约定 |
|------|---------|---------|---------|
| 需求/架构 | `01_需求/`、历史 `02_架构/`、`MEMORY.md` | 架构设计文档（含 Mermaid） | `02_架构/{NN}_{模块}架构.md` |
| Story 拆分（可选） | `01_需求/`、`02_架构/{模块}` | Story 文档 | `07_story/{NN}_{模块}/{NN}_{故事}.md` |
| 编码实现 | 对应 `02_架构/`、`MEMORY.md` | 代码 + 注释 | `scripts/` `scenes/` |
| 测试 | `05_测试策略/`、本宪法 D7 | 测试用例 | `test/{unit,integration,functional}/` |
| 检视/复盘 | 本宪法 D2–D10、`MEMORY.md` | 检视总结 | `99_postmortem/MEMORY.md` |
| 构建发布 | `06_构建发布/` | 发布产物 + 版本 | `build/` |

### 设计-实现一致性校验（P0-33）

每个功能交付前**必须**对比"设计文档"与"实际代码"：①读模块设计文档（架构图/接口/状态机）；②对照实际 `.gd`/`.tscn`（节点结构/信号/接口/状态枚举）；③不一致即修正（代码偏离改代码；设计过时更新文档并说明原因）；④在代码检视（B5）中**显式声明一致性结论**。

### README 内容约束（P0-34）

> **README.md 是项目的「游戏门面」**，面向玩家与外部访客，定位与 `docs/` 下技术文档严格区分。

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
- 检视（B5）时须显式校验：README 是否混入技术/进度内容，违规即迁移修正。

---

# PART E · 附录

## E1 命令速查

> **`godot` 命令路径从系统环境变量 `$GODOT_HOME` 读取**（mac 上从 `~/.zshrc` 获取）。

```bash
$GODOT_HOME --headless --import                                                                        # 预热导入（P0-21 Step1）
$GODOT_HOME --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a test/ --ignoreHeadlessMode   # 跑测试（Step2）
$GODOT_HOME --headless --check-only --script scripts/xxx.gd                                            # 语法检查（备选）
$GODOT_HOME -e                                                                                         # 重载编辑器（B6/B7 前置）
```

> **qmd 命令**（详见 C5）：`qmd init` · `qmd collection add project "docs/,AGENTS.md,README.md,scripts/"` · `qmd embed -c project` · `qmd query "<query>"` · `qmd search "<kw>" -c project` · `qmd get <file>` · `qmd update && qmd embed -c project`。

## E2 MCP / Skill 索引

- **MCP（项目已配）**：`minimal-godot`（`get_diagnostics`/`scan_workspace_diagnostics`，G01）；`godot-ultimate`（lint/validate_scenes/validate_project/get_test_coverage/project_health 等，G02–G13）；`godot-mcp`（`create_scene`/`add_node`/`save_scene`/`load_sprite`，场景生成）；`aseprite`（`create_canvas`/`export_sprite`/`export_frame`/`export_spritesheet`/`draw_*` 等，像素美术创作与导出，产物存 `aseprite-assets/`，见 D1）。
- **Skill（项目内）**：`godot-architect` · `godot-best-practices` · `godot-gdscript-patterns` · `godot-code-review` · `godot-static-analysis` · `godot-ui`。
- **业界参考**：[AGENTS.md 规范](https://agents.md/) · [GdUnit4](https://github.com/godot-gdunit-labs/gdUnit4) · [GodotPrompter](https://github.com/jame581/GodotPrompter) · [Godot Autoload 文档](https://docs.godotengine.org/en/latest/tutorials/scripting/singletons_autoload.html)。

---

> 隐藏/工具目录（不纳入版本管理或自动生成）：`.opencode/`（OpenCode agents+skills）、`.zcode/`（ZCode 配置）、`.godot/`（引擎缓存）、`.qmd/`（qmd 索引缓存，见 C5）、`tmp/`（任务临时文件，任务结束删除，见 D1 P0-06）、`.env`（本地环境变量，勿提交）、`.gitignore` / `.gitattributes` / `.editorconfig`。
