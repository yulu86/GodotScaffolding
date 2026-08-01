# Godot 游戏开发宪法（项目级）

> **Godot 4.x / GDScript 专属宪法**，条款为最高优先级指令，不可协商、不可绕过。
> 用户指令优先级高于 Skill。

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