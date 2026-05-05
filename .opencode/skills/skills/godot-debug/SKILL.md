---
name: godot-debug
description: Godot 4.x MCP 调试 Skill，通过 MCP 工具运行项目、捕获调试输出、截图验证和错误日志分析。当需要调试游戏 Bug、运行项目并查看输出、截图验证 UI 布局、分析运行时错误或性能问题时触发此技能。
---

# Godot MCP 调试器

使用 MCP 工具调试 Godot 4.x 游戏，获取实时反馈。

## 何时使用

- 运行游戏并捕获调试输出
- 诊断运行时错误和警告
- 通过截图验证 UI 布局和视觉 Bug
- 分析性能问题
- 验证修改后的场景行为

## 调试工作流

### 阶段1：复现问题

```
1. godot-mcp_run_project(projectPath, optionalScene)
2. Interact with the game or let it run to the error state
3. godot-mcp_get_debug_output()  → capture errors/warnings
4. godot-mcp_stop_project()
```

如果用户报告了特定的 Bug，先询问复现步骤。

### 阶段2：分析输出

解析调试输出中的以下模式：

| 模式 | 含义 | 操作 |
|------|------|------|
| `SCRIPT ERROR:` | GDScript 运时错误 | 检查文件:行号，阅读错误信息 |
| `parse error` | 加载时的语法错误 | 修复语法，重新运行 |
| `Node not found` | 无效的节点引用 | 检查 %UniqueName 或节点路径 |
| `Invalid type` | 类型不匹配 | 检查变量类型和函数签名 |
| `Attempt to call function on null` | 缺少节点或资源 | 检查 @onready 初始化顺序 |
| `Condition 'xxx' is true` | 引擎断言 | 检查 Godot 版本兼容性 |

### 阶段3：定位并修复

1. **读取错误文件** — 使用 `read` 工具查看堆栈跟踪中报告的文件
2. **定位根本原因** — 不要修复症状，修复根本原因
3. **最小化修复** — 每次只改一处
4. **重新运行并验证** — 再次执行阶段1-2

### 阶段4：验证修复

```
1. godot-mcp_run_project(projectPath)
2. Reproduce the previous scenario
3. godot-mcp_get_debug_output() → confirm no errors
4. godot-mcp_stop_project()
```

对于 UI 修复，还需要截图进行视觉验证。

## 参考文档（按需加载）

- **MCP 工具指南**：[references/godot-mcp-guide.md](references/godot-mcp-guide.md) — 完整的 MCP 工具参考，涵盖项目管理、场景操作、运行/调试和 UID 管理

## MCP 工具参考

### 运行项目

```
godot-mcp_run_project(projectPath, scene?)
```
- `projectPath`：Godot 项目根目录的绝对路径
- `scene`：可选，指定要运行的场景（适用于隔离问题）

### 捕获调试输出

```
godot-mcp_get_debug_output()
```
返回运行中游戏的所有 stdout/stderr 输出。

### 停止项目

```
godot-mcp_stop_project()
```

### 获取 Godot 版本

```
godot-mcp_get_godot_version()
```
验证是否使用 Godot 4.4+（UID 支持所需）。

### 诊断

```
minimal-godot_get_diagnostics(file_path)
```
检查单个 .gd 文件的错误/警告，无需运行游戏。

```
minimal-godot_scan_workspace_diagnostics()
```
扫描项目中所有 .gd 文件（开销较大，请谨慎使用）。

## 常见调试场景

### 场景：运行时脚本错误

```
1. Run project → capture output
2. Parse: "SCRIPT ERROR: ... at player.gd:42"
3. Read player.gd around line 42
4. Identify the null reference or type mismatch
5. Fix minimally
6. Re-run and verify
```

### 场景：UI 布局异常

```
1. Run project → take screenshot
2. Compare with expected layout
3. Identify the misplaced or missing nodes
4. Read the .gd script for the UI scene
5. Fix the layout logic or container settings
6. Re-run → screenshot to verify
```

### 场景：性能问题

```
1. Run project → capture output for warnings
2. Check for:
   - _process creating objects every frame
   - Large number of physics bodies
   - Shader compilation warnings
3. Profile the specific area
4. Apply targeted optimization
5. Re-run and compare
```

### 场景：信号连接失败

```
1. Run project → "Error calling deferred method"
2. Check signal connection code in _ready()
3. Verify %UniqueName is set on the target node
4. Verify signal signature matches callback signature
5. Fix the connection or callback
6. Re-run and verify
```

## 调试原则

1. **证据优先** — 在假设之前必须捕获调试输出
2. **每次只改一处** — 修复、验证、重复
3. **根本原因分析** — 不要只修补症状
4. **最小化修改** — 调试时不要重构
5. **连续3次修复失败后** — 停止、回滚、咨询 Oracle

## 与其他技能的集成

- **systematic-debugging**：用于复杂的多步骤调试
- **godot-developer**：用于诊断后实施实际修复
- **godot-scene**：用于与场景结构相关的 Bug
- **godot-test**：用于测试调试和测试失败诊断

## 约束

- **必须**在修改前捕获调试输出
- **禁止**猜测错误原因 — 先阅读日志
- **禁止**同时进行多项修复
- **必须**在每次修复后重新运行并验证
- 连续3次修复失败后**停止** — 回滚并升级处理
