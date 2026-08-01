---
description: 创建 `zcode` 定时任务，每20min定时执行
agent: build
---

# 任务：创建 `zcode` 定时任务

传入的`任务执行周期`为：`$ARGUMENTS`（默认为20min）


## 任务内容

```
## 任务

你是项目的自动开发助手。本次为定时触发，**无需与用户交互**，所有决策由你（AI）全权负责。请严格按以下流程执行。

## 项目信息
- Story 清单：docs/06_story/00_总表.md（总表）+ docs/06_story/S{NN}_{名称}/{NN}_{标题}.md（子 story）
- 项目宪法：AGENTS.md（PART B 主流程 / A2 门禁 / A3 Skill 链 / C3 经验沉淀 / C5 qmd 索引 / C6 状态追踪）

---

## 第一步：读取 story 清单并分类状态

读取所有子 story 文档（`docs/06_story/S*/*.md`）的 frontmatter `status:` 字段，按值分类（注意中英文混杂）：
- **【进行中】类**：`in_progress` / `开发中` / `阻塞中` / `blocked`
- **【待开发】类**：`todo` / `待开发`
- **【已完成】类**：`已通过验收` / `done` / `已完成`

可用命令快速统计：`grep -rh "^status:" docs/06_story/S*/*.md | sort | uniq -c`

## 第二步：跳过判定（关键，避免并发冲突）

按优先级判断，**满足任一立即停止本次任务，不做任何开发**：

1. **存在【进行中】类 story** → 说明上一个 story 仍在开发或阻塞中，**立即停止本次任务**（避免并发冲突）。在停止前用一句话说明哪个 story 在进行中。
2. **无【进行中】且无【待开发】story** → 全部已完成，**立即停止本次任务**。
3. 否则（无进行中、有待开发）→ 继续第三步。

## 第三步：确定下一个待开发 story

1. 列出所有【待开发】类子 story
2. 按依赖顺序排序：先按父 Story 编号（S01 < S02 < ... < S18），同父 Story 内按子编号（01 < 02 < ...）
3. 逐个检查 `depends_on` 字段：前置 story 必须全部为【已完成】类；前置未完成的跳过
4. 取**第一个**满足依赖条件的 story 作为本次开发目标（本次只开发**这一个** story）

## 第四步：调用 /godot-dev-stories 开发该 story

调用 `godot-dev-stories` 命令（或 Skill），参数为该 story 的 `story_id`（如 `S01-03`）。

**开发强制约束**：
- **完全遵循项目 AGENTS.md**（B1 启动准备读 MEMORY.md + 查 Wiki → B2 架构 → B3 TDD 小循环 → B4 可视化搭建 → B5 A2 全部门禁 → B7 收尾）
- **必须使用 TDD 方式开发**：加载 `test-driven-development` skill，每次 1 个测试方法 → 最小实现 → 重构
- **Skill 链不可绕过**：架构用 `godot-architect`、编码用 `godot-best-practices` / `godot-gdscript-patterns`、检视用 `godot-code-review`、质量验证用 `godot-static-analysis`
- **全程不调用 question 工具**，遇阻（门禁失败 / 验证失败 / 依赖问题）自行进入「阻塞中 → 最小改动修复 → 恢复开发中」循环，**禁止跳过或降级验收标准**
- **C1 可视化搭建**：AI 直接用 MCP `godot-mcp` 写初值，**不暂停等用户精调**
- **状态实时刷新**（C6）：编码开始立即把该 story status 置 `开发中`（frontmatter + 总表 🔵）；验收通过后置 `已通过验收`（frontmatter + 总表 ✅ + 统计计数）

## 第五步：界面开发的额外自动验证（替代 C2 玩家手工验证）

**若该 story 涉及界面开发**（含可见节点：Sprite2D / AnimatedSprite2D / Control / CollisionShape2D / Camera2D / TileMapLayer / 场景 / UI / 动画 / 粒子等），按 `docs/00_开发指南/01_快速开始.md`（不存在则按 README）：

1. 把游戏**导出为 web**（Godot HTML5 WebAssembly）
2. 用 **https** 启动游戏，端口固定 **8443**
3. 加载 `playwright-cli` skill，对照 story 验收标准做黑盒自动验证：
   - `playwright-cli open https://localhost:8443`（忽略自签证书警告）
   - `playwright-cli snapshot` / `playwright-cli screenshot --filename=.tmp/<story-id>-初始.png`
   - 操作模拟：`playwright-cli press Space/Enter/ArrowUp`、`playwright-cli click <x> <y>`
   - 数值/状态验证：`playwright-cli console`（读 Godot print 输出与 JS 报错）、`playwright-cli eval "<JS>"`
   - 每个关键操作后截图留证：`.tmp/<story-id>-<步骤>.png`
4. **验证通过后**（关键，用户明确要求）：
   - 停止 https 服务（杀掉监听 8443 的进程）
   - `playwright-cli close` 关闭浏览器（残留则 `playwright-cli kill-all`）
   - **删除 `build/` 目录**


若 story 纯逻辑（无界面，如域模型 / FSM / Evaluator），跳过本步，用 headless GdUnit4 测试替代验证。

## 第六步：收尾（B7 / C3）

story 验收通过后：
1. **提交代码**（commit 规范遵从宪法 §4.1：`feat: {描述}`）
2. **经验沉淀**：可复用经验按双区（通用 / 项目专属）追加到 `MEMORY.md`，**独立 commit**（`docs: 沉淀本次{story_id}经验`）
3. **qmd 索引刷新**（C5）：`qmd update && qmd embed -c {集合名}`
4. **开发完单个 story 后立即停止本次任务**（不要连续开发多个，下次定时触发再继续下一个）
5. **发送飞书通知**：飞书通知中包含验证截图

## 重要约束（贯穿全程）

- **本次只开发一个 story**，完成后立即停止
- 所有临时文件统一存 `.tmp/`，任务结束删除
- 代码除注释外无中文；标识符用英文/拼音
- 新增 .gd / 图片 / 音频 / .tscn 必跑 `$GODOT_HOME --headless --import` 生成 .uid / .import
- .tscn / .tres 禁手写，用 MCP `godot-mcp` 或编辑器生成
- 飞书通知凭证从项目根 `.env` 读取（FEISHU_APP_ID / FEISHU_APP_SECRET / FEISHU_USER_ID），禁止硬编码

## 执行报告

任务结束（无论是否开发了 story）输出简短报告：本次是「跳过」还是「开发了 story」、目标 story_id、状态变更、门禁通过情况、是否有遗留阻塞。
```
