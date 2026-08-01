---
description: 开发指定Feature剩余所有未完成的story（支持传入多个Feature），全程AI自主遵循当前项目Godot宪法迭代开发并做功能验证
agent: build
---

# 任务：AI 自主开发剩余所有未完成的 story

传入的 Feature 列表为：`$ARGUMENTS`（如 `F02 F03`，按依赖顺序逐个开发）

## 核心立场（本命令的全部特殊性所在）

> 开发流程的「怎么做」**完全遵循项目 `AGENTS.md`**（PART B 主流程、A2 门禁、A3 Skill 链、C3/C5 收尾），本命令**不重复**这些内容。本命令只规定 AI 自主开发模式下与有人类陪伴时的**差异**：

| 环节 | 有人类陪伴时（宪法默认） | AI 自主模式（本命令覆盖） |
|------|------------------------|------------------------|
| **协作关卡①（C1 可视化搭建）** | AI 写初值 → 暂停等用户精调 | AI 用 `【MCP】` `godot-mcp` 直接写初值，**不暂停、不等精调** |
| **协作关卡②（C2 玩家手工验证）** | 玩家试玩黑盒验收 | 用 `【Skill】` `playwright-cli` 自动验证替代（流程见步骤 2） |
| **状态反馈** | 用 `question` 工具暂停等用户选择 | **全程不调用 `question`**，遇阻自行进入「阻塞→修复→恢复」循环（见步骤 4） |
| **Story 状态枚举** | 3 态（todo/in_progress/done） | **4 态**（见下方状态管理），新增 `阻塞中` 表达 AI 自行处理的遇阻 |

除以上四点覆盖外，其余**一律按宪法执行**（B1 启动准备、B2 架构、B3 TDD、B4 搭建、B5 质量门禁、B7 收尾、C3 经验沉淀、C5 qmd 索引等），不再赘述。

## Story 状态管理（AI 自主特有，4 态状态机）

实时维护每个 story 的状态，枚举固定 4 种：

| 状态 | 含义 | 触发时机 |
|------|------|---------|
| `待开发` | 进入队列初始态 | story 依赖分析完成 |
| `开发中` | 正在编码 / 验证 / 修复 | 开始编码；从阻塞中解除 |
| `阻塞中` | **AI 自主可处理的**遇阻（门禁失败 / 验证失败 / 依赖或环境问题） | 遇阻瞬间 |
| `已通过验收` | 功能验证全过，可收尾 | 步骤 2 全通过 |

**流转**：`待开发 → 开发中 ⇄ 阻塞中 → 已通过验收`

**写入规则**（每次变更**立即**写，禁止滞后）：
- **位置**：该 story 文档（`docs/06_story/` 下，无则用 `05_需求/` 对应文件）
- **方式**：frontmatter `status:` 字段（如 `status: 开发中`）；无 frontmatter 则标题下首行标记（如 `> 状态：开发中`）
- **阻塞必记原因**：置 `阻塞中` 时**必须**在同一文档记录阻塞原因与已尝试的修复

## 单个 story 工作流

### 步骤 1 — 编码（按宪法 B1→B5 执行）
> 进入前先把该 story 状态置为 `开发中`（立即写入）

严格按宪法 PART B 的 B1（启动准备）→ B2（架构）→ B3（TDD 小循环）→ B4（可视化搭建，AI 直接写初值不暂停）→ B5（A2 全部门禁必过）执行。

**门禁未过的处理**：立即将该 story 置 `阻塞中` 并记录失败项 → 按步骤 4 修复 → 恢复 `开发中` → 重跑门禁。

### 步骤 2 — 自动功能验证（替代宪法 C2 玩家手工验证）

对照该 story 验收标准（`docs/06_story/`，无则用 `05_需求/` 功能点）做**黑盒自动验证**：

1. 按 `docs/00_开发指南/01_快速开始.md`（不存在则按 `README.md`）把游戏导出为 web
2. 用 `https` 启动游戏，端口固定 `8443`
3. 加载 `【Skill】` `playwright-cli`，按以下流程逐条验证 story 验收标准：

   ```bash
   playwright-cli open https://localhost:8443      # 打开游戏（忽略自签证书警告）
   playwright-cli snapshot                          # 确认页面加载（Godot web 导出为 canvas，快照主要确认 canvas 存在）
   playwright-cli screenshot --filename=.tmp/<story-id>-初始.png   # 截取初始画面作为证据
   ```

   **画面验证**：`playwright-cli screenshot` 截图对照预期表现（精灵位置 / UI 布局 / 场景切换）

   **操作模拟**（按验收标准需要的 Input Action 映射到键盘/鼠标）：
   - 键盘：`playwright-cli press Space` / `press ArrowUp` / `press Enter`
   - 鼠标：`playwright-cli click <x> <y>` 或 `playwright-cli mousemove <x> <y>` + `playwright-cli mousedown`
   - 按键组合：`playwright-cli keydown Shift` → 操作 → `playwright-cli keyup Shift`

   **数值/动画/音效验证**（Godot web 导出无 DOM，靠日志与 JS 桥接）：
   - `playwright-cli console` — 读取 Godot `print()` 输出与 JS 报错（验证数值变化、状态切换、资源加载）
   - `playwright-cli eval "<JS 表达式>"` — 若游戏暴露了 JS 接口（如 `Engine` 对象、自定义全局变量），直接读取游戏内状态
   - 每个关键操作后 `playwright-cli screenshot --filename=.tmp/<story-id>-<步骤>.png` 留证

4. **刷新状态**：全过 → `已通过验收`；任一不过 → `阻塞中` + 记录失败现象（附 `.tmp/` 截图与 console 日志） → 进入步骤 4
5. 验证结束后 `playwright-cli close` 关闭浏览器（步骤 3 收尾会再确认）

### 步骤 3 — 收尾（按宪法 B7 / C3 执行）

功能验证通过并**提交代码 commit**（格式遵从宪法 §4.1）后：

1. **经验沉淀**（C3）：可复用经验按双区追加到 `MEMORY.md`，**独立 commit**；改动 `.md` 后用 `【Skill】` `qmd` 刷新索引（C5）
2. **清理本 story 验证产物**（AI 自主特有）：
   - 终止步骤 2 启动的本地 https 服务进程
   - `playwright-cli close` 关闭浏览器（若步骤 2 未关）；若仍有残留进程用 `playwright-cli kill-all`
   - 删除 `build/` 目录
   - 删除 `.tmp/` 下的验证截图（保留到收尾仅用于阻塞排查，story 通过后清理）

### 步骤 4 — 遇阻修复循环（AI 自主核心机制）

> 这是 AI 自主模式下替代「向用户提问」的自愈闭环。

进入 `阻塞中` 后：
1. 记录阻塞原因到 story 文档
2. 最小改动修复（禁止扩大改动范围）
3. 重跑相关门禁 / 重做步骤 2 验证
4. 通过 → 恢复 `开发中` 或推进到下一态；仍失败 → 回到第 1 步继续，**禁止跳过或降级验收标准**

## 全部 Feature 完成后的总收尾

所有 story 开发完毕后，用 `【Skill】` `lark-im` 发飞书通知（凭证读取遵从宪法 C3），汇总：
- 完成的 Feature 与 story 清单
- **各状态 story 统计**（`待开发` / `开发中` / `阻塞中` / `已通过验收`）——若仍有非「已通过验收」态须重点说明
- 变更文件数、门禁通过情况、经验沉淀要点
