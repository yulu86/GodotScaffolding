# dajiji — Godot 跨项目复用经验集

> **从 `godot-texas` 项目 `docs/99_postmortem/MEMORY.md` 抽取的可跨项目复用原则与经验**。
> 沿用 MEMORY.md 的结构（快速检索表 / 通用原则 / 实例档案 / 维护指南 / 示例），便于 AI 按相同路径检索。
>
> **筛选口径**：MEMORY.md 中标记「通用」的条目（原样保留）+ 标记「项目」但理念本身可跨项目的条目（泛化项目特定引用后纳入）。排除纯项目专属内容（如特定素材包命名、特定游戏算法）。
>
> **类型列说明**：本文档定位为跨项目复用集，故所有纳入条目的 Type 列统一标「通用」；来源列保留原日期 + 任务名便于追溯原始场景。
>
> **AI 检索路径**（按序）：
> 1. 扫「🤖 快速检索表」按 **标签 / 关键词** 命中规则（一句话索引）
> 2. 命中后查「📐 通用原则」对应分组的 **详细规则**
> 3. 需要上下文/案例佐证时，按规则尾部 `→ 来源` 跳「📋 实例档案」
>
> **结构约定**：
> - `通用原则` = 已沉淀的跨任务规则（详细版，按主题 `#标签` 分组）
> - `实例档案` = 场景化案例（场景 / 教训 / 沉淀规则指针），按日期倒序
> - 新增经验：先看「快速检索表」是否已有同类规则 → 有则补充实例 → 无则在「通用原则」新增并加入检索表

---

## 🤖 快速检索表

> 一句话规则索引，按 `#标签` 主题聚类。命中后查「📐 通用原则」对应分组看详情。
>
> **建议标签**（按需扩展）：`#架构` `#FSM` `#数据驱动` `#碰撞` `#GdUnit4` `#测试` `#代码规范` `#性能` `#RefCounted` `#信号` `#UI` `#流程` `#MCP` `#qmd` `#配置` `#场景` `#动画`

| 标签 | 一句话规则 | 类型 | 来源 |
|------|----------|:---:|------|
| `#测试` | 用户故事开发前先按验收标准设计集成测试+单元测试用例，再编码实现 | 通用 | 2026-07-11 流程约定 |
| `#流程` | 每个 Story 开发前必须输出详细的 LLA（Low-Level Architecture）文档 | 通用 | 2026-07-11 流程约定 |
| `#流程` | LLA 只画类图+签名清单（类名/函数名/参数/返回值/信号），禁写实现代码体 | 通用 | 2026-07-12 LLA 规范 |
| `#流程` | LLA 必须用表格输出测试用例设计（方法/验证AC/输入/断言/类型），禁散列文字 | 通用 | 2026-07-12 LLA 规范 |
| `#流程` | 文档生成后必自检其中 mermaid 图语法（类图/状态机/时序/流程图），发现错误立即修 | 通用 | 2026-07-12 文档质量约定 |
| `#GdUnit4` | GdUnit4 测试用例用 `auto_free(obj)` + `add_child(node)`，无 `add_child_autoqfree` | 通用 | 2026-07-12 F01-01 |
| `#UI` | Control 节点在 Node2D 子 Viewport 下不接收 GUI 输入事件，需挂根 Node 或 CanvasLayer | 通用 | 2026-07-12 F01-01 |
| `#流程` | Story 场景完成后必须确认项目启动路径串联（入口脚本加载子场景），否则 F5 验证不可见 | 通用 | 2026-07-12 F01-01 |
| `#信号` | 信号总线（EventBus）信号引用未定义类型用 Variant 占位 + TODO，后续渐进强类型化 | 通用 | 2026-07-11 信号总线设计 |
| `#配置` | project.godot 的 [input]/[autoload]/[layer_names] 段用 Godot API 脚本生成，禁手写 | 通用 | 2026-07-11 配置生成 |
| `#碰撞` | 纯 UI 无物理交互游戏不用 2D 物理，碰撞层配少量语义占位层满足层名合规 | 通用 | 2026-07-11 碰撞层降级 |
| `#场景` | SubViewportContainer 必须含 SubViewport 子节点；stretch=true 时禁手动设 SubViewport size | 通用 | 2026-07-11 F00-05 |
| `#MCP` | godot-mcp add_node 的 properties 对 size 字段无效，需用 Lua/API 脚本补设 | 通用 | 2026-07-11 F00-05 |
| `#FSM` | 信号订阅/取消订阅用 has_signal + is_connected 双重守卫，避免缺信号或未连接时崩溃 | 通用 | 2026-07-12 F02-03 |
| `#流程` | git 提交记录 ≠ story 交付：需 AC 逐条核对 + 质量门禁 + frontmatter 状态闭环 | 通用 | 2026-07-12 完成度审计 |
| `#qmd` | 每次修改项目 md 后必跑 `qmd update && qmd embed -c <集合名>` 保持索引同步 | 通用 | 2026-07-12 索引刷新 |
| `#qmd` | 集合初始化用 `qmd collection add <path> --name <name>`；禁无参/首参当集合名（会扫全根含第三方目录） | 通用 | 2026-07-12 集合初始化 |
| `#场景` | PackedScene.pack 子节点 owner 必须是根节点，否则序列化时丢弃 | 通用 | 2026-07-12 F03-01 |
| `#代码规范` | Godot 4.7 枚举类型变量必须设显式默认值，否则 ENUM_VARIABLE_WITHOUT_DEFAULT 警告 | 通用 | 2026-07-12 F03-01 |
| `#流程` | 每个 story 开发完必须立即刷新 frontmatter 状态 + README 总表，保持进度可追踪 | 通用 | 2026-07-12 进度追踪约定 |
| `#测试` | GdUnit4 信号测试用 await signal + Array 容器记录参数；lambda 捕获 int 计数无效 | 通用 | 2026-07-12 F03-02 |
| `#配置` | 像素风游戏视口设小(固定逻辑分辨率) + 窗口覆盖等比例放大(整数缩放)，非视口=窗口 | 通用 | 2026-07-12 F03-02 |
| `#MCP` | headless SceneTree 脚本无法给引用 autoload 的脚本 set_script（编译失败），改编辑器/MCP | 通用 | 2026-07-12 F03-02 |
| `#场景` | 动态子节点非动画移除用 remove_child+free（同步），queue_free 是帧末执行 get_child_count 不立即更新 | 通用 | 2026-07-12 F03-03 |
| `#场景` | .tscn 脚本引用必须带 uid（ext_resource uid=），仅 path 无 uid 时 instantiate as ClassType 返回 null | 通用 | 2026-07-12 F03-03 |
| `#动画` | Label 数字滚动用 tween_method(int→int, 时长) + 逐帧回调更新 .text，重入前 kill 旧 Tween | 通用 | 2026-07-12 F03-04 |
| `#信号` | signal.connect(带默认参方法) 会自动把信号参数绑到首参，其余参用默认值（GDScript 信号连接语义） | 通用 | 2026-07-12 F03-04 |
| `#MCP` | godot-mcp 运行环境不加载 autoload，引用 autoload 的脚本编译失败（Identifier not found），用最小文本补丁替代 | 通用 | 2026-07-12 F03-04 |
| `#代码规范` | GDScript 4.7 const Dictionary 不能引用其他类枚举成员（非常量表达式），改用 _init 里 var 初始化 | 通用 | 2026-07-12 F04-04 |
| `#代码规范` | GDScript 4.7 Array 不能隐式赋给 Array[T] 等强类型数组，需逐个 append 或 clear+append | 通用 | 2026-07-12 F04-04 |
| `#代码规范` | 禁止 override Node 原生方法 set_name（签名 set_name(StringName)），自定义命名方法改用 set_xxx_name | 通用 | 2026-07-12 F03-05 |
| `#代码规范` | `@warning_ignore("unused_signal")` 必须紧贴有效目标（signal 声明），单独放文件顶部会 parse error | 通用 | 2026-07-12 脚手架重建 |
| `#流程` | 项目重置后必查孤儿 .tres（脚本删但 .tres 引用断裂→validate_project 失败），删除或补脚本骨架 | 通用 | 2026-07-12 脚手架重建 |
| `#信号` | 信号总线（EventBus）信号不预声明全部（引用未定义类型编译失败），按 Feature 渐进追加（首个信号上方加 @warning_ignore） | 通用 | 2026-07-12 脚手架重建 |
| `#架构` | Autoload 骨架先行：所有单例空骨架（含必要枚举）+ main.tscn 分层占位，解除后续 story 启动阻塞 | 通用 | 2026-07-12 脚手架重建 |

<!-- 检索表新增行格式：
| `#标签` | 简明规则描述（≤30 字） | 通用 | 日期 + 任务名 |
-->

---

## 📐 通用原则

> 已沉淀的跨任务通用规则，按 `#标签` 主题分组。详细版本，新增规则同步加入上方「快速检索表」。

### `#测试`

- **Story 前置测试设计（验收标准驱动，集成 + 单元双层先行）**：每个 Story 开发前**必须**先按其验收标准（AC1/AC2…）设计**集成测试**与**单元测试**用例（明确每条 AC 对应的测试方法、输入、断言），再进入编码实现阶段。
  - **Why**：验收标准是 Story 的"完成定义"，先把它转化为可执行的测试，能让开发始终对齐验收目标、避免"实现完才发现漏了某个 AC"。集成测试覆盖端到端行为（验收层），单元测试覆盖核心逻辑/边界/分支（实现层），双层先行才能既守住验收目标又驱动内部设计；同时它们是后续重构的安全网（契合 TDD 小循环的 Red 预备）。
  - **How**：
    1. 读对应 Story 的验收标准（AC 列表）；
    2. **集成测试**：逐条 AC 设计端到端测试方法（命名描述行为，如 `test_ac1_xxx`），列出输入操作与预期断言（画面/状态/数值），落码到 `test/integration/{模块}/`；
    3. **单元测试**：针对该 Story 涉及的核心函数/分支/边界设计单元测试（每方法 ≥2 用例，覆盖正常+异常），落码到 `test/unit/`；
    4. 此时测试允许 fail 或 skip（作为 Red 起点）；再进入编码实现，用 TDD 小循环逐个让测试转绿。
  - **反例**：直接开始写功能代码，事后补测试 → 容易漏掉某个 AC，且测试沦为"给已有代码做背书"而非驱动设计；或只写集成测试不写单元测试 → 内部分支/边界无安全网，重构易引入回归。
  - **与 TDD 小循环的关系**：本规则是 Story 级的"测试先行（集成 + 单元）"，TDD 的 Red-Green-Refactor 是函数级的小循环；前者定义"要测什么"，后者定义"怎么一步步实现"。两者互补，不可互相替代。

- **GdUnit4 信号测试：用 `await signal` + Array 容器记录参数，禁用 lambda 捕获 int 计数**：测试异步信号（如 tween 动画完成后 emit）时，常见的错误模式是 `var count := 0; sig.connect(func(): count += 1); await ...; assert_int(count).is_equal(1)`——这会**失败**，因为 GDScript lambda 捕获**值类型（int）变量**时，闭包内的自增不会反映到外层变量（int 是值拷贝语义，lambda 捕获的是快照）。即便改用对象引用捕获（`var received: Node = null; sig.connect(func(c): received = c)`）在某些 await 时序下也表现为 null（lambda 回调未执行）。
  - **Why**：GDScript lambda 闭包对值类型变量的捕获语义与直觉不符；且 `await signal` 与 `connect(callable)` 对同一次 emit 存在调度时序竞态（await 唤醒与 callable 执行的顺序不保证）。
  - **How（正确方式）**：
    1. **用 Array 容器记录信号参数**（Array 是引用类型，闭包修改可见）：
       ```gdscript
       var received: Array = []
       sig.connect(func(c): received.append(c))
       await sig  # 或 await await_millis(动画时长)
       assert_array(received).is_not_empty()  # 非空即证明 emit
       ```
    2. **`await sig` 成功唤醒本身就证明信号 emit 了**（若信号不 emit，await 会卡到测试超时），所以对于「只验证是否 emit」的场景，`await sig` 后断言状态/纹理即可，不必额外计数。
    3. **GdUnit4 内置信号监控**（`monitor_signals(obj)` + `await assert_signal(obj).is_emitted("sig_name")`）是权威方式，但注意 `is_emitted` 是 async（内部 await frame 循环），**必须** `await`，且**不要**在它前面再加 `await await_millis()`（重复等待会冲突）。
  - **反例**：`var count := 0; sig.connect(func(): count += 1)` → count 永远是 0（值类型捕获陷阱）。
  - **适用边界**：所有异步信号（tween/Timer/延迟调用触发的 emit）测试；同步信号（emit 在同一帧同步执行）用 lambda 计数也可能因 await 时序失效，统一改用 Array 容器最稳妥。

### `#流程`

- **Story 前 LLA 文档（Low-Level Architecture，低层级架构设计）**：每个 Story 进入编码实现阶段前**必须**先输出详细的 LLA 文档，覆盖该 Story 涉及的场景节点树、脚本类图、信号通信图、状态机设计（如有）、核心接口/方法签名、数据流与依赖关系。LLA 需与架构文档形成「总-分」关系：模块架构文档定义宏观边界与约束，LLA 聚焦单个 Story 的落地细节。
  - **Why**：Story 是对验收标准的「实现承诺」，没有 LLA 就进编码 → 节点结构随意、信号流转散乱、接口设计临时拼凑，最终导致代码质量差、检视返工多、后续 Story 扩展困难。LLA 是架构到代码的最后一公里桥梁，确保低层设计对齐高层架构、降低团队协作摩擦。
  - **How**：
    1. 在 Story 拆分完成后、TDD 编码开始前（即架构设计阶段），为该 Story 编写 LLA 文档；
    2. **LLA 最低交付物清单（6 项）**：
       - **场景节点树**：该 Story 新增/修改的场景（`.tscn`）完整节点层级（含类型、`%UniqueName` 关键节点标注、挂载脚本），可用 ASCII 树或 Mermaid；
       - **信号通信图**：该 Story 涉及的信号（emit/connect 关系），谁发出、谁接收、携带什么参数，可用 Mermaid 时序图/流程图；
       - **状态机图**（如有）：该 Story 包含的状态机（enum 定义、状态转换触发条件、每状态行为），用 Mermaid 状态图；
       - **类图 + 接口/方法签名清单**：该 Story 需要新增/修改的所有类（`class_name`、`extends`、职责注释）及其公开接口（信号签名、`@export` 变量、公开方法签名含参数类型与返回值类型、`##` 文档注释）。**必须画 Mermaid 类图**（classDiagram）呈现类结构与关系（继承/组合/聚合/订阅），辅以签名清单表格或代码块（**仅签名，不含方法体**）。**禁止在 LLA 中写实现代码体**（如 `func x(): current_mode = target; mode_changed.emit(...)` 是实现，属于编码阶段产物；LLA 只标 `func change_mode(target: GameMode) -> void` 这样的签名 + 一句职责说明）。
       - **测试用例设计表**：该 Story 的全部测试用例（单元测试 + 集成测试）**必须用表格形式输出**，每行一个测试方法，列含：①测试方法名（描述行为，如 `test_change_mode_emits_signal`）；②验证的 AC 编号（如 AC2）；③类型（unit/integration）；④输入/前置条件；⑤断言/预期结果。**禁止**用散列文字或代码块罗列测试名，必须表格化以便 review 者一眼看清"每个 AC 由哪些测试覆盖、测试矩阵是否完备"。表格示意：
         | 测试方法 | AC | 类型 | 输入/前置 | 断言 |
         |---------|:--:|:----:|----------|------|
         | `test_change_mode_emits_signal()` | AC2 | unit | change_mode(TUTORIAL) | mode_changed emit，参数==TUTORIAL |
       - **数据流与依赖**：该 Story 涉及的外部依赖（Autoload、跨模块信号、Resource 文件），数据在节点间的流转路径；
    3. LLA 产出后，以 LLA 为基准进行 Story 编码、检视（校验实现与 LLA 的一致性，即设计-实现一致性校验的前置输入）；
    4. 编码过程中若发现 LLA 设计不合理需调整，**必须先更新 LLA 文档再改代码**，禁止先改代码后补文档。
  - **Why（LLA 与实现的边界）**：LLA 是"设计契约"（What + 接口形状），不是"实现草稿"（How）。写实现代码体会迫使 LLA 卷入编码期才该决定的算法/控制流/局部变量，导致 LLA 臃肿、过早固化实现细节、与真实代码双向漂移。类图 + 签名清单聚焦"类有哪些职责、暴露什么接口、类之间什么关系"，让 LLA 保持设计抽象层级，实现自由度留给编码（含 TDD 驱动的具体算法）。
  - **反例**：拆分 Story 后直接写代码，凭记忆或临时构想搭节点结构和信号连接 → 场景节点层次混乱、信号发送方与接收方职责不清、接口命名不一致，导致检视时大面积重构；或 LLA 只写了节点树就编码，遗漏信号/data flow → 通信设计靠临时 hack 补丁解决。

- **每个 story 开发完必须立即刷新状态（frontmatter + README 总表），保持项目进度实时可追踪**：每个 story 通过验收后、进入交付收尾时，**必须同步完成两处状态刷新**，缺一不可：
  1. **story 文件 frontmatter**：`status: todo` → `in_progress`（开发中）→ `done`（通过验收后）；
  2. **进度总表**：Story 清单总表对应行的状态列（⬜/🔵/✅/⛔），以及全局进度统计区块（该 Feature 的 done/todo 计数 + 合计行的完成率）。
  - **Why**：项目若有大量 story，做完不立即刷新状态，总表会持续失真——下次接手时无法判断「哪些已完成、哪些待开发、下一个该做什么」，导致重复开工（如某 Feature 的 story 代码早已完成但 frontmatter 全是 todo，总表显示 0%，实际已 100%）。状态是项目进展的「单一真相源」，不及时刷新等于丢失进度记录。
  - **How**：
    1. story 通过验收（AC 全绿 + 质量门禁通过 + 关卡确认）后，**在同一个 commit 里**更新该 story frontmatter `status: done` + 总表对应行 ⬜→✅ + 统计计数；
    2. 改完 `.md` 后**立即**跑 `qmd update && qmd embed -c <集合名>` 刷索引（见 `#qmd` 规则），否则下次 AI 检索 story 状态会拿到过期快照。
  - **反例**：story 代码写完、测试通过、git commit 了，但 frontmatter 忘记改 todo→done，总表也没更新 → 显示 0% 完成，实际代码已就绪；下次接手的 AI 或开发者被误导，重复开发或误判进度。
  - **与 `#流程 git 提交记录 ≠ story 交付` 的关系**：那条规则强调"完成度审计"（防漏标：代码提交了但没验收就标 done）；本规则强调"及时刷新"（防拖延：验收过了但状态没更新）。两者互补——前者定义"何时算 done"（AC + 门禁 + 关卡全过），本规则定义"确认 done 后必须做什么"（立即刷新 frontmatter + 总表）。

- **项目重置/脚本删除后必查孤儿 .tres（validate_project 的隐藏失败源）**：当项目经历"删除 scripts/"（如重构/重置）后，**必须**跑 `godot-ultimate godot_validate_project` 检查 `assets/resources/**/*.tres` 是否存在「引用已删除脚本」的孤儿资源。这类孤儿 .tres 会让资源检查门禁失败（报 `Missing script: res://scripts/xxx.gd`），但 `validate_scenes` 查不到（场景无断裂），易被漏检。
  - **Why**：.tres 是文本格式，`ext_resource` 里硬编码了脚本路径；脚本删除后 .tres 不会自动清理，成为悬挂引用。validate_project 的 `resources` 检查会扫到，但若只看 `scenes`/`scripts` 维度会误判"全绿"。
  - **How**：
    1. 脚本删除/重构后，**立即**跑 `godot_validate_project`，关注 `resources.errors` 段；
    2. 发现 `Missing script` 孤儿 .tres 时，二选一：① 删除该 .tres（若数据可在对应 Feature 重做时重新生成）；② 补建脚本骨架（若 .tres 数据宝贵需保留）；
    3. 决策依据：孤儿 .tres 所属 Feature 是否在近期开发范围。近期会重做的 → 删除（数据重新生成）；需保留数据的 → 补脚本骨架。
  - **反例**：项目重置删了某脚本，但对应的 .tres 资源仍在 → validate_project 报多个 resource error，门禁失败。若只看 validate_scenes（场景无引用）会误判全绿。
  - **适用边界**：所有经历脚本删除/重构的场景；尤其项目重置、Feature 重做、脚本改名时。

- **Story 完成后必须确认项目启动路径串联（入口脚本加载子场景），否则 F5 验证不可见**：Story 产出独立场景后，若项目启动入口（main.tscn / main.gd）从未 `load/instantiate/add_child` 该场景，F5 运行项目只会看到空场景（脚手架骨架），无法触发手工验证。Story 本身的单元测试可能全绿（独立实例化场景），但「入口串联」是另一个维度的集成问题。
  - **Why**：垂直切片要求每个 Story 完成后产生可见、可交互的产出物（手工验证）。若启动流程未串联，所有 Story 产出都是「孤岛」——独立场景文件存在但运行时不可见，验证无法进行，开发者会误认为"AC 未通过"而浪费排查时间。
  - **How**：
    1. Story 编码完成后、手工验证前，**必须**检查入口脚本（main.gd）是否 load 了本 Story 的场景；
    2. 若是该 Story 是首个可见切片（如主菜单），在 `_ready()` 里先硬编码加载（+ `TODO(next_story_id):` 标记后续迁移）；
    3. 若后续 Story 已有 GameManager 驱动，通过 GameManager 模式切换加载（属后续 Story 职责，不作为当前 Story 的 AC 但需在验证指导中说明串联方式）；
    4. **注意挂载点兼容性**：Control UI 不能挂到 Node2D/Node3D 下（见 `#UI` 规则），需选正确的父节点。
  - **反例**：场景文件完成 + 测试全绿，但入口脚本的 `_ready()` 只有 TODO 注释没 `add_child` → F5 运行后屏幕黑屏（只有脚手架），开发者在无日志报错下排查按钮无响应问题（实际是场景根本没加载），浪费大量时间。
  - **适用边界**：每个新增场景的 Story；尤其首个可见切片、Mid-Feature 产出的 F5 串联验证时。
  - **与 `#场景` / `#UI` 的关系**：本规则解决「场景是否被加载」问题；`#场景` 规则解决「场景结构是否正确」问题；`#UI` 规则解决「UI 节点是否在正确位置接收输入」问题。三者递进：加载→结构→交互。

- **文档生成后必须自检 mermaid 图语法**：任何含 Mermaid 图的文档（GDD 文档、架构文档、设计文档、LLA 文档、ADR、README 等）**在生成/修改完成后**，**必须立即自检**其中所有 mermaid 代码块的语法正确性，发现错误**立即修复**后才能交付（进入下一步流程或提交）。
  - **Why**：Mermaid 图是文档的「设计语言」。但 Mermaid 语法敏感（括号/引号/特殊字符/关键词冲突/节点 ID 与标签混淆等），AI 生成的图极易含隐晦语法错误——文档渲染时图崩成"Parse error"或空白块，读者完全看不到设计意图，文档沦为废纸。LLA/架构文档的图若崩，后续编码就失去设计契约依据。自检是文档质量的最后一道闸门。
  - **How**：
    1. 文档写完（或修改 mermaid 块后），**逐个**检查其中的 ```mermaid 代码块；
    2. 重点查这些常见错误：① 节点标签含括号/引号/特殊字符未用引号包裹（如 `Main["Main (Node)"]` 标签里的 `(Node)` 必须整体在引号内）；② 类图成员类型符号（`+`/`-` 公私、`<<...>>` 注解）遗漏或错位；③ 状态机 `stateDiagram-v2` 的转换箭头 `A --> B: 文字` 冒号后文字含特殊字符；④ 时序图 `participant X as "别名"` 引号缺失；⑤ 图类型声明拼错（`classDiagrma`/`squanceDiagram` 等）；⑥ 中文标点误入（全角括号（）vs 半角()、中文冒号：）。
    3. 有条件时用 mermaid CLI（`mmdc -i file.md`）或在线 live editor 实际渲染验证；无条件则逐行人工 review 关键语法点；
    4. 自检通过后再进入下一步；发现错误立即修正并在 commit message / 交付说明里注明"已自检 mermaid 语法"。
  - **反例**：LLA classDiagram 里写 `class Main { <<class_name Main>> }`——`<<...>>` 是类注解（sterotype）语法，而 `class_name` 是 GDScript 关键字不是 sterotype，渲染器要么报错要么注解变成无意义文本；或节点标签 `MM["MainMenu (已实现)"]` 漏了引号 → 括号被当成节点形状语法解析报错。
  - **适用边界**：所有项目文档（`docs/` 下全部 `.md`）含 mermaid 图时强制；临时笔记/聊天回复里的草图不强制（但建议用 ASCII 图替代）。

### `#GdUnit4`

- **GdUnit4 命令行测试不能用 `--headless`，须用官方 runtest 非 headless 命令**：GdUnit4 的 `plugin.gd` 的 `check_running_in_test_env()` 会检测 `DisplayServer.get_name() == "headless"` 或命令行含 `-a`/`--import` 等参数，判定为"测试环境"后**直接跳过 `_enter_tree` 初始化**（不执行 `GdUnitSettings.setup()` 等）。在 headless 模式下跑 `GdUnitCmdTool.gd` 会得到"No test cases found"（测试套件扫描器依赖的环境未初始化），即使测试类已正确注册到全局类缓存。
  - **Why**：GdUnit4 设计上把"被测环境"和"测试运行器"做了互斥检测——当它发现自己运行在被测项目里（headless/import/selftest），就不激活插件逻辑，避免插件干扰测试。但这导致 headless 命令行根本起不来测试运行所需的初始化。
  - **How（正确命令）**：用 GdUnit4 官方 `runtest.cmd`/`runtest.sh` 脚本封装的非 headless 命令：
    ```bash
    # 官方 runtest 脚本核心命令（非 headless！）
    "$GODOT_HOME" --path . -s -d --remote-debug tcp://127.0.0.1:0 \
      res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://test/unit/"
    ```
    - `-a` 参数路径**必须用 `res://` 协议**（如 `res://test/unit/`），不能用相对路径 `test/unit/`——`DirAccess.open()` 对相对路径返回的 `get_current_dir()` 是绝对磁盘路径，导致与全局类缓存里的 `res://` 路径不匹配，测试套件加载失败。
    - `--remote-debug tcp://127.0.0.1:0`：端口 0 永不绑定，防止脚本解析错误时触发交互式 CLI debugger 的死循环。
  - **反例**：用 `--headless --ignoreHeadlessMode` 跑测试 → 永远 "No test cases found"，白白调试数小时却以为是测试脚本问题。
  - **GdUnit4 assert API 注意**：无 `assert_true()`/`assert_not_null()`；正确写法是 `assert_bool(x).is_true()`、`assert_object(x).is_not_null()`，加失败描述用 `.override_failure_message("msg")` 链式调用。

- **GdUnit4 测试用例中无 `add_child_autoqfree`，用 `auto_free(obj)` + `add_child(node)` 替代**：GdUnit4 测试类继承 `GdUnitTestSuite`，提供 `auto_free(variant) -> Variant` 方法（注册到 execution_context，测试结束后自动 free），以及标准的 `add_child(node)` 方法。旧版 GdUnit3 的 `add_child_autoqfree()` 在 GdUnit4 中不存在，直接调用会报 `Parse Error: Function "add_child_autoqfree()" not found in base self`。
  - **Why**：GdUnit4 重构了资源管理机制，将 auto-free 从 add_child 中分离出来，通过 `auto_free()` 显式注册节点生命周期，测试结束后自动释放。语义更清晰，且避免了 add_child_autoqfree 在多层嵌套场景下的所有权歧义。
  - **How**：`var menu: MainMenu = auto_free(load("res://...").instantiate()) as MainMenu; add_child(menu)`
  - **反例**：`var menu := load("...").instantiate() as MainMenu; add_child_autoqfree(menu)` → parse error。
  - **注意事项**：GDScript 4.7 中 `:=` 与 `auto_free()` 组合会导致 `inferred as Variant` 警告（warning treated as error），必须用显式类型标注 `var menu: MainMenu = ...`。这是 GDScript 4.7 的 `INFERRED_DECLARATION` 警告规则，与静态类型全标注要求一致。

### `#信号`

- **信号总线（EventBus）前向引用类型用 Variant 占位 + TODO 渐进强类型化**：当 Autoload 信号总线（如 EventBus）需要声明跨模块事件，但信号参数引用的自定义类型要等后续 Story 才定义时，**信号参数先用 Variant（无类型标注）**，在每条信号上方用 `# TODO {Story-ID}: {类型}` 注释标注未来类型；后续各 Story 定义类型后逐条改回强类型标注。
  - **Why**：GDScript 信号参数引用未定义类型会**编译报错**（Parse Error），阻断整个脚本。若为了一开始的类型完整就创建一堆空类型骨架，违反单一职责且后续必返工；若永久放弃类型则损失编译期检查。Variant 占位 + TODO 是两者间的平衡：既不阻断编译，又留下明确的强类型化任务标记。
  - **How**：
    1. 内置类型（int/String/StringName/bool）直接保留强类型；
    2. 引用未定义自定义类的参数用无类型 Variant（如 `signal hand_ended(result)` 而非 `signal hand_ended(result: HandResult)`）；
    3. 每条信号上方加 `# TODO F01-12: result: HandResult` 注释（Story-ID + 目标类型）；
    4. 加 `@warning_ignore("unused_signal")` 抑制跨节点订阅告警；
    5. 后续 Story 实现该类型时，grep `# TODO {Story-ID}` 找到对应信号改回强类型。
  - **反例**：为信号类型完整，在脚手架 Story 里创建 11 个空 class_name 骨架 → 范围膨胀、违反单一职责、空类后续还得重构。
  - **与静态类型规范的关系**：全类型标注是**最终态**；本规则是脚手架阶段的**渐进达成策略**，通过 TODO 标记确保最终能收敛到全标注。

- **信号总线（EventBus）信号「不预声明全部」，按 Feature 渐进追加（脚手架阶段留空骨架）**：这是上一条「前向引用类型用 Variant」的**前置策略**。信号总线脚手架阶段，**不要**一次性把架构文档列的全部信号声明出来（即使全用 Variant），而是**只建空骨架**（`extends Node` + 文档注释 + 注释说明"信号按 Feature 渐进追加"），各信号在**对应 Feature 开发时**再追加声明。
  - **Why**：① 架构文档列的信号参数引用了大量后续才定义的类型，即便用 Variant 占位，一次性声明几十个信号会让总线膨胀且大量"暂未使用"；② 信号参数语义会随 Feature 实现演进，过早声明易返工；③ 空骨架 + 渐进追加符合 YAGNI，且每个信号声明时自然带上 `@warning_ignore("unused_signal")`（紧贴目标，避免 parse error，见 `#代码规范` 规则）。
  - **How**：
    1. 脚手架阶段信号总线只写：`extends Node` + `##` 文档注释（说明是纯信号中转站 + 信号按 Feature 渐进声明）+ 注释列出完整事件目录指向架构文档；
    2. **首个信号声明时**，在其正上方加 `@warning_ignore("unused_signal")`（紧贴，不空行）；
    3. 后续每个 Feature 开发时，在总线追加该 Feature 的事件信号（参数类型已定义的直接强类型，跨 Feature 未定义的用 Variant + TODO）；
    4. 用 `grep "^signal " scripts/services/event_bus.gd` 可审计当前已声明信号清单。
  - **反例**：脚手架阶段一次性声明 30+ 信号（架构文档全量），参数全用 Variant → 脚本臃肿、大量 unused、后续改参数语义时大面积返工。
  - **适用边界**：EventBus / 全局信号总线这类"信号先于业务"的骨架文件；模块内信号（父子节点通信）不需要此策略（随模块开发自然声明）。

- **`signal.connect(带默认参方法)` 自动绑定信号参数到首参**：信号 `emit` 时传入的参数会按位置传给连接方法的**前几个参数**，若方法声明了更多参数且这些参数有默认值，则不受影响。例如 `signal pot_updated(amount: int)` 连接到 `func set_pot(amount: int, animated: bool = true)`，emit 时只传 amount，animated 自动取 true。这在「信号只携带部分数据，方法需要更多控制参数」时非常有用。
  - **Why**：GDScript 信号连接的参数绑定规则——信号 emit 时传入的参数会按位置传给连接方法的**前几个参数**，若方法声明了更多参数且这些参数有默认值，则不受影响。
  - **How**：
    1. 信号 `signal pot_updated(amount: int)`；
    2. 方法 `func set_pot(amount: int, animated: bool = true) -> void`；
    3. 连接 `EventBus.pot_updated.connect(set_pot)`（无需 lambda 或 bind）；
    4. emit `EventBus.pot_updated.emit(500)` → 自动调用 `set_pot(500)`，animated 用默认 true。
  - **反例**：为了让信号连接工作，把方法拆成两个（`set_pot(amount)` + `set_pot_animated(amount, animated)`），或用 lambda 包裹 `connect(func(a): set_pot(a, true))` → 冗余，默认参数机制已覆盖。
  - **适用边界**：信号参数 < 方法参数且多出参数有默认值时；若方法参数无默认值或信号参数更多，需用 lambda/bind 显式适配。

### `#FSM`

- **State 节点取消订阅 engine 信号时用 has_signal + is_connected 双重守卫**：状态机 State 节点在 `enter()` 订阅外部对象信号、`exit()` 取消订阅时，`disconnect()` 会在「信号不存在」或「未连接」时报错。正确做法：`enter()` 用 `has_signal("xxx")` 守卫订阅（防止目标对象无该信号），`exit()` 用 `signal.is_connected(callable)` 守卫取消（防止未连接时报错）。可进一步抽取 `_is_connected(signal_ref, target)` 辅助方法消除行超长（>120 字符 LINE001 警告）。
  - **Why**：State 基类要求「无 engine 时安全降级」，且 exit 可能被重复调用或 engine 引用被释放；无守卫的 disconnect 会抛 "Signal 'xxx' is not connected" 运行时错误，破坏状态切换流程。
  - **How**：
    1. `enter()` 订阅前判 `if obj.has_signal("signal_name"):`；
    2. `exit()` 取消前判 `if signal_ref.is_connected(target_callable):`；
    3. 行超长时抽取 `_is_connected(signal_ref: Signal, target: Callable) -> bool` 私有方法（GDScript 的 Signal 是一等公民，可作参数传递）；
    4. 可用 `engine != null` 外层守卫 + has_signal/is_connected 内层守卫双层防护。
  - **反例**：`exit()` 直接调 `engine.stage_changed.disconnect(_on_stage_changed)` → engine 为 null 崩溃，或信号未连接报运行时错误。
  - **适用边界**：适用于 State 节点订阅任意 RefCounted/Node 对象信号的场景；若对象信号集合固定且确定已连接，可省略守卫。

### `#配置`

- **project.godot 的 [input]/[autoload]/[layer_names] 段用 Godot API 脚本生成，禁手写**：
  - **Why**：project.godot 的文件头注释明示"最好用编辑器 UI 编辑"；手写这些段产生的格式可能与编辑器写入的不一致，导致编辑器重载时被覆盖或解析异常。用 `ProjectSettings.set_setting()` + `ProjectSettings.save()` 走 Godot API，保证输出与编辑器完全一致、可复现、可版本对比。
  - **How**：
    1. 写一次性 `@tool extends SceneTree` 脚本，存 `tmp/`（临时文件任务结束必删）；
    2. 用对应 API 写入：`[input]` → `InputMap.add_action()` + `InputMap.action_add_event()`；`[autoload]` → `ProjectSettings.set_setting("autoload/Name", "*res://...")`；`[layer_names]` → `ProjectSettings.set_setting("layer_names/2d_physics/layer_N", "中文名")`；
    3. 最后调 `ProjectSettings.save()` 持久化，`quit()`；
    4. 运行：`$GODOT_HOME --headless --path . --script tmp/xxx.gd`；
    5. 验证 project.godot 输出后删除脚本（临时文件任务结束必删）。
  - **反例**：手写 `[input]` 段的 `Object(InputEventKey,...)` → 字段顺序/类型错乱，编辑器打开后配置丢失或报错。
  - **适用边界**：简单纯文本段（如 `[application]` 的 `config/name`、`[display]` 的 window 设置等编辑器 UI 产出的基础 key-value）手写风险低，不强制脚本生成；但一旦涉及 Godot 对象序列化或数组/字典结构，**必须**走脚本。

- **像素风游戏视口/窗口配置：小视口（固定逻辑分辨率）+ 大窗口覆盖（等比例整数缩放），非视口=窗口**：像素风游戏的分辨率配置原则是 `window/size/viewport_width/height` 设**小值**（作为固定逻辑分辨率，与像素资产尺寸匹配），`window/size/window_width/height_override` 设**大值**（在视口基础上等比例整数放大，让玩家看到的画面不显小）。引擎 stretch mode `canvas_items` + aspect `expand` 会自动将小视口缩放填充到大窗口。
  - **Why**：若视口=窗口（如直接设 1280×720），像素资产在 1280×720 逻辑空间里显得极小，需给每个 Sprite2D 设大 scale 补偿，scale 管理混乱且非整数缩放会模糊。正确做法是「小视口固定逻辑分辨率 + 大窗口整数缩放」——像素资产在小视口里占合理比例，整数缩放（2×/3×/4×）保持像素锐利。
  - **How**：
    1. 确定目标逻辑分辨率（考虑 HUD 布局密度）：经典像素风 16:9 选 `320×180` 或 `640×360`；
    2. 确定窗口覆盖（整数倍缩放）：`1280×720`（4× 缩放）等；
    3. project.godot `[display]` 配置：
       ```
       window/size/viewport_width=320
       window/size/viewport_height=180
       window/size/window_width_override=1280
       window/size/window_height_override=720
       window/stretch/mode="canvas_items"
       window/stretch/aspect="expand"
       ```
    4. Sprite2D 的 scale 基于逻辑分辨率设定（非物理像素）。
  - **反例**：视口直接设 1280×720（=窗口）→ 像素资产占逻辑空间比例极小，必须给每个 sprite 设 scale=2+ 补偿，且非整数缩放模糊。
  - **配套**：`default_texture_filter=0`（Nearest）必须配套设置，否则整数缩放后像素边缘仍会被线性插值模糊。在 project.godot `[rendering]` 设 `textures/canvas_textures/default_texture_filter=0`。

### `#碰撞`

- **纯 UI 无物理交互游戏的 2D 物理层降级策略（配语义占位层而非空置）**：纯 UI 游戏（卡牌/解谜/文字等无物理碰撞交互的游戏），所有点击/拖拽交互走 Control 节点的 `gui_input`/信号，不使用 2D 物理系统（Area2D/PhysicsBody2D）。但碰撞层名规范要求层名非空且用中文，故采用「少量语义占位层」方案：配置 2-3 个预留层（如交互元素/界面元素/触发器），当前不使用但为未来扩展留空间，同时满足合规。
  - **Why**：完全空置 layer_names 会导致编辑器 Layer Names 面板全是空名，违反层名规范；但配置一堆实际用不到的层也是噪音。2-3 个语义占位层是平衡点——合规、有语义、留余地、不过度。
  - **How**：
    1. 评估游戏类型：若有物理碰撞需求 → 按实际用途一物一层命名；若纯 UI 无物理 → 走降级方案；
    2. 降级方案：配 2-3 个语义占位层（如交互元素/界面元素/触发器），在 story 文档记录降级决策；
    3. 用 `#配置` 规则的脚本生成方式写入 `[layer_names]` 段。
  - **反例**：配 32 层全填中文名 → 绝大多数永远用不到，纯噪音；或只配 1 个「通用」层 → 语义不明，后续真要用物理时还得重命名。

### `#UI`

- **Control 节点在 Node2D 子 Viewport 下不接收 GUI 输入事件，必须挂到根 Node 或 CanvasLayer**：Godot 的 GUI 输入分发系统要求 Control 节点位于接收输入的 Viewport 的直接或间接 Control/Viewport 父链中。当 `Control`（如主菜单 MainMenu）作为 `Node2D` 的子节点挂在 `SubViewport` 下时，虽然 Control 仍会被渲染（可见），但鼠标点击等 GUI 输入事件**不会被分发**到该 Control——玩家看到按钮但点击无反应。
  - **Why**：Godot 的 `Viewport.push_input()` → `Viewport._gui_input_event()` 的分发路径中，Control 节点需要在 `gui` 的 control 列表中被注册；Node2D 不是 Control 容器，其下的 Controls 不加入 GUI 输入链表，即便子 Viewport 的 `handle_input_locally` 也为 GUI 事件分发无效（它只影响 embedded 对象的 local input 处理，不改变 Control 的 GUI 注册逻辑）。
  - **How**：
    1. UI 场景（Control 根）添加到**根 Node**（`get_tree().root` 的直属子节点）或 `CanvasLayer` 下——这两种方式都会注册 Control 到主 Viewport 的 GUI 输入链表；
    2. **不要**将 Control UI 添加到 `Node2D`/`Node3D` 子节点下（即使是 SubViewport 内的 Node2D）；
    3. 若架构约束要求 UI 在 SubViewport 内，可改用 `Control` 作为容器（而非 `Node2D`）并在其上设 `anchors_preset=15`。
  - **反例**：入口脚本把主菜单场景（Control 根）`add_child` 到 `%WorldContainer`（Node2D）下 → 可见性通过，但按钮点击无响应。修复：`add_child(main_menu)` 到根 Node 即可。
  - **适用边界**：任何需要交互（按钮/滑块/输入框）的 Control UI 场景加挂载点选择时；纯显示 UI（Label/Sprite 无交互）在 Node2D 下可正常渲染。

### `#场景`

- **SubViewportContainer 必须包含 SubViewport 子节点，且 stretch=true 时禁止手动设 SubViewport.size**：Godot 4 的 `SubViewportContainer` 是纯容器/缩放器，本身不提供画布，**必须**内含一个 `SubViewport` 子节点才能渲染 2D/3D 内容。架构图的 Mermaid 常把 Camera2D/World 直接画在 SubViewportContainer 下（逻辑表示），但实际落地需补 `SubViewport` 中间层（实现表示）。当 `SubViewportContainer.stretch = true` 时，引擎会**自动同步** SubViewport 的 size 到容器尺寸，此时手动设置 `SubViewport.size` 会触发警告并被忽略（`Can't change the size of a SubViewport with a SubViewportContainer parent that has stretch enabled`）。
  - **Why**：SubViewportContainer 的设计是「容器负责缩放，SubViewport 负责画布」；stretch 模式下容器接管尺寸控制权，手动设 size 会破坏自动同步逻辑。架构图省略 SubViewport 是为了简洁，但实现时必须补上，否则场景无渲染画布。
  - **How**：
    1. 节点树：`SubViewportContainer → SubViewport → (Camera2D + Node2D 内容)`；
    2. 在 SubViewportContainer 上设 `stretch=true` + 容器 `size`（或用 anchors/layout 让容器自适应窗口）；
    3. **不要**手动设 SubViewport.size（stretch 模式下自动同步）；若需固定逻辑分辨率独立于容器，用 `SubViewport.size_2d_override` + `size_2d_override_stretch`；
    4. 响应式窗口缩放：监听容器 `resized` 信号，在脚本中同步处理。
  - **反例**：把 Camera2D 直接挂在 SubViewportContainer 下（无 SubViewport）→ 无画布，内容不渲染；或在 stretch=true 时硬设 SubViewport.size → 警告且不生效。
  - **架构图与实现的关系**：架构 Mermaid 图是逻辑/概念表示，允许省略实现细节节点（如 SubViewport 中间层）；LLA 文档应显式记录这类「图 vs 实现」的差异决策，避免实现者困惑。

- **PackedScene.pack 序列化只保存 owner==根节点的子节点（多层嵌套场景必须统一设 owner）**：用脚本（`@tool extends SceneTree`）批量搭建场景节点树时，`PackedScene.pack(root)` 只会序列化 `owner == 根节点` 的节点。若子节点的 owner 被设成其直接父节点（非根），pack 时会被**静默丢弃**——运行时 `get_children()` 看得到，但保存到 `.tscn` 后再加载，嵌套层级的子节点会消失。
  - **Why**：Godot 的 owner 机制设计用于「场景内可继承节点追踪」——一个节点只有 owner 为场景根时才算"属于这个场景"，否则被视为临时节点。嵌套层级（如 `BattleTable → PlayerSeat → PlayerHoleCards`）中，PlayerHoleCards 的 owner 必须是 BattleTable（根），而不是 PlayerSeat（中间层）。
  - **How**：
    1. 批量搭建时维护一个 `_root` 引用，`_add_child(parent, name, type)` 内统一设 `node.owner = _root`（而非 `parent`）；
    2. 保存前用 `print_tree()` 打印运行时树结构，保存后重新 `load().instantiate()` 再打印一次对比，确认无节点丢失；
    3. 若必须分场景/子场景，用 `pack_scene` 对子根单独 pack 成独立 `.tscn`，再 `instance` 到父场景（此时 owner 关系由编辑器/引擎自动处理）。
  - **反例**：`_add_child` 里写 `node.owner = parent` → PlayerSeat 下的 PlayerHoleCards/PlayerChips 被 pack 丢弃，`.tscn` 里只剩一级子节点。
  - **与编辑器的关系**：在 Godot 编辑器里手动添加节点时，编辑器会自动把 owner 设为场景根，无需手动处理；本规则仅针对脚本化搭建场景。

- **动态子节点非动画移除用 remove_child + free（同步），queue_free 是帧末执行（get_child_count 不立即更新）**：运行时动态 `add_child` 的节点（如筹码精灵/子弹/特效），在测试或同步逻辑中需要立即移除并让 `get_child_count()` 反映变化时，**不能用 `queue_free()`**——它只是标记「在本帧结束时释放」，节点在当帧仍然挂在父节点上，`get_child_count()` 不会立即减 1。必须用 `parent.remove_child(node)` + `node.free()` 才能同步移除。
  - **Why**：`queue_free()` 设计用于 `_process`/信号回调中安全释放（避免遍历中修改节点树），代价是延迟到帧末；而单元测试的断言是同步的，`queue_free` 后立即 `assert_int(get_child_count()).is_equal(N)` 会失败（实际还是 N+1）。`free()` 是同步立即释放（慎用：若该帧还有引用会崩溃，但配合 `remove_child` 先断开父子关系后是安全的）。
  - **How**：
    1. **动画/运行时移除**（允许延迟）：`node.queue_free()`（配合 Tween 回调 `tween_callback(node.queue_free)`）；
    2. **测试/同步立即移除**：`parent.remove_child(node); node.free()`（先断开父子关系，再 free，避免其他系统在同一帧访问）；
    3. **批量清空**：`for c in parent.get_children(): c.queue_free()`（帧末统一清，若需同步则改 `remove_child + free`）。
  - **反例**：测试中 `set_amount(0, animated=false)` 内部用 `chip.queue_free()`，紧接着 `assert_int(chip_container.get_child_count()).is_equal(0)` → 失败，实际为原数量（queue_free 未执行）。
  - **适用边界**：仅当需要「移除后立即在同一执行流中验证子节点数」时必须同步 free；纯运行时逻辑（不依赖即时 get_child_count）用 queue_free 更安全。

- **.tscn 脚本引用必须带 uid（ext_resource uid=），仅 path 无 uid 时 instantiate as ClassType 返回 null**：手写或 MCP 生成的 `.tscn` 文件中，`[ext_resource type="Script" path="res://xxx.gd" id="N"]` 若**不带 `uid="uid://..."`**，场景加载时脚本能被识别（节点有 script 属性），但 `packed.instantiate() as MyClass` 会返回 **null**——因为缺少 uid 时引擎无法将脚本正确关联到全局 class_name 缓存，类型转换失败。
  - **Why**：Godot 4 的资源引用优先用 uid（path 可变，uid 不变）；ext_resource 无 uid 时，实例化的节点 script 属性虽指向脚本，但 `as` 类型转换走的是 class_name 注册表，缺 uid 导致注册表匹配失败返回 null。
  - **How**：
    1. 脚本创建后先查 `.uid` 文件（`cat xxx.gd.uid` → `uid://xxxxx`）；
    2. `.tscn` 的 ext_resource 写 `[ext_resource type="Script" uid="uid://xxxxx" path="res://xxx.gd" id="N"]`（uid + path 双保险）；
    3. 节点引用 `script = ExtResource("N")`；
    4. 验证：`var node = packed.instantiate() as MyClass; assert(node != null)`。
  - **反例**：`[ext_resource type="Script" path="res://scripts/battle/chip_stack.gd" id="1"]`（无 uid）→ `instantiate() as ChipStack` 返回 null，集成测试报 Nil 访问错误。
  - **适用边界**：所有 `.tscn` 挂载脚本的场景；用 MCP `add_node` 生成的场景 MCP 会自动补 uid，手写/文本编辑补丁时必须手动补。

### `#动画`

- **Label 数字滚动用 tween_method(int→int) + 逐帧回调更新 .text，重入前 kill 旧 Tween**：实现「数字从旧值平滑滚动到新值」的动画（如底池金额、分数、血量数字），正确做法是用 `create_tween().tween_method(回调, 起始值, 目标值, 时长)`，回调函数逐帧接收插值后的 int 并更新 `Label.text = str(value)`。**不要**用 `tween_property` 直接 tween Label.text（String 无法线性插值）；也**不要**手动在 `_process` 里 lerp（重复造轮子且帧率敏感）。
  - **Why**：`tween_method` 接受任意类型的起始/目标值（包括 int），引擎在每帧调用回调并传入当前插值结果；对 int 数值滚动，回调只需 `func _set_displayed(value: int) -> void: current = value; label.text = str(value)`。这比 `_process` 手动 lerp 更简洁、帧率无关、且能与 Tween 的 kill/finished 信号联动。
  - **How**：
    1. 定义逐帧回调：`func _set_displayed_pot(value: int) -> void: current_pot = value; _pot_label.text = str(value)`；
    2. 启动动画：`_roll_tween = create_tween(); _roll_tween.tween_method(_set_displayed_pot, current_pot, target_pot, 0.4)`；
    3. **重入保护**：若动画中再次触发，先 `_roll_tween.kill()` 再起新 Tween，否则两个 Tween 抢同一属性产生抖动；
    4. **终点精确**：Tween 完成后用一个 `tween_callback` 或在 finished 信号里强制 `current = target`（防止浮点插值误差导致终点差 1）；
    5. 瞬变模式（animated=false）：直接 `current = target; label.text = str(current)` 跳过 Tween。
  - **反例**：`tween.tween_property(label, "text", "800", 0.4)` → String 无法插值，报错或无效果；或 `_process` 里 `current = lerp(current, target, delta * speed)` → 帧率敏感、到达判定麻烦、与 Tween 体系割裂。
  - **适用边界**：所有「数值平滑过渡并同步显示」的场景（底池/分数/血量/经验条数字）；纯属性动画（position/scale/color）用 tween_property 即可。

### `#代码规范`

- **Godot 4.7 枚举类型变量必须设显式默认值（ENUM_VARIABLE_WITHOUT_DEFAULT 警告）**：Godot 4.7 起，声明为枚举类型（自定义 `enum` 或内置枚举）的成员变量若未设默认值，会触发 `ENUM_VARIABLE_WITHOUT_DEFAULT` 警告（"The variable X has an enum type and does not set an explicit default value. The default will be set to 0"）。虽然默认值 0 通常对应枚举首项，但引擎要求显式声明以避免语义歧义（0 可能不是开发者期望的初始状态）。
  - **Why**：GDScript 的静态分析在 4.7 加强了枚举类型安全——隐式默认值可能掩盖"变量未初始化"的逻辑漏洞。显式默认值让代码意图清晰，也消除编辑器加载时的警告噪音。
  - **How**：
    1. 声明枚举变量时同步给默认值：`var suit: Suit = Suit.SPADE`、`var current_stage: Stage = Stage.HAND_END`；
    2. 默认值应与 `_init()` 的默认参数保持语义一致（如 Card 的 `_init(p_suit = SPADE)` 对应 `var suit = Suit.SPADE`）；
    3. 其他常见 4.7 警告配套修法：`UNUSED_PARAMETER` → 参数前缀 `_`；`UNUSED_SIGNAL`（跨节点订阅的 Autoload/引擎信号）→ `@warning_ignore("unused_signal")`；`INTEGER_DIVISION`（筹码/金额整数运算）→ `@warning_ignore("integer_division")`。
  - **反例**：`var type: ActionType` 无默认值 → 编辑器加载时每个实例报警告，污染 Output 面板。
  - **适用边界**：适用于所有 `enum` 类型的成员变量；普通 `int`/`String`/`bool` 不触发此警告（但 `bool` 建议也显式设默认值提升可读性）。

- **GDScript 4.7 const Dictionary 不能引用其他类枚举成员（非常量表达式）**：声明 `const` 修饰的 Dictionary 字面量时，其值不能引用其他类的枚举成员（如 `OtherClass.EnumName.MEMBER`），因为编译器认为这是「非常量表达式」（const 要求编译期完全可求值，跨类枚举引用在 GDScript 中不被视为编译期常量）。会报 `Cannot use a non-constant expression in a constant expression` 错误。
  - **Why**：GDScript 的 const 语义比某些语言严格——跨类符号引用不被当作编译期常量，即便枚举值在源码里是固定的。
  - **How**：把 const Dictionary 改为 `_init()` 里用 `var` 初始化的成员变量（运行时赋值，无编译期常量约束），或在同一类内用局部 int 字面量代替跨类枚举引用。
  - **反例**：`const TABLE = { "key": OtherClass.Mode.A }` → 编译报错「non-constant expression」。
  - **适用边界**：所有跨类枚举引用的 const 字面量；同类内枚举引用的 const Dictionary 通常可用。

- **GDScript 4.7 Array 不能隐式赋给 Array[T] 等强类型数组，需逐个 append 或 clear+append**：声明为强类型数组（`Array[Card]`/`Array[String]` 等）的变量，不能直接把一个普通 `Array`（无类型）整体赋值给它（即便元素类型匹配），会报类型不匹配。必须逐个 `append`，或先 `clear()` 再循环 `append`。
  - **Why**：GDScript 4.7 的强类型数组是「值类型 + 类型守卫」，整体赋值会触发类型检查失败（源 Array 的元素类型在编译期无法证明全部是 T）。
  - **How**：
    1. 逐个 append：`for item in source_array: typed_array.append(item)`；
    2. 或 clear + append：`typed_array.clear(); for item in source_array: typed_array.append(item)`；
    3. 若源也是同类型强类型数组，可直接赋值（`typed_a = typed_b` 合法）。
  - **反例**：`var typed: Array[Card] = untyped_array` → 类型不匹配报错。
  - **适用边界**：所有强类型数组（`Array[T]`）的初始化与赋值；普通 `Array`（无类型参数）不受此限。

- **禁止 override Node 原生方法 set_name（签名不匹配编译报错）**：GDScript 中若自定义方法命名为 `set_name`，会与 Node 原生方法 `set_name(StringName) -> void` 冲突，编译报两个错误：① "The function signature doesn't match the parent. Parent signature is 'set_name(StringName) -> void'"；② "The method 'set_name()' overrides a method from native class 'Node'. This won't be called by the engine and may not work as expected."（Warning treated as error）。这会导致脚本完全无法加载（`Failed to load script with error "Parse error"`）。
  - **Why**：Node 是 Godot 的基础节点类型，`set_name` 是其原生方法（用于设置节点名称，参数是 StringName 而非 String）。GDScript 4.7 严格禁止 override 原生方法且签名不一致；即使签名一致也不建议 override（引擎调用的是原生版本，你的 override 不会被调用）。
  - **How**：
    1. 自定义「设置显示名字」方法时，**避开 `set_name`**，改用语义化的方法名：`set_player_name(name)` / `set_ai_name(name)` / `set_display_name(name)`；
    2. 同理避开其他 Node 原生方法名：`get_name`/`add_child`/`remove_child`/`get_parent`/`set_position` 等；
    3. 若需设置节点名称（节点树中的 name 属性），直接赋值 `node.name = "xxx"` 或调用原生 `node.set_name(StringName("xxx"))`，不要自定义同名方法。
  - **反例**：`func set_name(player_name: String) -> void: name_label.text = player_name` → 编译报错 "function signature doesn't match the parent"，脚本加载失败。
  - **适用边界**：所有继承 Node（含 Node2D/Control/Sprite2D 等子类）的脚本；RefCounted/Object 子类不受此限制（无 set_name 原生方法）。

- **`@warning_ignore("unused_signal")` 必须紧贴有效目标（signal 声明），单独放文件顶部会 parse error**：GDScript 的 `@warning_ignore` 注解要求**紧跟一个有效的声明目标**（函数/变量/信号/类声明等）。若把 `@warning_ignore("unused_signal")` 单独写在脚本注释块下方、但后面没有紧跟 `signal xxx` 声明（例如该文件当前还没有任何信号），会报 `Parse Error: Annotation "@warning_ignore" does not precede a valid target, so it will have no effect`，导致 autoload 脚本加载失败 → 项目无法启动（`Failed to instantiate an autoload`）。
  - **Why**：注解必须依附于具体的声明节点；"暂无目标"的注解在 GDScript 语法上非法。
  - **How**：
    1. `@warning_ignore("unused_signal")` 写在**首个 `signal xxx` 声明的正上方**（紧贴，中间不空行）；
    2. 若信号总线当前无信号（骨架阶段），**不要**写该注解——等首个信号声明时再加；或用注释占位说明「首个信号声明时在其上方加 @warning_ignore("unused_signal")」；
    3. 其他 `@warning_ignore` 同理：必须紧贴目标声明。
  - **反例**：骨架阶段写 `extends Node` + 文档注释 + `@warning_ignore("unused_signal")` + 空行 + `# === Signals ===`（无信号声明）→ parse error，autoload 加载失败，引擎启动崩溃。
  - **适用边界**：所有 GDScript 脚本；尤其 EventBus/Autoload 这类"信号先于实现"的骨架文件。

### `#MCP`

- **godot-mcp 的 add_node 运行环境不加载 autoload，引用 autoload 的脚本编译失败**：godot-mcp 的 `add_node`/`create_scene` 等操作在后台跑一个精简 Godot 实例（非完整编辑器），该实例**不加载 autoload 单例**（ThemeManager/EventBus 等）。当场景中已挂载（或即将挂载）引用 autoload 的脚本时，MCP 加载场景会报 `Compile Error: Identifier not found: 'ThemeManager'`，导致操作失败（即使只是给同级节点加属性）。
  - **Why**：这与「headless SceneTree 脚本无法给引用 autoload 的脚本 set_script」同源——都是「精简环境不加载 autoload」问题。godot-mcp 的后台实例虽非 headless，但 autoload 初始化依赖完整编辑器生命周期，MCP 的脚本化操作不触发。
  - **How**：
    1. **优先用最小文本补丁**：直接编辑 `.tscn` 文本（补 `[ext_resource type="Script" uid=... path=...]` + `script = ExtResource(...)` + 节点属性），这是最可靠的方式；
    2. **避免在已挂 autoload 脚本的场景上用 MCP add_node**：先建空场景（无脚本），用 MCP 加节点，再用文本补丁挂脚本；
    3. **属性设置也用文本补丁**：Label 的 offset/alignment、Node 的 position 等，直接写 `.tscn` 属性行比 MCP properties 参数更可靠（后者对部分属性不生效，见下一条经验）。
  - **反例**：场景已挂某脚本（引用 ThemeManager），再用 MCP add_node 给某 Label 设属性 → `Compile Error: Identifier not found: 'ThemeManager'`，操作失败。
  - **适用边界**：所有引用 autoload/class_name 外部符号的脚本场景；纯内置节点（无自定义脚本）的场景 MCP add_node 正常。

- **godot-mcp add_node 的 properties 对 Vector2/Vector2i size 字段设置无效，需用 API 脚本补设**：godot-mcp 的 `add_node` 操作支持 properties 参数，但对 `SubViewport.size`、`SubViewportContainer.size` 等 Vector2/Vector2i 类型属性的设置不生效（节点创建成功但值保持默认，如 SubViewport 默认 size=Vector2i(2,2)）。其他属性（bool 的 stretch、int 的 layer）设置正常。
  - **Why**：疑似 godot-mcp 对 Vector2 类型属性的序列化/赋值处理有缺陷，或这些属性是只读的计算属性（stretch 模式下 size 由容器管理）。
  - **How**：
    1. 用 godot-mcp `add_node` 创建节点 + 设置简单属性（bool/int/float/String）；
    2. 对未生效的 Vector2/Vector2i 属性，用一次性 `@tool extends SceneTree` 脚本 `load → instantiate → set → pack → ResourceSaver.save` 补设；
    3. 顺便在同脚本中完成改名（根节点 `root` → `Main`）、挂脚本（`set_script(load(...))` 等批量操作。
  - **反例**：依赖 godot-mcp properties 传 `{"size": [1280, 720]}` → 节点创建了但 size 仍是默认值。
  - **适用边界**：本经验基于当前 godot-mcp 版本，后续版本可能修复；使用前先用简单案例测试 properties 是否生效。

- **headless SceneTree 脚本无法给「引用 autoload 的脚本」set_script（编译失败）**：用 `@tool extends SceneTree` 一次性脚本给场景节点挂脚本（`node.set_script(load("xxx.gd"))`）时，若 `xxx.gd` **编译期引用了 autoload 单例**（如 `ThemeManager`、`EventBus`），在 headless `--script` 模式下会报 `Compile Error: Identifier not found: 'ThemeManager'`——因为 autoload 只在项目主场景运行时初始化，headless SceneTree 不加载 autoload 配置，导致脚本编译期符号解析失败，`set_script` 静默失败，`pack` 保存的 `.tscn` 里脚本引用丢失（重新 instantiate 后 `get_script()` 返回 null）。
  - **Why**：GDScript 编译期需要解析全局符号（autoload 名、class_name），headless SceneTree 环境不提供 autoload 实例，编译就失败；即便注入占位 Node 到 `/root` 也没用（autoload 解析依赖 ProjectSettings 配置 + 全局脚本类缓存，非运行时节点）。
  - **How（正确方式）**：
    1. **用 godot-mcp / 编辑器**（运行在完整项目环境，autoload 可用）配置场景脚本；
    2. 或**最小文本补丁**：直接在 `.tscn` 加 `[ext_resource type="Script" path="res://xxx.gd" id="..."]` + node 的 `script = ExtResource(...)` 两行（仅脚本引用，不涉及 UID/sub_resource，风险低）；
    3. **禁止**用 headless SceneTree 脚本给引用 autoload 的脚本 set_script。
  - **反例**：`@tool extends SceneTree; node.set_script(load("res://scripts/battle/card_sprite.gd"))`（card_sprite.gd 引用 ThemeManager）→ `Compile Error: Identifier not found: 'ThemeManager'`，脚本挂载失败。
  - **适用边界**：仅当目标脚本**不引用任何 autoload/class_name 外部符号**时，headless SceneTree set_script 才有效；引用 autoload 的脚本必须用编辑器/MCP/文本补丁。

### `#qmd`

- **修改项目 md 文档后必须刷新 qmd 索引保持同步**：每次新增/修改/删除任何项目 `.md` 文档后，**必须**立即跑索引更新命令，确保后续 `qmd search`/`qmd query` 检索命中最新内容（否则语义检索会基于过期快照，命中旧版文档或漏掉新增内容）。
  - **Why**：qmd 的 BM25 词法索引与向量嵌入都是本地缓存（`.qmd/`），文件改动后不会自动重算；若忘记刷新，AI 检索设计文档/story/MEMORY 时会拿到过期内容，导致设计-实现一致性校验、Wiki 经验查询等环节基于陈旧信息做判断，引入隐蔽错误。
  - **How**：
    1. 改动 `.md` 后立即执行：`qmd update && qmd embed -c <集合名>`；
       - `qmd update`：扫描集合内文件变更（新增/修改/删除）、刷新文件列表与词法索引；
       - `qmd embed -c <集合名>`：为新增/变更的文档生成向量嵌入；
    2. **提交代码前若改动了 `.md`，commit 前必须先跑一次**索引更新；
    3. 若一次性改动较多文档，`embed` 耗时可能数分钟，可后台运行不阻塞其他工作。
  - **反例**：更新了某 story 的 frontmatter 状态（如 `todo → done`）后直接提交，未刷索引 → 下次 AI 用 qmd 检索该 story 时仍显示 `todo`，误判为「未完成」而重复开工。

- **qmd 集合初始化必须用 `--name` 显式命名，禁无参/把名字当路径传**：为新项目首次配置 qmd 集合时，正确语法是 `qmd collection add <目录路径> --name <集合名>`（如 `qmd collection add docs --name my-project`）。**不要**写成 `qmd collection add <集合名> "<paths>"`（这是 Skill 文档里的伪代码占位，实际 qmd CLI 把首个位置参数当目录路径，会把集合名解析成磁盘路径，生成 `Pattern: **/*.md` 且 `Files: 0` 的空集合）；也**不要**无参调用 `qmd collection add`（会把整个项目根 `**/*.md` 扫进去，含 `addons/`/`.zcode/`/`.opencode/`/`.godot/` 等第三方/工具目录，违反强制排除规则）。
  - **Why**：qmd 一个集合绑定单一目录路径（`collection show` 可见 `Path: <目录> Pattern: **/*.md`），不支持在同一集合附加散落文件；Skill 文档示例的 `qmd collection add {name} "paths"` 是抽象写法，实际 CLI 参数顺序是 `<path> [--name <name>]`。误用会踩两个坑：① 集合名变成路径 → 空集合；② 无参 → 全根扫描污染索引。
  - **How（正确初始化流程）**：
    1. 确定索引目录（通常为 `docs/`，排除 `addons/`/`.zcode/` 等第三方/工具目录）；
    2. `qmd collection add docs --name <项目名>`（路径在前，`--name` 在后）；
    3. `qmd embed -c <项目名>`（生成向量嵌入）；
    4. `qmd ls <项目名> | wc -l` 验证文档数 + `qmd search "<关键词>" -c <项目名> -n 3` 验证可检索；
    5. 根目录散落 md（`AGENTS.md`/`README.md`）因 qmd 集合绑定单目录无法纳入，需读取时用 `read` 工具（位置固定、内容稳定）。
  - **反例**：① `qmd collection add my-project "docs/,AGENTS.md,README.md"` → 输出 `Collection: .../my-project (**/*.md) Files: 0`（把 my-project 当路径）；② 无参 `qmd collection add` → 索引含 `.opencode/`/`.zcode/`/`addons/gdUnit4/` 等第三方 md，违反排除规则。
  - **与「刷新索引」规则的关系**：本规则管「首次初始化集合」（`collection add` + 首次 `embed`），上一条管「日常改动后同步」（`update` + `embed`）。初始化是一次性操作，同步是持续性操作。
  - **排错信号**：`qmd status` 若出现 `Pattern: **/*.md`（而非相对路径 pattern）或 `Files: 0`，说明集合创建语法错误，需 `qmd collection remove <错误名>` 后用 `--name` 重建。

### `#架构`

- **Autoload 骨架先行：所有单例空骨架 + main.tscn 分层占位，解除后续 story 启动阻塞**：项目重置/初始化时，**第一步**就应建立所有 autoload 单例的空骨架脚本（`extends Node` + 文档注释 + 占位空方法）+ main.tscn 根场景分层占位（SubViewportContainer + 多个 CanvasLayer），让 `project.godot` 的 `[autoload]` 与 `main_scene` 引用全部有效。**不要**等后续 Feature 开发时才逐个补 autoload——那样 project.godot 会处于断裂状态，引擎无法启动，阻塞所有 story。
  - **Why**：project.godot 的 autoload 引用若指向不存在的脚本，Godot 启动会报 `Failed to instantiate an autoload` 并崩溃；main_scene 指向不存在的 .tscn 同理。这是**阻塞性**问题，优先级最高。骨架先行让项目立即可启动，后续每个 Feature 在骨架上填充业务逻辑。
  - **How**：
    1. 识别 project.godot `[autoload]` 段的所有单例（如 GameManager/SaveManager/AudioManager/ThemeManager/SettingsManager/EventBus）；
    2. 每个单例创建最小空骨架：`extends Node` + `##` 文档注释 + 必要的枚举（如 GameManager 的 GameMode，被其他 story 引用属必要前置）+ 占位空方法（带 `# TODO(feature-id):` 指向后续实现 story）；
    3. **禁 `class_name`**（Singleton 用全局名访问）；**代码除注释外无中文**；
    4. 信号总线（EventBus）走「渐进式声明」策略（见 `#信号` 规则），不预声明全部信号；
    5. main.tscn 按技术架构建分层占位（SubViewportContainer + SubViewport + Camera2D + WorldContainer(%Unique) + 多个 CanvasLayer 分层 HUD/Pause/Popup/Top）；
    6. 完成后跑 `godot --headless --import` 验证无报错 + GdUnit4 测试验证 autoload 可访问。
  - **反例**：项目重置后直接开始首个 Feature 开发，没先补 autoload 骨架 → project.godot 引用不存在的脚本，引擎启动崩溃，首个 Feature 无法运行验证。
  - **适用边界**：项目初始化、项目重置后恢复、新增 autoload 单例时。

<!-- 原则新增分组格式：
### `#新标签`

- **规则名**：详细描述（含 Why / How / 反例）
-->

---

## 📋 实例档案

> 场景化案例（规则的来源佐证），按日期倒序。每条含：标签 / 场景 / 教训 / 沉淀规则指针。
> 注：以下案例源自 `godot-texas` 项目，仅保留可跨项目复用的教训，项目专属细节（如特定素材、特定游戏算法）已剔除。

### 2026-07-12 ｜ LLA 规范修正（LLA 禁实现代码、画类图+签名、测试用例表格化）

- **标签**：`#流程`
- **场景**：某 GameManager 状态机 LLA 初稿犯了两个形式错误：①「核心接口」一节直接贴完整实现代码体（`func change_mode(target): current_mode = target; mode_changed.emit(target)` 含控制流/赋值/emit 调用）；②「测试设计」一节用散列文字 + 代码块罗列测试方法（`func test_a(): ...` / `func test_b(): ...`），未表格化。review 连续两次指出规范偏差："LLA 中不需要写实现代码，但是要画类图，标明类名、函数名、函数签名等"；"需要在 LLA 用表格输出测试用例设计"。
- **教训**：LLA 是**设计契约**（What + 接口形状 + 验证矩阵），不是**实现草稿**（How）。两个形式问题的共同根因是把 LLA 当成"代码草稿纸"而非"设计文档"：
  - 贴实现代码体 → LLA 卷入编码期才该决定的局部变量/控制流，过早固化，与真实代码双向漂移，review 注意力被实现细节分散。
  - 测试用例散列文字 → review 者无法一眼判断"每个 AC 由哪些测试覆盖、测试矩阵是否完备（正常/异常/边界/分支）"，掩盖覆盖盲区。
  - 正确形式：类图（Mermaid classDiagram，类结构+关系）+ 签名清单（表格或仅签名代码块）+ **测试用例设计表**（方法/AC/类型/输入/断言五列），三者共同构成"接口契约 + 验证矩阵"，把 How 留给编码与 TDD。
- **沉淀规则**：→ 见 `#流程 Story 前 LLA 文档`（LLA 最低交付物扩为 6 项：①场景节点树 ②信号通信图 ③状态机图 ④类图+签名清单 ⑤**测试用例设计表** ⑥数据流与依赖；其中 ④禁实现代码体、⑤必须表格化）

### 2026-07-12 ｜ 脚手架重建（项目重置后恢复 autoload + main.tscn 分层）

- **标签**：`#架构` `#代码规范` `#流程` `#信号`
- **场景**：项目经历代码与文档重置后，`scripts/` 与 `scenes/` 全空，但 `project.godot` 仍引用多个 autoload 脚本 + `main.tscn`，引擎无法启动（断裂状态）。重建过程中遇到三个坑：① 信号总线骨架把 `@warning_ignore("unused_signal")` 放文件顶部（无 signal 目标）→ parse error 导致 autoload 加载失败；② validate_project 发现多个 .tres 引用已删脚本（孤儿资源）；③ main.tscn 脚本引用 headless 打包不带 uid。
- **教训**：
  1. `@warning_ignore` 必须紧贴有效声明目标，无目标时 parse error 会让 autoload 加载失败 → 整个项目启动崩溃（`#代码规范`）；
  2. 脚本删除后必查孤儿 .tres（`#流程`），validate_project 的 resources 维度是唯一能查到的门禁；
  3. 信号总线信号不预声明全部（`#信号`），按 Feature 渐进追加避免引用未定义类型编译失败；
  4. Autoload 骨架先行（`#架构`）是项目启动的前置条件，优先级最高。
- **沉淀规则**：→ 见 `#代码规范 @warning_ignore 位置` / `#流程 孤儿.tres清理` / `#信号 信号总线渐进式声明` / `#架构 Autoload骨架先行`

<!-- 实例新增条目格式：
### YYYY-MM-DD ｜ {任务名}

- **标签**：`#标签1` `#标签2`
- **场景**：什么情况下遇到 / 做了什么决策
- **教训**：学到了什么 / 根因
- **沉淀规则**：→ 见 `#标签 规则名`（指向通用原则）
-->

---

## 📝 维护指南

### 新增经验的标准流程

1. **先查重**：扫「快速检索表」是否已有同类规则
2. **已有规则** → 仅在「实例档案」补充新案例（标签 / 场景 / 教训 / 指针）
3. **新规则** → ① 在「通用原则」对应 `#标签` 分组新增详细规则；② 在「快速检索表」加一行索引；③ 在「实例档案」记录来源案例

### 标签命名约定

- **小写下划线**：`#标签名`（如 `#数据驱动`、`#代码规范`）
- **主题分类**：技术领域（`#FSM`/`#碰撞`/`#UI`）、工具（`#GdUnit4`）、流程（`#架构`/`#测试`/`#代码规范`）
- **类型标记**：本文档所有条目均为「通用」（跨 Godot 项目可复用）

### 结构原则

- **不重复**：同一规则只在「通用原则」出现一次（详细版），「实例档案」只放案例不放规则全文
- **指针互联**：实例 → 原则（`→ 见 #标签 规则名`），原则不反向指实例（避免循环）
- **倒序追加**：实例档案按日期倒序（最新在上），原则分组内顺序无关紧要
- **AI 友好**：检索表用一句话索引，详细规则在原则段；AI 扫检索表即可判断是否命中，无需读全文
