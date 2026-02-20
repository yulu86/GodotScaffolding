# Godot状态机实现指南（宪法级文档）

## 概述

本文档是Godot Copilot技能的宪法级文档，定义了Godot中状态机实现的完整范式和最佳实践。所有状态机相关开发**必须严格遵循**本文档的架构模式和实现规范。

## 核心设计原则

### 1. 单一职责原则
- 每个状态只负责一个特定的行为模式
- 状态类专注于处理该状态下的逻辑、输入和转换
- 状态间通过明确的接口进行通信

### 2. 开闭原则
- 对扩展开放：新状态可以轻松添加而不影响现有代码
- 对修改关闭：现有状态的行为不需要因为添加新状态而改变

### 3. 依赖倒置原则
- 状态机依赖于抽象的状态接口，而非具体的状态实现
- 通过工厂模式实现状态创建的解耦

### 4. 信号驱动架构
- 使用信号系统实现状态转换请求
- 状态转换必须通过信号触发，禁止直接调用
- 确保线程安全和解耦设计

## 状态机架构模式

### 核心组件架构

```
状态机核心架构
├── State (状态基类)
│   ├── enter() - 状态进入
│   ├── exit() - 状态退出
│   ├── process(delta) - 每帧更新
│   ├── physics_process(delta) - 物理更新
│   └── can_transition_to(state_type) - 转换条件检查
├── StateData (状态数据类)
│   ├── 建造者模式支持
│   ├── 数据验证机制
│   └── 轻量化设计
├── StateFactory (状态工厂)
│   ├── 状态类型注册
│   ├── 状态实例创建
│   └── 类型安全检查
└── StateMachine (状态机管理器)
    ├── 状态转换逻辑
    ├── 生命周期管理
    ├── 调试和日志
    └── 错误处理
```

### 状态转换流程

```
状态转换时序图
1. 当前状态发出转换请求信号
   state_transition_requested.emit(to_state, state_data)

2. 状态机管理器接收信号
   on_state_transition_requested(to_state, state_data)

3. 验证转换条件
   if current_state.can_transition_to(to_state):
       执行转换
   else:
       记录错误，转换失败

4. 清理旧状态
   current_state.queue_free()
   断开信号连接

5. 创建新状态
   new_state = state_factory.get_fresh_state(to_state)

6. 初始化新状态
   new_state.setup(state_machine, state_data)
   new_state.state_transition_requested.connect(switch_state.bind())

7. 延迟添加到场景树
   call_deferred("add_child", new_state)
```

## 实现规范（宪法级）

### 1. 状态基类实现

```gdscript
# State.gd - 所有状态的基类（模板代码）
class_name State
extends Node

# 状态转换信号（必须使用）
signal state_transition_requested(to_state: Enum, state_data: StateData)

# 调试模式
var debug_mode: bool = false

# 状态机引用
var state_machine: Node = null
var state_data: StateData = null
var context: Dictionary = {}

func setup(context_machine: Node, context_data: StateData, extra_context: Dictionary = {}) -> void:
    """状态初始化设置（必须实现）"""
    debug_mode = context_machine.debug_mode if "debug_mode" in context_machine else false
    state_machine = context_machine
    state_data = context_data
    context = extra_context

func transition_state(to_state: Enum, new_state_data: StateData = StateData.new()) -> void:
    """请求状态转换（必须使用信号）"""
    state_transition_requested.emit(to_state, new_state_data)

func enter() -> void:
    """状态进入时调用（子类必须重写）"""
    if debug_mode:
        print("[%s] Enter state: %s" % [Engine.get_physics_frames(), name])

func exit() -> void:
    """状态退出时调用（子类必须重写）"""
    if debug_mode:
        print("[%s] Exit state: %s" % [Engine.get_physics_frames(), name])

func process(delta: float) -> void:
    """每帧更新处理（子类可重写）"""
    pass

func physics_process(delta: float) -> void:
    """物理帧更新处理（子类可重写）"""
    pass

func input(event: InputEvent) -> void:
    """输入事件处理（子类可重写）"""
    pass

func can_transition_to(state_type: Enum) -> bool:
    """检查是否可以转换到指定状态（子类必须重写）"""
    return true

# Node生命周期方法
func _enter_tree() -> void:
    """Node进入场景树时调用"""
    enter()

func _exit_tree() -> void:
    """Node退出场景树时调用"""
    exit()
```

### 2. 状态数据类实现

```gdscript
# StateData.gd - 状态数据基类（模板代码）
class_name StateData
extends RefCounted

# 建造者模式支持（必须实现）
static func build() -> StateData:
    return StateData.new()

# 默认构造函数
func _init() -> void:
    pass

# 数据验证（必须实现）
func validate() -> bool:
    return true

# 数据重置（可选实现）
func reset() -> void:
    pass

# 数据复制（可选实现）
func duplicate() -> StateData:
    var new_data = StateData.new()
    return new_data
```

### 3. 状态工厂实现

```gdscript
# StateFactory.gd - 状态工厂基类（模板代码）
class_name StateFactory
extends RefCounted

# 状态注册表（必须实现）
var states: Dictionary = {}
var default_state: Enum = null

# 构造函数
func _init():
    register_states()

# 注册状态类（子类必须重写）
func register_states() -> void:
    """子类需要重写此方法来注册具体状态"""
    pass

# 注册单个状态
func register_state(state_type: Enum, state_class: GDScript) -> void:
    states[state_type] = state_class
    if default_state == null:
        default_state = state_type

# 获取状态实例（必须实现）
func get_fresh_state(state_type: Enum) -> State:
    if not states.has(state_type):
        push_error("State type not registered: " + str(state_type))
        return get_default_state()
    
    var state_class = states.get(state_type)
    return state_class.new()

# 获取默认状态
func get_default_state() -> State:
    if default_state == null:
        push_error("No default state set")
        return null
    return get_fresh_state(default_state)
```

### 4. 状态机管理器实现

```gdscript
# StateMachine.gd - 状态机管理器基类（模板代码）
class_name StateMachine
extends Node

# 状态机配置
@export var debug_mode: bool = false
@export var auto_start: bool = true
@export var initial_state: Enum = null

# 当前状态
var current_state: State = null
var state_factory: StateFactory = null

# 状态转换历史
var state_history: Array[String] = []
var max_history_size: int = 50

# 信号
signal state_changed(from_state: String, to_state: String)
signal state_transition_failed(from_state: String, to_state: String, reason: String)

func _ready() -> void:
    setup_factory()
    if auto_start and initial_state != null:
        switch_state(initial_state)

func setup_factory() -> void:
    """设置状态工厂（子类必须重写）"""
    state_factory = StateFactory.new()

# 状态转换（核心方法，必须遵循规范）
func switch_state(to_state: Enum, state_data: StateData = StateData.new()) -> bool:
    """状态转换（严格遵循转换流程）"""
    var from_state_name = "Empty"
    
    # 验证状态数据
    if not state_data.validate():
        emit_signal("state_transition_failed", from_state_name, str(to_state), "Invalid state data")
        return false
    
    # 检查转换条件
    if current_state != null and not current_state.can_transition_to(to_state):
        emit_signal("state_transition_failed", current_state.name, str(to_state), "Transition not allowed")
        return false
    
    # 记录状态历史
    if current_state != null:
        from_state_name = current_state.name
        add_to_history(from_state_name)
        
        # 清理旧状态（必须立即清理）
        current_state.queue_free()
    
    # 创建新状态
    current_state = state_factory.get_fresh_state(to_state)
    if current_state == null:
        emit_signal("state_transition_failed", from_state_name, str(to_state), "Failed to create state")
        return false
    
    # 设置新状态
    current_state.setup(self, state_data)
    current_state.state_transition_requested.connect(switch_state.bind())
    current_state.name = get_state_name(to_state)
    
    # 延迟添加到场景树（必须使用call_deferred）
    call_deferred("add_child", current_state)
    
    # 发出状态改变信号
    var to_state_name = current_state.name
    emit_signal("state_changed", from_state_name, to_state_name)
    
    # 调试日志
    print_state_changed(from_state_name, to_state_name)
    
    return true

# 辅助方法
func get_state_name(state_type: Enum) -> String:
    """获取状态名称"""
    return str(state_type)

func add_to_history(state_name: String) -> void:
    """添加状态到历史记录"""
    state_history.append(state_name)
    if state_history.size() > max_history_size:
        state_history.pop_front()

func print_state_changed(from_state: String, to_state: String) -> void:
    """打印状态转换日志"""
    if debug_mode:
        print("[%s] StateMachine %s: %s => %s" % [
            Engine.get_physics_frames(),
            name,
            from_state,
            to_state
        ])
```

## 状态机最佳实践

### 1. 性能优化

#### 即时清理机制
```gdscript
# ✅ 正确的做法：立即清理旧状态
if current_state != null:
    current_state.queue_free()  # 立即标记为删除
    # 断开信号连接，避免内存泄漏
    if current_state.state_transition_requested.is_connected(switch_state):
        current_state.state_transition_requested.disconnect(switch_state)
```

#### 延迟添加机制
```gdscript
# ✅ 正确的做法：使用call_deferred避免在_update中添加子节点
call_deferred("add_child", current_state)
```

### 2. 错误处理

#### 状态转换失败处理
```gdscript
# 实现完善的错误处理机制
func switch_state(to_state: Enum, state_data: StateData = StateData.new()) -> bool:
    # 验证状态数据
    if not state_data.validate():
        handle_transition_failure("Invalid state data", to_state)
        return False
    
    # 检查转换条件
    if current_state and not current_state.can_transition_to(to_state):
        handle_transition_failure("Transition not allowed", to_state)
        return False
    
    # 执行转换...
    return True

func handle_transition_failure(reason: String, to_state: Enum) -> void:
    """处理状态转换失败"""
    push_error("State transition failed: " + reason)
    emit_signal("state_transition_failed", current_state.name, str(to_state), reason)
```

### 3. 调试支持

#### 状态转换日志
```gdscript
func print_state_changed(from_state: String, to_state: String) -> void:
    """打印状态转换日志（必须实现）"""
    if debug_mode:
        print("[%s] StateMachine %s: %s => %s" % [
            Engine.get_physics_frames(),
            name,
            from_state,
            to_state
        ])
```

#### 状态历史记录
```gdscript
# 记录状态转换历史，便于调试
var state_history: Array[String] = []
var max_history_size: int = 50

func add_to_history(state_name: String) -> void:
    state_history.append(state_name)
    if state_history.size() > max_history_size:
        state_history.pop_front()

func get_state_history() -> Array[String]:
    return state_history.duplicate()
```

## 状态机开发流程

### 1. 设计阶段
- 明确状态机的使用场景和需求
- 定义状态枚举和转换关系
- 设计状态数据结构

### 2. 实现阶段
- 创建状态枚举类型
- 实现状态数据类（继承StateData）
- 实现具体状态类（继承State）
- 创建状态工厂（继承StateFactory）
- 实现状态机管理器（继承StateMachine）

### 3. 集成阶段
- 在场景中添加StateMachine节点
- 配置初始状态和调试模式
- 连接外部信号和事件
- 测试状态转换逻辑

### 4. 测试阶段
- 验证所有状态转换路径
- 测试错误处理机制
- 检查内存泄漏和性能
- 验证调试功能

## 常见错误和解决方案

### 1. 状态转换死循环
**问题**：状态之间无限循环转换
**解决方案**：
- 实现转换冷却机制
- 添加状态转换条件检查
- 使用状态转换历史检测循环

### 2. 内存泄漏
**问题**：状态对象没有正确清理
**解决方案**：
- 使用queue_free()立即清理旧状态
- 断开所有信号连接
- 避免循环引用

### 3. 并发状态修改
**问题**：多个地方同时修改状态
**解决方案**：
- 使用状态转换队列
- 实现线程安全的状态切换
- 避免在状态更新过程中直接切换状态

## 扩展指南

### 1. 状态插件系统
- 支持动态状态加载
- 实现状态插件接口
- 支持状态的热重载

### 2. 状态组合模式
- 实现状态装饰器
- 支持状态的并行处理
- 实现状态机嵌套

### 3. 可视化调试
- 状态机图形化显示
- 状态转换时间线
- 性能监控面板

---

**重要提醒**：本文档是宪法级文档，所有状态机实现必须严格遵循。任何对本文档的修改都需要经过严格的审核和测试。