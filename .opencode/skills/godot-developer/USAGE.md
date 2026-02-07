# Godot Developer 技能使用指南

## 快速开始

### 1. 代码实现模式
直接告诉AI需要实现的功能：
```
请实现一个玩家控制器，支持WASD移动和跳跃
```

### 2. Story开发指导模式
使用完整的开发流程：
```
请使用Story开发指导功能
```

## 核心功能详解

### 🔄 动态配置
首次使用时自动配置项目路径，支持：
- 自动识别常见项目结构
- 自定义所有文档路径
- 配置持久化保存
- 随时重新配置

### 📋 Story开发流程
完整的Story-driven开发：
1. 自动读取backlog
2. 识别下一个Story
3. 确认需求细节
4. 生成TDD方案
5. 输出开发指导

### 🧪 TDD支持
- 测试用例设计
- Red-Green-Refactor流程
- 代码框架规划
- 质量检查清单

## 输出文件

### 开发指导文档
保存到：`docs/04_hands_by_hands/`
文件格式：`{序号}_{Story名称}_开发指导.md`

### 配置文件
保存到：`.claude/skills/godot-developer/config/project-config.json`

## 最佳实践

1. **首次使用**：让AI自动配置项目路径
2. **Story开发**：严格按指导文档执行
3. **TDD流程**：始终遵循测试先行原则
4. **质量保证**：使用提供的检查清单

## 常见问题

### Q: 如何修改项目路径？
A: 运行技能时选择重新配置，或直接编辑config/project-config.json

### Q: 生成的指导文档在哪里？
A: 默认在docs/04_hands_by_hands/目录下

### Q: 如何确保代码质量？
A: 严格按照技能提供的开发检查清单执行

## 技能文件结构

```
godot-developer/
├── SKILL.md              # 主技能文档
├── USAGE.md              # 使用指南（本文件）
├── config/               # 配置文件
│   ├── project-config.json
│   └── README.md
├── modules/              # 功能模块
│   ├── story-guide-generator.md
│   └── tdd-planner.md
├── templates/            # 文档模板
│   └── development-guide-template.md
├── guides/               # 用户指南
└── references/           # 参考资料
```