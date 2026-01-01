# 1. 创建PRD

```
ultrathink 请根据 docs/00_scratch/ 目录下的图片，设计2D平台跳跃游戏`骑士的奥德赛大冒险`，按照GDD模版，输出游戏需求GDD文档到 docs/01_GDD/01_游戏设计文档_骑士的奥德赛大冒险.md 
要求:
- 游戏平台：支持PC、Mac
- 操作：支持键盘、Xbox手柄操作
游戏资产：
- 游戏资产: assets/
参考：
- GDD模版：docs/99_prompts/templates/GDD.md
```

---

# 2. 架构设计

```
ultrathink use context7 请输出游戏架构概要设计:
1. 读取`游戏需求GDD`，理解游戏需求
3. 结合业界最佳实践中的成熟方案和合理的设计模式， 使用 `godot-architect`技能进行架构设计
3. 委托 tech-docs-writer 输出详架构概要设计文档到 docs/02_arch/
约束：
- 概要设计文档输出架构设计需要按照`架构设计模版`输出
- 禁止输出详细实现代码 
参考文档:
- 游戏需求GDD: docs/01_GDD/01_游戏设计文档_骑士的奥德赛大冒险.md
- 架构设计模版: docs/99_prompts/templates/ARCH.md
```

---

# 3. sprint计划

```
ultrathink 请根据游戏GDD文档和架构概要设计文档，创建sprint开发计划:
1. 读取游戏需求GDD和游戏架构概要设计，遵循相关设计
2. 按照sprint开发方法论，支持迭代开发，分解story
3. 按照story维度，按照story模版输出story文档，保存到 docs/03_sprint/02_stroy/ 
4. 创建backlog文档，把所有story纳入其中，安排开发计划，并标记所有story为待开发状态，保存到 docs/03_sprint/01_backlog.md
约束：
- 禁止输出详细实现代码 
参考文档:
- 游戏需求GDD: docs/01_GDD/01_游戏架构概要设计_骑士的奥德赛大冒险.md
- 游戏架构概要设计: docs/02_arch/01_游戏架构概要设计_骑士的奥德赛大冒险.md
- story模版: docs/99_prompts/templates/STORY.md
```

---

# 4. Story手把手开发指导

```
ultrathink 请分析并输出下一个待开发的Story的手把手开发指导:
1. 读取backlog文档，获取下一个待开发的Story，并找我确认
2. 等待我的确认后，按迭代开发的方式拆分成多个task
3. 设计实现方案
3. 设计每个task的具体实现步骤
6. 等待我确认实现方案准确无误后，输出手把手详细TDD开发指导到 docs/04_hands_by_hands/ 
要求:
- 输出到一份文档中
- 不要完全隔离测试和实现的步骤，而是严格使用TDD微循环
- 优先输出详细指导，让我完成.tscn开发/project.godot配置，再进行gdscript开发
约束：
- 必须使用`godot-developer`技能设计并输出指导
- 仅输出设计和指导，禁止编写代码(可以用TODO的方式描述，例如
   ```
   func create_state(state_type: PlayerStateMachine.State) -> PlayerState:
    # TODO: 创建状态实例
    # - 根据类型返回对应状态
    pass
   ```)
```

---

# 5. Story协同开发

```
请与我与我协同开发:
1. 从 docs/04_hands_by_hands/ 下获取待开发的指导，并与我确认
2. 等待我确认后，切换到开发分支
3. 严格遵守`手把手开发指导`，使用`godot-developer`技能与我协同开发
要求：
- A good strategy with GUT is to separate unit and integration tests into separate directory structures (such as res://test/unit and res://test/integration).
约束：
- 必须遵守上下文和技能中声明的宪法(不可协商)
- 开发过程必须严格遵守TDD方法论，使用微循环小步快跑
- 开发分支名称：{story id}_{story名称英文名，中划线连接单词}, 例如： US_20251207153000_01_Player-Basic-Movement
- 代码实现后，调整方法中的注释，以增加代码可读性
- 每个task开发前，给我展示task开发的目标，并暂停等待我确认
- 每个task开发完成后，暂停执行，等待我代码检视
```