# TDD 测试规范

> Godot 4.x / GdUnit4 测试驱动开发规范。AI 在**阶段 9（TDD 开发）**写测试时**必须**加载并遵循本规范。
> 与 `test-driven-development` Skill（TDD 流程纪律）+ GdUnit4（测试工具）协同。
> 每条含：规范说明 + 正例（✅）+ 反例（❌）。

---

## 一、TDD 核心纪律

### 1. 先写失败测试（铁律）

**说明**：任何产品代码之前，**必须**先有一个失败的测试。先写实现再补测试不算 TDD——测试一跑就过，无法证明它测对了东西。

**正例**（✅）：先写 `test_take_damage_reduces_health`，运行看到它失败（方法不存在），再实现 `take_damage`。

**反例**（❌）：先把 `take_damage` 写好，再补测试——测试立即通过，等于没验证。

### 2. 红 → 绿 → 重构

**说明**：严格三步循环——写失败测试（红）→ 写最小实现使其通过（绿）→ 重构清理（保持绿）。

**正例**（✅）：红（写测试）→ 验证失败 → 绿（最小实现）→ 验证通过 → 重构（去重/改名）→ 进入下一轮。

**反例**（❌）：跳过「验证失败」；或绿之后顺手加测试未要求的功能。

### 3. 必须亲见测试失败

**说明**：写完测试**必须**运行，确认它**因预期原因失败**（功能缺失），而非笔误或编译错误。

**正例**（✅）：运行测试，看到失败信息「`take_damage` 不存在」——符合预期。

**反例**（❌）：写完测试直接写实现，从不观察失败态；或失败原因是拼写错误却未察觉。

### 4. GREEN 只写最小实现

**说明**：只写让测试通过的**最简**代码，禁止提前实现测试未覆盖的功能（YAGNI）。

**正例**（✅）：
```gdscript
func take_damage(amount: int) -> void:
    current_health -= amount   # 够过即可
```

**反例**（❌）：
```gdscript
func take_damage(amount: int, source: Node = null) -> void:
    current_health -= amount
    _play_hit_effect()         # 测试未要求
    _notify_attacker(source)   # 提前实现
```

---

## 二、测试组织

### 5. 测试文件命名与路径镜像

**说明**：测试文件 `源名_test.gd`，放 `test/unit/` 下，子目录**镜像源码相对路径**（见目录规范第六节）。

**正例**（✅）：`scripts/utils/math_utils.gd` → `test/unit/scripts/utils/math_utils_test.gd`

**反例**（❌）：测试随意放置；或命名为 `test1.gd`、`MathTest.gd`（不符合镜像规则）。

### 6. 单元测试与集成测试分层

**说明**：纯逻辑/类 → 单元测试（`test/unit/`）；多模块协作/场景交互 → 集成测试（`test/integration/`）。

**正例**（✅）：FSM 状态切换逻辑 → `unit`；关卡加载 + 敌人生成 → `integration`。

**反例**（❌）：把依赖完整场景树的测试当单元测试，拖慢且脆弱。

### 7. 一个测试只验证一个行为

**说明**：单个测试聚焦一个行为；方法名出现「and」多半该拆分。

**正例**（✅）：`func test_take_damage_reduces_health() -> void:`

**反例**（❌）：`func test_damage_and_heal_and_death() -> void:`（一次测三件事，失败难定位）。

---

## 三、GdUnit4 写法

### 8. 测试套件继承 GdUnitTestSuite

**说明**：测试类 `extends GdUnitTestSuite`，`class_name` 用 `源名Test`（PascalCase）。

**正例**（✅）：
```gdscript
class_name MathUtilsTest
extends GdUnitTestSuite

func test_add() -> void:
    assert_int(MathUtils.add(2, 3)).is_equal(5)
```

**反例**（❌）：`extends Node`，手写 `if x != y: print("fail")` 断言逻辑。

### 9. 用流式断言（fluent assertions）

**说明**：用 GdUnit4 的 `assert_xxx` 链式断言，类型对应用对应断言（`assert_int`/`assert_str`/`assert_array`/`assert_object`）。

**正例**（✅）：
```gdscript
assert_str(msg).contains("ok").has_length(10)
assert_array(items).has_size(3).contains("sword")
```

**反例**（❌）：
```gdscript
if x != 5:
    print("失败")        # 无断言、无失败报告、CI 不识别
```

### 10. 测试方法以 test_ 开头并描述行为

**说明**：方法名 `test_` 前缀 + 行为描述（snake_case）；GdUnit4 据此发现并运行测试。

**正例**（✅）：`func test_empty_input_returns_zero() -> void:`

**反例**（❌）：`func test1() -> void:`、`func check_damage() -> void:`（无 `test_` 前缀，不被发现）。

### 11. auto_free 管理对象生命周期

**说明**：测试中 `new` 出的 Node/Resource 用 `auto_free()` 包裹，自动释放避免泄漏。

**正例**（✅）：
```gdscript
func test_timer() -> void:
    var timer := auto_free(Timer.new())
    add_child(timer)
```

**反例**（❌）：
```gdscript
var timer := Timer.new()   # 忘记 free/auto_free，测试间泄漏
add_child(timer)
```

---

## 四、测试质量

### 12. AAA 模式（准备-执行-断言）

**说明**：测试分三段：Arrange（准备）→ Act（执行）→ Assert（断言），结构清晰。

**正例**（✅）：
```gdscript
func test_take_damage() -> void:
    # Arrange
    var hp := Health.new()
    hp.current = 10
    # Act
    hp.take_damage(3)
    # Assert
    assert_int(hp.current).is_equal(7)
```

**反例**（❌）：准备/执行/断言交错混杂，难以一眼看出「测了什么」。

### 13. 测试隔离

**说明**：每个测试独立，不依赖其他测试的执行顺序或全局状态；自己准备初始状态。

**正例**（✅）：每个测试各自 `new` 对象、自行初始化。

**反例**（❌）：依赖 `test_a` 先跑设置了某全局变量，`test_b` 才能通过。

### 14. 测公开行为，不测内部实现

**说明**：测类的公开接口与可观察行为，不测私有方法/内部数据结构——实现重构时测试不应断。

**正例**（✅）：测 `take_damage(5)` 后 `current` 减少 5（公开行为）。

**反例**（❌）：断言内部 `_counter` 私有变量、或具体 Dictionary 存储结构（一重构就断）。

### 15. 覆盖边界与错误路径

**说明**：除正常路径外，**必须**覆盖边界（0/空/最大值）与错误路径（null/越界/负值）。

**正例**（✅）：
```gdscript
func test_zero_damage_keeps_health() -> void: pass
func test_overkill_clamps_to_zero() -> void: pass
func test_negative_amount_ignored() -> void: pass
```

**反例**（❌）：只测 happy path（正常输入），忽略边界与异常。

---

## 五、场景与信号测试

### 16. 用 scene_runner 测试场景

**说明**：场景交互测试用 `scene_runner` 加载场景、模拟输入/帧、断言场景状态；归 `integration`。

**正例**（✅）：
```gdscript
func test_player_takes_damage() -> void:
    var runner := scene_runner("res://scenes/actors/player/player.tscn")
    var player := runner.find_child("Player")
    player.take_damage(5)
    await runner.simulate_frames(2)
    assert_int(player.current_health).is_equal(95)
```

**反例**（❌）：单元测试里手动 `instantiate` + `add_child` 场景，重复造轮子且易泄漏。

### 17. 用 assert_signal 测信号

**说明**：信号触发用 `assert_signal(node).is_emitted("信号名")` 验证，不手动接线。

**正例**（✅）：
```gdscript
func test_died_signal_on_zero_health() -> void:
    var hp := auto_free(Health.new())
    hp.current = 1
    hp.take_damage(1)
    await assert_signal(hp).is_emitted("died")
```

**反例**（❌）：手动连信号到 flag 变量再 `if flag:` 判断，繁琐且不可靠。

---

## 六、测试纪律

### 18. 失败时改实现，不改测试

**说明**：测试失败时修**产品代码**使其通过，**不修测试**（除非测试本身写错）；重构期测试应保持不变。

**正例**（✅）：测试红 → 改 `take_damage` 实现 → 测试绿。

**反例**（❌）：测试失败就删断言、放宽预期值，让测试「凑合过」——掩盖了真实 bug。

---

## 附：测试自查清单 + 运行方式

**写测试提交前逐条核对：**

- [ ] 每个新方法/行为先有失败测试，且亲见失败
- [ ] 测试文件 `_test.gd`，路径镜像源码；单元/集成正确分层
- [ ] 一测一行为，方法名 `test_` + 行为描述
- [ ] 用 `assert_xxx` 流式断言；`new` 出对象用 `auto_free`
- [ ] AAA 结构清晰；测试互相隔离；测公开行为非内部实现
- [ ] 覆盖边界与错误路径；场景用 `scene_runner`，信号用 `assert_signal`
- [ ] 失败时改实现不改测试

**headless 运行（阶段 10 门禁 / CI）：**

```bash
# 设置 Godot 可执行路径（按实际安装）
# export GODOT_BIN=/path/to/godot

# 运行全部测试
./addons/gdUnit4/runtest.sh --godot_binary $GODOT_BIN

# 运行指定目录
./addons/gdUnit4/runtest.sh --godot_binary $GODOT_BIN -a res://test/unit/
```
