# {STORY_NAME} - TDD开发指导

## 文档信息
- **Story编号**: {STORY_ID}
- **创建时间**: {CREATE_DATE}
- **预计工期**: {ESTIMATED_DAYS}
- **负责人**: AI助手 / 用户

## 1. Story概述

### 1.1 需求描述
{STORY_DESCRIPTION}

### 1.2 验收标准
{ACCEPTANCE_CRITERIA}

### 1.3 技术要求
{TECHNICAL_REQUIREMENTS}

## 2. 技术架构分析

### 2.1 涉及模块
- {MODULE_1}
- {MODULE_2}
- ...

### 2.2 依赖关系
{DEPENDENCIES}

### 2.3 设计约束
{DESIGN_CONSTRAINTS}

## 3. TDD实施方案

### 3.1 测试用例设计

#### 3.1.1 功能测试
| 测试ID | 测试描述 | 预期结果 | 优先级 |
|--------|----------|----------|--------|
| {TEST_ID_1} | {TEST_DESC_1} | {EXPECTED_1} | {PRIORITY_1} |
| ... | ... | ... | ... |

#### 3.1.2 边界测试
| 测试ID | 测试场景 | 边界值 | 预期行为 |
|--------|----------|--------|----------|
| {BOUNDARY_TEST_1} | {SCENARIO_1} | {VALUE_1} | {BEHAVIOR_1} |
| ... | ... | ... | ... |

#### 3.1.3 异常测试
| 测试ID | 异常情况 | 错误处理 | 验证方式 |
|--------|----------|----------|----------|
| {EXCEPTION_TEST_1} | {EXCEPTION_1} | {HANDLING_1} | {VERIFY_1} |
| ... | ... | ... | ... |

### 3.2 代码框架设计

#### 3.2.1 类结构
```
{CLASS_NAME}
├── {PROPERTY_1}: {TYPE_1}
├── {PROPERTY_2}: {TYPE_2}
├── {METHOD_1}(): {RETURN_TYPE_1}
├── {METHOD_2}({PARAM}): {RETURN_TYPE_2}
└── {SIGNAL_1}
```

#### 3.2.2 方法签名
```gdscript
# {CLASS_NAME}.gd
class_name {CLASS_NAME}
extends {BASE_CLASS}

# {METHOD_1_DESCRIPTION}
func {METHOD_1}({PARAMETERS}) -> {RETURN_TYPE}:
    pass

# {METHOD_2_DESCRIPTION}
func {METHOD_2}({PARAMETERS}) -> {RETURN_TYPE}:
    pass
```

## 4. 详细开发步骤

### 步骤1：准备测试环境 [责任人：AI助手]
- [ ] 创建测试文件 `test/{CLASS_NAME}_test.gd`
- [ ] 设置测试基础结构
- [ ] 引入必要的依赖

**操作说明**：
1. 使用GUT框架创建测试类
2. 继承自GutTest
3. 配置测试环境

### 步骤2：编写第一个失败的测试 [责任人：AI助手]
- [ ] 实现 `{TEST_FUNCTION_1}` 测试函数
- [ ] 确保测试失败（Red阶段）
- [ ] 验证测试逻辑正确

**操作说明**：
1. 按照AAA模式编写测试
2. 确保测试描述清晰
3. 运行测试确认失败

### 步骤3：实现最小功能代码 [责任人：用户]
- [ ] 创建 `{CLASS_NAME}.gd` 文件
- [ ] 实现基本类结构
- [ ] 编写刚好通过测试的代码

**操作说明**：
1. 创建类文件并命名
2. 实现最小功能
3. 运行测试确保通过

### 步骤4：重构优化代码 [责任人：用户]
- [ ] 优化代码结构
- [ ] 提高可读性
- [ ] 确保所有测试通过

**操作说明**：
1. 在保持测试通过的前提下重构
2. 应用设计模式
3. 验证性能

### 步骤5：完善测试覆盖 [责任人：AI助手]
- [ ] 添加边界条件测试
- [ ] 增加异常处理测试
- [ ] 确保测试覆盖率达标

**操作说明**：
1. 补充缺失的测试用例
2. 验证覆盖率指标
3. 优化测试代码

## 5. 质量检查清单

### 代码质量
- [ ] 代码符合GDScript规范
- [ ] 使用类型提示
- [ ] 命名规范正确
- [ ] 无代码重复

### 测试质量
- [ ] 测试覆盖率达标
- [ ] 测试用例独立
- [ ] 包含所有场景
- [ ] 测试可维护

### 性能要求
- [ ] 无性能瓶颈
- [ ] 内存使用合理
- [ ] 帧率稳定

## 6. 常见问题与解决方案

### 问题1：{COMMON_PROBLEM_1}
**解决方案**：{SOLUTION_1}

### 问题2：{COMMON_PROBLEM_2}
**解决方案**：{SOLUTION_2}

## 7. 参考资源

- [GDScript官方文档]({GDSCRIPT_DOCS})
- [GUT测试框架指南]({GUT_GUIDE})
- [项目架构文档]({ARCHITECTURE_DOCS})

## 8. 交付物

- [ ] `{CLASS_NAME}.gd` - 功能实现代码
- [ ] `test/{CLASS_NAME}_test.gd` - 单元测试代码
- [ ] 相关场景文件（如需要）
- [ ] 更新的技术文档

---
*本文档由godot-developer技能自动生成，请严格按照TDD方法论进行开发*