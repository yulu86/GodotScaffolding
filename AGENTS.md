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
创意探索 -> 低保真设计 -> 开源免费资产获取 -> 游戏资产分析 -> 高保真设计 -> 需求文档 -> 启动准备 -> 架构与模块设计 -> TDD开发 -> 质量门禁 -> 黑盒验收
```

> 每个 `->` 节点完成后，立即执行横切规则「收尾沉淀」。

### 完整阶段表

| # | 阶段 | 强制 Skill / 工具 | 产物 / 门禁 | 宪法编号 |
|---|------|------------------|------------|:------:|
| 1 | 创意探索 | `brainstorming` | 设计意图 / 约束 / 成功标准 | 前置 |
| 2 | 低保真设计 | Godot 灰盒 / `excalidraw-diagram-generator` | 核心玩法循环验证（有趣性/可行性） | 前置 |
| 3 | 开源免费资产获取 | Kenney / OpenGameArt / itch.io | 免费素材包（下载走 hf-mirror / gh-proxy 加速） | 前置 |
| 4 | 游戏资产分析 | `sprite-analyzer`【项目级】 | tile 网格 / 动画帧分组 / 精灵资源文档 | 前置 |
| 5 | 高保真设计 | `frontend-design` + `gsap-*` 系列 | HTML 交互原型（视觉/动效/交互定稿） | 前置 |
| 6 | 需求文档 | — | Feature/Story + 验收标准 AC（`docs/05_需求`·`docs/06_story`） | 前置 |
| 7 | 启动准备 | `qmd` / `wiki-query` | 读 `MEMORY.md` + 查 LLM Wiki | B1 |
| 8 | 架构与模块设计 | `godot-architect`【项目级】（仅设计不写码） | 场景树 / 状态机 / 模块 / 接口 | B2 |
| 9 | TDD 开发 | `test-driven-development` + `godot-best-practices` + `godot-mcp` | 红→绿→重构；`.tscn`/`.tres` 禁手写 | B3/B4 |
| 10 | 质量门禁 | `gdlint`/`gdformat` + GdUnit4 + code review | **全过方可继续**，不过进阻塞修复循环 | B5/A2 |
| 11 | 黑盒验收 | `godot-web-verify` / `playwright-cli` | web 导出验 AC；纯逻辑用 headless GdUnit4 | C2 |

### 各阶段详解

**阶段 1 · 创意探索**
- **目的**：明确做什么游戏/功能、为谁做、成功标准是什么
- **强制 Skill**：`brainstorming`（探索意图 → 提 2-3 方案 → 定设计 → 用户批准）
- **完成标志**：用户确认设计方向

**阶段 2 · 低保真设计**
- **目的**：用最低成本验证核心玩法循环是否有趣、可行
- **工具**：Godot 灰盒原型 / 纸面原型 / `excalidraw-diagram-generator`（画玩法流程）
- **完成标志**：核心玩法循环验证通过（fun factor 达标）

**阶段 3 · 开源免费资产获取**
- **目的**：获取免费可用的美术/音效资产
- **来源**：Kenney.nl / OpenGameArt / itch.io 免费区
- **门禁**：遵守素材许可协议；下载走加速（huggingface 加 `hf-mirror.com`，github 加 `gh-proxy.org`）
- **产物**：素材包入项目资源目录

**阶段 4 · 游戏资产分析**
- **目的**：识别精灵表结构，为后续开发做准备
- **强制 Skill**：`sprite-analyzer`【项目级】
- **产物**：精灵资源文档（tile 网格 / 动画帧分组）

**阶段 5 · 高保真设计**
- **目的**：基于真实资产定稿视觉风格、动效与交互
- **强制 Skill**：`frontend-design` + `gsap-*` 系列（`gsap-core`/`gsap-timeline`/`gsap-scrolltrigger` 等）
- **产物**：HTML 交互原型（浏览器可预览，与后续 web 验收同源）
- **完成标志**：视觉/动效/交互定稿

**阶段 6 · 需求文档**
- **目的**：冻结需求，定义可验证的验收标准
- **产物**：Feature/Story 文档 + 验收标准 AC（`docs/05_需求`、`docs/06_story`）
- **完成标志**：每条需求都有对应可测的 AC

**阶段 7 · 启动准备（B1）**
- **目的**：回顾已有经验与知识，避免重复造轮子（**先查再设计**）
- **强制 Skill**：`qmd`（查 `MEMORY.md`）/ `wiki-query`（查 LLM Wiki）
- **完成标志**：已检索 MEMORY + Wiki，确认可复用经验

**阶段 8 · 架构与模块设计（B2）**
- **目的**：设计场景树结构、状态机、模块划分与接口
- **强制 Skill**：`godot-architect`【项目级】（**仅设计，不写代码**）
- **产物**：架构方案文档
- **完成标志**：架构方案通过评审

**阶段 9 · TDD 开发（B3 / B4）**
- **目的**：以测试驱动实现功能
- **强制 Skill**：`test-driven-development`（1 个测试 → 最小实现 → 重构）+ `godot-best-practices`【项目级】（编码规范）+ `godot-mcp`（搭建场景）
- **编码规范**：所有 `.gd` 代码**必须**遵循 `specs/01_GDScript开发规范.md`（24 条，每条含正例/反例），编码前加载并应用
- **门禁**：`.tscn`/`.tres` **禁手写**，用 MCP 或编辑器生成；新增 `.gd`/图片/音频/`.tscn` 必跑 `--headless --import` 生成 `.uid`/`.import`
- **产物**：通过单元测试的功能代码

**阶段 10 · 质量门禁（B5 / A2）**
- **目的**：保证代码质量，**全过方可继续**
- **门禁清单**：`gdlint` / `gdformat`（lint 与格式）+ GdUnit4 单元测试 + code review
- **完成标志**：全部门禁通过；未过则进入「阻塞 → 最小改动修复 → 重跑」循环，**禁止跳过或降级验收标准**

**阶段 11 · 黑盒验收（C2）**
- **目的**：对照 AC 做端到端验证
- **强制 Skill**：`godot-web-verify`【项目级】/ `playwright-cli`（界面类）/ headless GdUnit4（纯逻辑类）
- **流程**：导出 web → https 启动（端口 8443）→ playwright 按条验 AC（截图/console/操作模拟）→ 验毕停服务、关浏览器、删 `build/`
- **完成标志**：所有 AC 验证通过

### 横切规则：收尾沉淀（B7 / C3 / C5 / C6）— 每个阶段完成后必做

> 无论刚完成哪个阶段（1~11），都**必须**立即执行以下收尾闭环，而非等到流程最末：

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
├── project.godot                  # Godot 工程配置（阶段8前必建）
├── export_presets.cfg             # web 导出预设（阶段11）
├── AGENTS.md                      # 项目宪法（含开发主流程）
├── MEMORY.md                      # 经验沉淀（横切 C3）
├── README.md
│
├── docs/                          # ── 文档类交付物（编号对齐11阶段）──
│   ├── 00_开发指南/               # 流程/目录规范/快速开始/环境
│   ├── 01_创意探索/               # 阶段1
│   ├── 02_低保真设计/             # 阶段2
│   ├── 03_资产/                   # 阶段3获取 + 阶段4分析
│   ├── 04_高保真设计/             # 阶段5 HTML+gsap 原型
│   ├── 05_需求/                   # 阶段6 Feature + AC
│   ├── 06_story/                  # story 拆分 + 00_总表.md
│   ├── 07_架构/                   # 阶段8 架构方案
│   └── 08_验收/                   # 阶段11 验收报告
│
├── scenes/                        # ── 所有 .tscn 场景（按实体类型）──
│   ├── _prototype/                # 阶段2 灰盒原型（临时）
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