# 🏛️ 项目宪法（CONTRIBUTING.md）

> **⚠️ 重要提示：本文档为本项目的核心宪法，所有规则必须严格遵守，不得违反。**

---

## ⭐ P0 - 核心原则（违反即项目失败）

### 代码设计原则
- **P0-1** 代码必须满足 SOLID 原则
  - Single Responsibility Principle（单一职责原则）
  - Open/Closed Principle（开闭原则）
  - Liskov Substitution Principle（里氏替换原则）
  - Interface Segregation Principle（接口隔离原则）
  - Dependency Inversion Principle（依赖倒置原则）

- **P0-2** 代码必须满足 DRY 原则（Don't Repeat Yourself）

### 代码质量
- **P0-3** 禁止在编码时出现语法错误，违反者视为严重违规
- **P0-4** 代码中除注释外禁止使用中文（包括变量名、函数名、类名等）

---

## 🔴 P1 - 强制规范（必须遵守）

### 开发流程
- **P1-1** 开发 Godot 项目时，必须使用 `godot-developer` 技能进行协同开发
- **P1-2** 必须使用 `godot-developer` 按照 TDD 微循环完成代码开发
- **P1-3** 必须使用 `context7` 工具获取 GDScript 语法和 Godot 引擎 API/SDK 文档

### 编码规范
- **P1-4** 优先选择 AnimationPlayer 节点，而非 AnimatedSprite2D 节点
- **P1-5** 在 `项目设置` - `全局设置` 中配置为 singleton 的 .gd 文件中禁止写 `class_name`
- **P1-6** 禁止使用三元运算符 `?:` 语法，必须使用 `if...else` 替代

### 测试规范
- **P1-7** GUT 测试代码中必须直接引用类，禁止使用 `load` 或 `preload` 加载类
- **P1-8** 测试代码必须使用子目录管理，相对路径与功能代码路径保持一致
- **P1-9** GUT 测试执行必须使用命令行，禁止使用编辑器界面执行

### 代码检查
- **P1-10** 编辑 `.gd` 文件后，必须使用 `minimal-godot` MCP 的 `get_diagnostics` 工具检查代码
- **P1-11** 代码检查未通过禁止提交

---

## 🟡 P2 - 操作流程（执行细节）

### 目录结构
```
├── assets/              # 游戏资产目录
│   ├── fonts/          # 字体文件
│   ├── music/          # 游戏音乐 (.wav, .ogg, .mp3 等)
│   ├── sounds/         # 游戏音效 (.wav, .ogg, .mp3 等)
│   └── sprites/        # 游戏图片资源
├── scenes/             # Godot 场景文件 (.tscn)，按游戏模块划分子目录
├── scripts/            # GDScript 文件 (.gd)，按游戏模块划分子目录
├── test/               # 单元测试目录
└── addons/             # 插件目录
```

- **P2-1** 严禁在规定目录外存放游戏资产、脚本或测试文件
- **P2-2** 场景和脚本文件必须按游戏模块划分子目录组织

### Git 提交流程
- **P2-3** 提交 .gd 功能代码到 git 后，必须检查是否需要修改或补充测试代码
- **P2-4** 检查完成后必须与用户确认后再执行
- **P2-5** 如果需要修改或补充测试代码，必须强制使用 `godot-developer` 技能完成
- **P2-6** .uid 文件必须提交到 git
- **P2-7** 提交新增的 .gd 文件时，如果发现缺少对应的 .uid 文件，必须提醒用户使用 Godot 引擎生成 .uid 文件后再提交

### 命令行使用
- **P2-8** 必须从环境变量 `GODOT_HOME` 获取 Godot 可执行文件路径
  ```bash
  # 假设环境变量 GODOT_HOME="C:\godot.windows.opt.tools.64.exe"
  # 原命令：godot -s addons/gut/gut_cmdln.gd -gexit
  # 转换后：
  $GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit
  ```

---

## 📋 严重违规清单

以下行为被视为严重违规，一经发现必须立即纠正：

1. 未使用 `godot-developer` 技能开发 Godot 项目
2. 未使用 `context7` 工具查询 API 导致语法错误
3. Singleton 文件中包含 `class_name`
4. 代码中（除注释外）包含中文字符
5. 未通过 `get_diagnostics` 检查即提交代码
6. 违反目录结构规范存放文件
7. 未提交 .uid 文件

**纠正措施：**
- 立即停止当前开发任务
- 回滚违规代码
- 重新按照宪法规范执行

---

## 📚 附录：文档规范

- **A-1** AGENTS.md 中的内容不需要重复 CONTRIBUTING.md 中的内容
