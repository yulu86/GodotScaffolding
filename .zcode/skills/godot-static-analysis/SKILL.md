---
name: godot-static-analysis
description: GDScript 代码静态检查与度量分析。当用户要求对 Godot 项目进行代码质量检查、静态分析、代码度量、质量报告、lint 检查、代码健康度评估时使用。触发词：静态检查、静态分析、代码度量、质量报告、lint、代码质量、健康检查、静态分析报告、code quality、static analysis、lint check。
---

# GDScript 静态检查与度量分析

对 Godot 项目的 GDScript 代码执行全面静态检查，生成固定格式的质量报告。

## 检查指标与阈值

| 编号 | 类别 | 指标 | 合法阈值 | MCP 工具 |
|------|------|------|---------|----------|
| C01 | 语法 | 语法/类型/未定义标识符错误 | 0 | `minimal-godot_get_diagnostics` |
| C02 | 代码卫生 | 未使用函数/变量/信号 | 0 | `godot-ultimate_godot_detect_dead_code` |
| C03 | 代码卫生 | 未使用文件 | 0 | `godot-ultimate_godot_find_unused_files` |
| C04 | 复杂度 | 函数圈复杂度 | ≤ 10 | `godot-ultimate_godot_get_complexity` |
| C05 | 复杂度 | 代码重复（≥5 行） | 0 组 | `godot-ultimate_godot_find_duplication` |
| C06 | 引用完整性 | 场景断裂引用 | 0 | `godot-ultimate_godot_validate_scenes` |
| C07 | 引用完整性 | 项目全局验证 | 全部通过 | `godot-ultimate_godot_validate_project` |
| C08 | 输入 | 未定义 Input Action | 0 | `godot-ultimate_godot_validate_inputs` |
| C09 | Lint | 单文件/项目级 Lint | 0 error, 0 warning | `godot-ultimate_godot_lint_project` |
| C10 | 测试 | 测试覆盖率 | ≥ 80% | `godot-ultimate_godot_get_test_coverage` |
| C11 | 健康 | 项目健康度综合评分 | ≥ 80 | `godot-ultimate_godot_project_health` |
| C12 | 模式 | 代码模式合规 | 0 违规 | `godot-ultimate_godot_check_patterns` |

## 执行流程

### 第一阶段：快速扫描

并行执行独立检查，收集原始数据：

1. **C01** — 调用 `minimal-godot_scan_workspace_diagnostics`（全项目扫描）
2. **C02** — 调用 `godot-ultimate_godot_detect_dead_code`
3. **C03** — 调用 `godot-ultimate_godot_find_unused_files`
4. **C06** — 调用 `godot-ultimate_godot_validate_scenes`
5. **C07** — 调用 `godot-ultimate_godot_validate_project`
6. **C08** — 调用 `godot-ultimate_godot_validate_inputs`
7. **C09** — 调用 `godot-ultimate_godot_lint_project`
8. **C10** — 调用 `godot-ultimate_godot_get_test_coverage`
9. **C11** — 调用 `godot-ultimate_godot_project_health`

### 第二阶段：深度分析

根据第一阶段结果，对有问题的文件执行：

1. **C04** — 对 Lint/诊断报错的 `.gd` 文件调用 `godot-ultimate_godot_get_complexity`
2. **C05** — 调用 `godot-ultimate_godot_find_duplication`（min_lines=5）
3. **C12** — 对有问题的 `.gd` 文件调用 `godot-ultimate_godot_check_patterns`

### 第三阶段：生成报告

读取报告模板 `references/report-template.md`，填充数据后输出。

### 评分规则

| 级别 | 判定条件 |
|------|---------|
| **A（优秀）** | 所有指标在阈值内，C10 ≥ 80% |
| **B（良好）** | 最多 2 个 C02/C05 指标超阈值，C10 ≥ 60% |
| **C（待改进）** | C01 或 C06/C07 超阈值，或 C10 < 60% |
| **D（不合格）** | C01 > 5 且 C10 < 40% |

## 资源

### references/

- `report-template.md` — 报告模板，生成报告时**必须**加载并严格遵循其格式
