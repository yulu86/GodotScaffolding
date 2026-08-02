# Godot 游戏开发宪法（项目级）

> **Godot 4.x / GDScript 专属宪法**，条款为最高优先级指令，不可协商、不可绕过。
> 本文档为只读文档。
> 用户指令优先级高于 Skill。

---

## 游戏迭代开发主流程（端到端）

> **强制约束**：AI 进行任何游戏功能开发时，**必须**严格按本流程顺序执行，不得跳步、不得降级验收标准。
> 每个阶段完成后**必须**立即执行「收尾沉淀」（见末尾横切规则），而非仅在流程末尾执行一次。
> Skill 优先级：**流程类 Skill 优先**（brainstorming / systematic-debugging 决定「怎么做」），**实现类 Skill 其次**。

### 一句话总览（`->` 流程链）

```
创意探索 -> 开源免费资产获取 -> 游戏资产分析 -> 高保真设计 -> 需求文档 -> 启动准备 -> 架构与模块设计 -> TDD开发 -> 质量门禁 -> 黑盒验收
```

> 每个 `->` 节点完成后，立即执行横切规则「收尾沉淀」。

### 完整阶段表

| # | 阶段 | 强制 Skill / 工具 | 产物 / 门禁 | 宪法编号 |
|---|------|------------------|------------|:------:|
| 1 | 创意探索 | `brainstorming` | GDD 文档（游戏设计文档：设计意图 / 约束 / 成功标准） | 前置 |
| 2 | 开源免费资产获取 | Kenney / OpenGameArt / itch.io | 免费素材包（下载走 hf-mirror / gh-proxy 加速） | 前置 |
| 3 | 游戏资产分析 | `sprite-analyzer`【项目级】 | tile 网格 / 动画帧分组 / 精灵资源文档 | 前置 |
| 4 | 高保真设计 |`using-superpowers` `brainstorming`（Visual Companion）+ `frontend-design`/`web-artifacts-builder` + `gsap-*` 系列 + Godot Theme（`.tres` 代码生成） | 视觉规范 + Theme 资源 + 界面流转图 + 逐界面 HTML 高保真 + 动效 + 设计文档（嵌截图/HTML 链接） | 前置 |
| 5 | 需求文档 | — | Feature/Story + 验收标准 AC（`docs/05_需求`·`docs/06_story`） | 前置 |
| 6 | 启动准备 | `qmd` / `wiki-query` | 读 `MEMORY.md` + 查 LLM Wiki | B1 |
| 7 | 架构与模块设计 | `godot-architect`【项目级】（仅设计不写码） | 场景树 / 状态机 / 模块 / 接口 | B2 |
| 8 | TDD 开发 | `test-driven-development` + `godot-best-practices` + `godot-mcp` | 红→绿→重构；`.tscn`/`.tres` 禁手写 | B3/B4 |
| 9 | 质量门禁 | `gdlint`/`gdformat` + GdUnit4 + code review | **全过方可继续**，不过进阻塞修复循环 | B5/A2 |
| 10 | 黑盒验收 | `godot-web-verify` / `playwright-cli` | web 导出验 AC；纯逻辑用 headless GdUnit4 | C2 |

### 各阶段详解

**阶段 1 · 创意探索**
- **目的**：明确做什么游戏/功能、为谁做、成功标准是什么
- **强制 Skill**：`brainstorming`（探索意图 → 提 2-3 方案 → 定设计 → 用户批准）
- **模板规范**：GDD 文档**必须**遵循 `specs/05_GDD模板.md` 结构填写，撰写前加载并参考
- **产物**：GDD 文档（游戏设计文档：设计意图 / 约束 / 成功标准，存放于 `docs/01_创意探索/`）
- **完成标志**：GDD 文档经用户确认设计方向

**阶段 2 · 开源免费资产获取**
- **目的**：获取免费可用的美术/音效资产
- **来源**：Kenney.nl / OpenGameArt / itch.io 免费区
- **门禁**：遵守素材许可协议；下载走加速（huggingface 加 `hf-mirror.com`，github 加 `gh-proxy.org`）
- **及时导入（硬门禁）**：资产放入项目 `assets/` 后，**必须立即**跑 `--headless --import` 生成 `.import`/`.uid`，否则后续无法被场景/脚本引用（命令见 `specs/09_Godot环境与命令手册.md` §3.1.1）
- **产物**：素材包入项目资源目录

**阶段 3 · 游戏资产分析**
- **目的**：识别精灵表结构，为后续开发做准备
- **强制 Skill**：`sprite-analyzer`【项目级】
- **产物**：精灵资源文档（tile 网格 / 动画帧分组）

**阶段 4 · 高保真设计**
- **目的**：基于真实资产（阶段3精灵资源文档）定稿视觉规范、界面流转、逐界面设计、动效与可交互原型，并沉淀为 Godot Theme 资源
- **强制 Skill**：`brainstorming`（启用 **Visual Companion** 浏览器伴侣，与用户实时可视化定稿）+ `frontend-design`/`web-artifacts-builder`（HTML 高保真）+ `gsap-*` 系列（动效）
- **强制工作流（按序执行，每步需用户确认方可进入下一步）**：
  1. **视觉规范**：开启 `brainstorming` 的 **Visual Companion**（`--open`），与用户**一起**基于游戏资产定稿视觉规范——配色（主/辅/强调/背景/文字，含色值）、字体与字号阶梯、间距栅格、圆角/阴影/描边、控件样式（按钮/面板/输入框/滚动条等）、图标与图示风格
  2. **Godot Theme 资源**：用**专用 `.gd` 脚本**（代码动态生成，**禁止手写 `.tres` 文本**）将上一步视觉规范参数化为 `Theme` 资源并保存为 `.tres`（字体/图标引用游戏资产；脚本→`scripts/resources/`，资源→`data/ui/`）。**硬门禁**：生成后**必须立即**跑 `--headless --import`（命令见 `specs/09_Godot环境与命令手册.md` §3.1.1），否则后续 UI 场景引用报 `uid not found`
  3. **界面流转流程**：与用户**一起**在 `Visual Companion` 中梳理全部界面（菜单/暂停/HUD/结算/设置等）及流转关系，绘制界面流转图（Mermaid `stateDiagram`/`flowchart`），标注触发条件、入口/出口、返回路径
  4. **逐界面详细设计**：对每个界面单独与用户定稿——布局（线框）、信息层级、控件清单与状态、交互行为、引用的视觉规范条目；每个界面在 Visual Companion 中**可视化对比**多方案后定稿
  5. **HTML 高保真**：用 `frontend-design`/`web-artifacts-builder` 为每个定稿界面产出**浏览器可预览的 HTML**，颜色/字体/间距/控件**严格对齐**视觉规范与 Godot Theme 取值
  6. **动效设计**：用 `gsap-*` 系列（`gsap-core`/`gsap-timeline`/`gsap-scrolltrigger` 等）为 HTML 原型叠加界面转场、控件反馈、入场/退场、强调等动效，并与用户在浏览器中定稿
- **产物（全部归档到 `docs/04_高保真设计/`）**：
  - `视觉规范.md`（配色/字体/间距/控件样式数值表）
  - `界面流转.md`（嵌 Mermaid 流转图）
  - 各界面 HTML 高保真文件（`.html`，浏览器可预览）
  - 各界面截图（`.png`，浏览器渲染截取，按界面命名）
  - `设计说明.md`：逐界面说明 + **必须内嵌**对应截图（`![](./<界面名>.png)`）与 HTML 链接（`[在线预览](./<界面名>.html)`）
  - Godot Theme 资源 `data/ui/theme_default.tres` + 生成脚本 `scripts/resources/`
- **完成标志**：视觉规范、Theme 资源、界面流转图、全部界面 HTML 高保真 + 截图 + 动效经用户逐项确认定稿；`设计说明.md` 内嵌的截图与 HTML 链接全部可访问
- **门禁**：`.tres` **禁手写文本**（仅由 `.gd` 脚本生成）；新增 `.tres`/`.gd` 后**必须立即** `--headless --import`

**阶段 5 · 需求文档**
- **目的**：冻结需求，定义可验证的验收标准
- **模板规范**：Story 文档**必须**遵循 `specs/06_story文档模板.md` 结构填写，撰写前加载并参考
- **产物**：Feature/Story 文档 + 验收标准 AC（`docs/05_需求`、`docs/06_story`）
- **完成标志**：每条需求都有对应可测的 AC
- **拆分准则**：Feature → Story 拆分遵循 INVEST·≤20min（详见下方「Story 拆分准则」专节）

**阶段 6 · 启动准备（B1）**
- **目的**：回顾已有经验与知识，避免重复造轮子（**先查再设计**）
- **强制 Skill**：`qmd`（查 `MEMORY.md`）/ `wiki-query`（查 LLM Wiki）
- **完成标志**：已检索 MEMORY + Wiki，确认可复用经验

**阶段 7 · 架构与模块设计（B2）**
- **目的**：设计场景树结构、状态机、模块划分与接口
- **强制 Skill**：`godot-architect`【项目级】（**仅设计，不写代码**）
- **模板规范**：架构与模块设计**必须**遵循 `specs/07_架构设计说明书模板.md` / `specs/08_模块设计说明书模板.md` 结构填写，撰写前加载并参考
- **产物**：架构设计说明书 + 各模块设计说明书（`docs/07_架构/`）
- **完成标志**：架构方案通过评审

**阶段 8 · TDD 开发（B3 / B4）**
- **目的**：以测试驱动实现功能
- **强制 Skill**：`test-driven-development`（1 个测试 → 最小实现 → 重构）+ `godot-best-practices`【项目级】（编码规范）+ `godot-mcp`（搭建场景）
- **编码规范**：所有 `.gd` 代码**必须**遵循 `specs/01_GDScript开发规范.md`（24 条，每条含正例/反例），编码前加载并应用
- **场景规范**：所有 `.tscn` 场景**必须**遵循 `specs/02_场景开发规范.md`（19 条，每条含正例/反例），搭建前加载并应用
- **测试规范**：TDD 开发**必须**遵循 `specs/03_TDD测试规范.md`（18 条，每条含正例/反例），写测试前加载并应用
- **场景禁手写**：`.tscn`/`.tres` **禁手写**，用 MCP 或编辑器生成
- **及时导入（硬门禁）**：每新增**游戏资源**（图片/音频/字体/3D/`.gdshader`）/ **GDScript**（`.gd`）/ **Scene**（`.tscn`）后，**必须立即**跑 `--headless --import` 生成 `.uid`/`.import`（命令见 `specs/09_Godot环境与命令手册.md` §3.1）；**禁止攒批**——否则后续场景/脚本引用报 `uid not found`
- **CLI 手册**：Godot 可执行定位与命令行用法**必须**遵循 `specs/09_Godot环境与命令手册.md`（导入/检查/导出/headless，适用阶段 7-10）
- **产物**：通过单元测试的功能代码

**阶段 9 · 质量门禁（B5 / A2）**
- **目的**：保证代码质量，**全过方可继续**
- **门禁清单**：`gdlint` / `gdformat`（lint 与格式）+ GdUnit4 单元测试 + code review（命令行用法见 `specs/09_Godot环境与命令手册.md` §3.3 `--check-only` / §4 配套工具）
- **检视规范**：code review **必须**遵循 `specs/04_代码检视规范.md`（18 条，每条含正例/反例），检视前加载并应用
- **完成标志**：全部门禁通过；未过则进入「阻塞 → 最小改动修复 → 重跑」循环，**禁止跳过或降级验收标准**

**阶段 10 · 黑盒验收（C2）**
- **目的**：对照 AC 做端到端验证
- **强制 Skill**：`godot-web-verify`【项目级】/ `playwright-cli`（界面类）/ headless GdUnit4（纯逻辑类）（Web 导出命令见 `specs/09_Godot环境与命令手册.md` §3.4 `--export-release`）
- **流程**：导出 web → https 启动（端口 8443）→ playwright 按条验 AC（截图/console/操作模拟）→ 验毕停服务、关浏览器、删 `build/`
- **完成标志**：所有 AC 验证通过

### Story 拆分准则（INVEST · ≤20min）

> 适用阶段 5：Feature（`docs/05_需求`）→ Story（`docs/06_story`）。每个 Story 必须满足以下 INVEST 适配原则。

| 原则 | 标准 | 本项目适配 |
|------|------|------------|
| **I** Independent 独立 | 尽量可独立开发 | 游戏功能常耦合，**允许依赖但必须显式标注**（frontmatter 记前置 Story） |
| **N** Negotiable 可协商 | 实现方式留空间 | AC 冻结需求，实现细节可协商 |
| **V** Valuable 有价值 | 对 Feature 有可验证贡献 | 极细粒度下「价值=可测增量」，即使不端到端可玩也要有可验证断言 |
| **E** Estimable 可估算 | 能给出预估 | 无法估算=拆分不清，继续分解 |
| **S** Small 足够小 | **硬约束：单 Story 开发预估 ≤ 20min** | **超标必须拆分** |
| **T** Testable 可测试 | 必有可测 AC | Story 层用 **GdUnit4（headless）** 验收；端到端 **web 黑盒验收（阶段10）在 Feature 层**（多 Story 组合后）进行 |

**拆分触发条件（预估 >20min 时按序尝试）**：
- 按工作流步骤切（一个步骤一个 Story）
- 按 happy-path / 边界异常切（主路径先行，异常单独成 Story）
- 按数据操作切（CRUD 各一）
- 按接口与实现切（数据结构/接口先行，逻辑实现后续）

**与验收流程衔接**：
- Story 完成（阶段 8-9）= GdUnit4 单测/集成测试通过 → `status: done`
- Feature 完成（阶段 10）= 所属 Story 全 done 后，组合走 web 黑盒验收

### 横切规则：收尾沉淀（B7 / C3 / C5 / C6）— 每个阶段完成后必做

> 无论刚完成哪个阶段（1~10），都**必须**立即执行以下收尾闭环，而非等到流程最末：

1. **提交代码 commit**（规范遵从 §4.1：`{type}: {描述}`）
2. **经验沉淀（C3）**：可复用经验按双区追加到 `MEMORY.md`，**独立 commit**（`docs: 沉淀经验`）
3. **qmd 索引刷新（C5）**：改动了 `.md` 就执行 `qmd update && qmd embed`
4. **状态追踪（C6）**：更新 story 状态（frontmatter `status:` + `docs/06_story/00_总表.md`）
5. **飞书通知**：关键节点用 `lark-im` 通知用户（凭证从 `.env` 读 `FEISHU_APP_ID`/`FEISHU_APP_SECRET`，禁止硬编码）

---

## 项目目录结构（ASCII）

> 详细目录用途、阶段交付物映射、命名规范见 `docs/00_开发指南/02_目录规范.md`；本节为快速参考。
> **设计原则**：`scripts/`=所有 `.gd`、`scenes/`=所有 `.tscn`、`assets/`=媒体、`data/`=`.tres`、`shaders/`=`.gdshader`。

```
GodotScaffolding/
├── project.godot                  # Godot 工程配置（阶段7前必建）
├── export_presets.cfg             # web 导出预设（阶段10）
├── AGENTS.md                      # 项目宪法（含开发主流程）
├── MEMORY.md                      # 经验沉淀（横切 C3）
├── README.md
│
├── docs/                          # ── 文档类交付物（编号对齐10阶段）──
│   ├── 00_开发指南/               # 流程/目录规范/快速开始/环境
│   ├── 01_创意探索/               # 阶段1
│   ├── 03_资产/                   # 阶段2获取 + 阶段3分析
│   ├── 04_高保真设计/             # 阶段4 HTML+gsap 原型
│   ├── 05_需求/                   # 阶段5 Feature + AC
│   ├── 06_story/                  # story 拆分 + 00_总表.md
│   ├── 07_架构/                   # 阶段7 架构方案
│   └── 08_验收/                   # 阶段10 验收报告
│
├── scenes/                        # ── 所有 .tscn 场景（按实体类型）──
│   ├── actors/  levels/  objects/  ui/
│   └── components/                # 可复用组件场景
│
├── scripts/                       # ── 所有 .gd 脚本 ──
│   ├── classes/  utils/
│   ├── autoloads/                 # 全局单例
│   └── resources/                 # Resource 类定义（extends Resource）
│
├── assets/                        # ── 媒体资源（无代码）──
│   └── sprites/  audio/  fonts/  textures/  themes/
│
├── data/                          # .tres 数据实例（Resource 取值）
├── shaders/                       # .gdshader 着色器
├── addons/                        # 插件（GdUnit4 等）
├── test/                          # ── 测试（分层 + 镜像）──
│   ├── unit/                      # 单测，子目录必须镜像源码相对路径
│   └── integration/               # 集成测试
│
├── build/                         # web 导出产物（临时，验后删）
└── .tmp/                          # 验收证据/中间产物（临时，任务后删）
```

---

## 附录：可用 Skill 速查表

> **使用原则**：当任务与下表任一 Skill 触发场景相符（哪怕仅 1% 可能）时，**必须**先调用对应 Skill 再行动。
> Skill 优先级：**流程类 Skill 优先**（brainstorming / systematic-debugging 决定「怎么做」），**实现类 Skill 其次**。
> 标记 `【项目级】` 的 Skill 来自本项目 `.opencode/skills/`；其余为全局可用。

### A. Godot 游戏开发（项目级）

| Skill | 触发场景 |
|-------|---------|
| `godot-architect`【项目级】 | 设计新功能架构、规划场景树结构、设计状态机、系统模块划分、制定技术方案时。**仅设计，不写代码** |
| `godot-best-practices`【项目级】 | 生成 GDScript 代码、创建场景、设计架构、实现状态机/对象池/存档系统、autoload/@export/类型标注等规范时 |
| `godot-web-verify`【项目级】 | Godot 导出 Web 版并用 playwright 黑盒自动验收（场景切换/配色/按钮交互/数值日志）时 |

### B. 美术资源生成

| Skill | 触发场景 |
|-------|---------|
| `sprite-analyzer`【项目级】 | 分析精灵表资源，识别 tile 网格、tile 内容、动画帧分组，生成精灵资源文档时 |

### C. Skill 与自身管理

| Skill | 触发场景 |
|-------|---------|
| `using-superpowers` | 每次对话开始时确立如何查找使用 skills（**已内联加载，勿重复调用**） |

### D. 知识与文档

| Skill | 触发场景 |
|-------|---------|
| `qmd` | **查看/查找 md 文件时必须优先用**；修改 md 后必须用 `qmd update`/`qmd embed` 刷新索引 |
| `wiki-query` | 基于 LLM Wiki 回答提问（产出有价值分析时主动回填为新页） |

### E. 飞书（Lark）集成

> AI 通知用户**优先**用飞书（`lark-im`）；凭证从 `FEISHU_APP_ID`/`FEISHU_APP_SECRET` 环境变量读取。

| Skill | 触发场景 |
|-------|---------|
| `lark-im` | 收发消息、管理群聊成员、上传下载图片文件（**AI 通知用户的首选渠道**） |
| `lark-doc` | 创建/编辑飞书文档、读取内容、插入图片、搜索云空间文档 |

### F. Web 前端与动画

| Skill | 触发场景 |
|-------|---------|
| `frontend-design` | 构建前端界面时创建独特、生产级、高设计质量的 UI（组件/页面/artifacts/应用） |
| `web-artifacts-builder` | 创建复杂多组件的 claude.ai HTML artifacts（含状态管理/路由/shadcn） |
| `theme-factory` | 用主题为 artifacts 设置样式（10 种预设主题或自定义） |
| `gsap-core` | GSAP 核心 API（to/from/fromTo/缓动/duration/stagger/matchMedia） |
| `gsap-timeline` | GSAP 时间线（gsap.timeline/位置参数/嵌套/编排关键帧序列） |
| `gsap-scrolltrigger` | GSAP ScrollTrigger（滚动联动动画/锁定/scrub/视差） |
| `gsap-react` | GSAP 在 React/Next.js 中（useGSAP/ref/context/卸载清理） |
| `gsap-frameworks` | GSAP 在 Vue/Nuxt/Svelte 中（生命周期/作用域/卸载清理） |
| `gsap-plugins` | GSAP 插件（注册/ScrollToPlugin/Flip/Draggable/SplitText 等） |
| `gsap-performance` | GSAP 性能优化（优先 transform/避免布局抖动/will-change/批处理） |
| `gsap-utils` | GSAP 工具函数（clamp/mapRange/random/snap/wrap/pipe 等） |

### G. 浏览器与 CLI 工具

| Skill | 触发场景 |
|-------|---------|
| `playwright-cli` | 浏览器自动化、测试网页、Playwright 测试。**必须用本地 Chrome**（`--browser=chrome`） |
| `webapp-testing` | 用 Playwright 交互测试本地 web 应用（截图/日志/调试 UI） |

---

> **降级策略提醒**：当某 Skill 不可用（未安装/服务未运行/命令报错）时，方可降级使用通用工具（read/grep/glob/bash/webfetch），并在回复中注明降级原因。