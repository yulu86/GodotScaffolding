# 1. 创建PRD

```
ultrathink 请根据 docs/00_scratch/ 目录下的图片，设计2D沙漠射手游戏，输出游戏需求PRD文档到 docs/01_PRD/ 目录下。
游戏需要支持PC、Mac，支持键盘、Xbox手柄操作。
```

# 2. 拆分feature

```
ultrathink use context7 请根据 docs/01_PRD/01_游戏需求文档.md ，拆分成多个feature，按照feature维度输出feature需求分析文档。
- feature需要能够独立开发、测试、交付，以满足按照迭代开发交付。
- feature需求分析文档需要包含feature id、feature标题、需求说明、验收标准、交付件
- 不需要包含详细的实现代码
- feature需求分析文档按照相关性划分为多个子目录，保存到 docs/02_feature/ 目录下
```

# 3. 架构设计

```
ultrathink use context7 请根据 docs/01_PRD/01_游戏需求文档.md 和 docs/02_feature/ 目录下的feature需求分析文档，结合 assets/ 下已有的游戏资源，进行架构设计，输出架构设计文档。
- 游戏引擎使用 Godot 4.5 
- 使用GDscript编码
- 使用GUT按照TDD进行开发
- 合理使用设计模式
- 不需要包含详细的实现代码
- 架构设计文档采用文字、表格、mermaid图形式组织
- 架构设计文档保存到 docs/03_architect/ 目录下
```

# 4. 开发计划

```
ultrathink use context7 请根据 docs/02_feature/ 目录下的feature需求分析文档，分析feature之间的依赖关系，输出逐个feature开发计划到 docs/04_plan/plan.md
只需要用有序列表输出feature id和feature名称
例如：
[ ] 1. FE-001 01_战斗基础机制
[ ] 2. FE-003 03_敌人AI系统
[ ] 3. FE-002 02_武器系统
```