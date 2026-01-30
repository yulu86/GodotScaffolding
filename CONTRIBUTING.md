# 🏛️ 项目宪法

## ⭐ P0 - 核心原则
- **P0-1** 代码必须满足 SOLID 原则 + DRY 原则
- **P0-2** 禁止语法错误
- **P0-3** 代码除注释外禁止使用中文

## 🔴 P1 - 强制规范

### 开发流程
- **P1-1** 使用 `godot-developer` 技能 + TDD 微循环
- **P1-2** 使用 `context7` 工具查询 API 文档

### 编码规范
- **P1-3** 优先 AnimationPlayer 节点
- **P1-4** Singleton .gd 文件禁止 `class_name`
- **P1-5** 禁止三元运算符 `?:`，使用 `if...else`

### 测试规范
- **P1-6** 测试代码直接引用类，禁止 `load`/`preload`
- **P1-7** 测试子目录路径与功能代码一致
- **P1-8** GUT 测试必须使用命令行执行

### 代码检查
- **P1-9** 编辑 .gd 后必须 `minimal-godot_get_diagnostics` 检查
- **P1-10** 检查未通过禁止提交

## 🟡 P2 - 操作流程

### 目录结构
```
assets/ (fonts, music, sounds, sprites)
scenes/ (.tscn，按模块分)
scripts/ (.gd，按模块分)
test/ (单元测试)
addons/
```
- **P2-1** 严禁在目录外存放资产/脚本/测试
- **P2-2** 场景脚本按模块分目录

### Git 提交
- **P2-3** 提交 .gd 后检查测试
- **P2-4** 与用户确认后再执行
- **P2-5** 修改测试必须用 `godot-developer`
- **P2-6** .uid 文件必须提交
- **P2-7** 缺少 .uid 时提醒用户生成

### 命令行
- **P2-8** 使用 `$GODOT_HOME` 环境变量：`$GODOT_HOME -s addons/gut/gut_cmdln.gd -gexit`

### godot-ultimate 工具

用于代码分析、测试、文档、项目验证（约 40+ 工具），包括：
- lint/validate/complexity 检查
- 符号/依赖/信号分析
- 测试生成与覆盖率
- API/项目文档查询
- 场景/输入/资源验证
- 代码生成与自动修复
- 着色器分析与 lint
- 专业代理调用
- 环境健康检查

## 📋 严重违规清单

1. 未使用 `godot-developer` 技能
2. 未使用 `context7` 查询 API
3. Singleton 文件包含 `class_name`
4. 代码含中文（除注释）
5. 未通过 `get_diagnostics` 检查
6. 违反目录结构
7. 未提交 .uid 文件

**纠正：停止 → 回滚 → 重新执行**

## 📚 附录

- **A-1** AGENTS.md 不重复 CONTRIBUTING.md 内容
