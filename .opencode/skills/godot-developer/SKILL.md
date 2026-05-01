---
name: godot-developer
description: Godot 4.x TDD 开发专家，使用测试驱动方法论实现 GDScript 代码。支持 Story 驱动的开发指导、TDD 方案设计和开发文档生成。当需要编写 GDScript 游戏代码、实现具体功能、执行 TDD Red-Green-Refactor 循环、生成 Story 开发指导或编写 GDScript 实现代码时触发此技能。
compatibility: opencode
---

# Godot Developer - TDD 实现专家

基于 `godot-architect` 的架构设计，使用 TDD 方法论实现 GDScript 代码。

## 何时使用

- 基于架构设计在 GDScript 中实现游戏功能
- 执行 TDD Red-Green-Refactor 循环
- 生成 Story 驱动的开发指导
- 编写实现代码（测试由 `godot-test` 技能负责）

## 核心职责

**架构 → 实现**。接收 `godot-architect` 的设计方案，通过 TDD 实现，使用 `godot-test` 和 `godot-debug` 验证。

## TDD 工作流

### Red：编写失败测试
- 根据需求设计测试场景
- 使用 GUT 框架（模式参考 `godot-test` 技能）
- 确保测试失败——验证需求理解是否正确
- 关注接口设计，而非实现细节
- AAA 模式：Arrange（准备）→ Act（执行）→ Assert（断言）

### Green：最小实现
- 编写能使测试通过的最少代码
- 严格遵循 GDScript 规范
- **目标：让测试通过**，而非追求完美
- 优先选择最简方案，避免过早优化

### Refactor：重构优化
- 在保持测试通过的前提下优化结构
- 提升可读性和可维护性
- 消除重复代码，应用设计模式
- 确保所有测试仍然通过

### Consolidate：强化测试
- 添加边界条件和边缘场景测试
- 添加错误处理和负面测试
- 目标覆盖率：单元测试 70%，集成测试 20%，端到端测试 10%

## 参考文档

### 强制标准
- **GDScript 风格指南**：[references/official_gdscript_styleguide.md](references/official_gdscript_styleguide.md) — 所有代码必须遵循
- **命名规范**：[references/naming_conventions.md](references/naming_conventions.md) — 场景脚本命名规则
- **TDD 工作流指南**：[references/tdd-workflow-guide.md](references/tdd-workflow-guide.md) — 详细的 TDD 实现指南
- **TDD 案例研究**：[references/tdd-case-studies.md](references/tdd-case-studies.md) — 真实项目的 TDD 示例
- **开发指南**：[references/development-guide.md](references/development-guide.md) — 代码模板和开发流程

### 状态机实现
状态机架构由 `godot-architect` 定义。完整规范参见该技能的 `references/state-machine-guide.md`。

实现状态机时，遵循以下模式：
```gdscript
class_name StateIdle
extends State

func enter() -> void:
	super.enter()
	# Initialization logic

func process(delta: float) -> void:
	super.process(delta)
	# State update logic
```

### 场景创建
场景创建工作流由 `godot-scene` 技能负责。创建或修改 .tscn 文件时请使用该技能。

### 测试
GUT 测试编写由 `godot-test` 技能负责。测试模式、框架参考和测试调试请使用该技能。

### 调试
基于 MCP 的调试由 `godot-debug` 技能负责。运行项目、捕获输出和诊断问题请使用该技能。

## 强制规范

### 命名（绝对强制）
- 场景文件名必须与脚本 class_name 100% 匹配
- `player.tscn` → `Player`（不是 `PlayerController`）
- 单例脚本：**禁止** 使用 `class_name`
- 违反命名规范 = 代码不予接受

### 代码质量
- 所有代码必须通过语法检查
- 所有变量和函数签名必须使用类型提示
- 遵循官方 GDScript 风格指南
- 禁止硬编码值

### TDD 要求
1. **测试先行**：先写测试再写实现
2. **全面覆盖**：覆盖核心功能和边界条件
3. **持续重构**：每次实现后进行优化
4. **文档同步**：代码变更时更新测试文档

## 工具使用

### 必需工具
- **Context7**：查询 GDScript 语法和 Godot API 文档
- **GUT 框架**：编写和运行单元测试（通过 `godot-test` 技能）
- **Godot MCP**：项目管理和场景操作（通过 `godot-scene` 技能）

### 文件权限
- ✅ **允许**：创建和编辑 .gd 脚本文件
- ✅ **允许**：通过 MCP 工具读取项目信息
- ❌ **禁止**：直接修改 .tscn 场景文件（使用 `godot-scene`）
- ❌ **禁止**：修改 project.godot 配置（使用 `godot-init`）

## 核心模块

### 动态配置
首次运行时自动配置项目路径：
- 自动检测项目结构
- 可自定义文档路径
- 跨会话持久化配置

### Story 驱动开发
完整的 Story 开发流程：
1. **Backlog 分析**：读取 Backlog，识别下一个 Story
2. **需求确认**：与用户确认 Story 范围
3. **文档加载**：加载 GDD、架构设计文档
4. **TDD 方案设计**：生成详细的 TDD 实现计划
5. **指导生成**：输出逐步开发指导

### TDD 规划器
专业的测试驱动开发设计：
- 测试用例设计：功能、边界、异常、集成
- 代码框架规划：类结构、方法签名、接口
- 开发步骤编排：Red-Green-Refactor 流程
- 质量标准：覆盖率、性能、可维护性

### 开发指导生成器
自动化文档生成：
- 基于标准化模板的输出
- 清晰的职责分工（AI 助手 vs 用户任务）
- 详细的步骤说明
- 完整的质量检查清单

## 开发检查清单

提交代码前，逐项检查：

### 代码规范
- [ ] 脚本 class_name 是否与场景文件名匹配？
- [ ] 是否使用了类型提示？
- [ ] 是否遵循官方命名规范？
- [ ] 是否通过语法检查？

### 测试质量
- [ ] 测试是否覆盖核心功能？
- [ ] 是否包含边界条件测试？
- [ ] 所有测试是否通过？
- [ ] 测试代码是否遵循规范？

### 性能
- [ ] 是否存在不必要的 _process 调用？
- [ ] 信号通信是否正确使用？
- [ ] 内存管理是否正确？
- [ ] 是否存在性能陷阱？
