# 报告模板

生成报告时**必须**严格遵循以下格式。`{{变量}}` 为运行时填充项。

---

# GDScript 静态分析报告

**项目**：{{project_name}}
**日期**：{{date}}
**Godot 版本**：{{godot_version}}

---

## 1. 综合评级

| 维度 | 评级 | 说明 |
|------|------|------|
| 综合评分 | {{grade}} | {{grade_reason}} |

## 2. 指标总览

| 编号 | 指标 | 当前值 | 阈值 | 状态 |
|------|------|--------|------|------|
| C01 | 语法/类型错误 | {{c01_count}} | 0 | {{c01_status}} |
| C02 | 未使用代码 | {{c02_count}} | 0 | {{c02_status}} |
| C03 | 未使用文件 | {{c03_count}} | 0 | {{c03_status}} |
| C04 | 圈复杂度超标函数 | {{c04_count}} | ≤ 10 | {{c04_status}} |
| C05 | 代码重复组数 | {{c05_count}} | 0 | {{c05_status}} |
| C06 | 场景断裂引用 | {{c06_count}} | 0 | {{c06_status}} |
| C07 | 项目验证失败项 | {{c07_count}} | 0 | {{c07_status}} |
| C08 | 未定义 Input Action | {{c08_count}} | 0 | {{c08_status}} |
| C09 | Lint 错误/警告 | {{c09_count}} | 0 | {{c09_status}} |
| C10 | 测试覆盖率 | {{c10_value}}% | ≥ 80% | {{c10_status}} |
| C11 | 项目健康度 | {{c11_value}} | ≥ 80 | {{c11_status}} |
| C12 | 模式违规 | {{c12_count}} | 0 | {{c12_status}} |

> 状态标记：✅ PASS | ⚠️ WARN | ❌ FAIL

## 3. 详细问题清单

### 3.1 语法与类型错误（C01）

{{c01_details}}

### 3.2 未使用代码（C02）

{{c02_details}}

### 3.3 未使用文件（C03）

{{c03_details}}

### 3.4 圈复杂度（C04）

{{c04_details}}

### 3.5 代码重复（C05）

{{c05_details}}

### 3.6 引用完整性（C06/C07）

{{c06_c07_details}}

### 3.7 输入映射（C08）

{{c08_details}}

### 3.8 Lint 问题（C09）

{{c09_details}}

### 3.9 测试覆盖率（C10）

{{c10_details}}

### 3.10 代码模式（C12）

{{c12_details}}

## 4. 改进建议

按优先级排列：

{{recommendations}}

---

*报告由 godot-static-analysis skill 自动生成*
