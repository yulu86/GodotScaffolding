---
name: godot-ui-design
description: Godot 4.x 界面设计 Skill，使用 Pencil 工具设计游戏 UI 界面。提供从需求分析到设计稿交付的完整工作流，涵盖界面原型设计、组件系统搭建、主题变量管理和设计验证。当需要为 Godot 游戏设计 UI 界面、创建界面设计稿、设计 HUD/菜单/对话框/设置面板等界面时触发此技能。
---

# Godot UI 界面设计器

使用 Pencil 工具为 Godot 4.x 游戏设计界面，输出标准化 .pen 设计稿。

## 适用场景

- 为游戏设计新的 UI 界面（HUD、主菜单、设置面板、背包、对话框等）
- 创建界面设计稿（.pen 文件）供后续开发参考
- 搭建可复用的 UI 组件库
- 管理全局设计变量和主题
- 截图验证界面设计效果

## 界面设计工作流

### 第 1 步：需求分析

在设计之前，明确以下内容：

1. **界面用途**：该界面在游戏中承担什么功能？
2. **目标平台**：PC / 移动端 / 主机？（影响分辨率和交互方式）
3. **参考分辨率**：推荐 1920×1080（16:9）或 2560×1440
4. **交互元素**：按钮、滑块、输入框、滚动列表等
5. **数据驱动区域**：哪些内容是动态的（血条、文字、图标）？
6. **导航关系**：该界面与其他界面的切换逻辑

输出一份简洁的界面需求清单，包含上述要点。

### 第 2 步：初始化设计环境

```
1. pencil_get_editor_state(include_schema=true)  → 获取编辑器状态和 .pen schema
2. 若无活跃文档 → pencil_open_document()  → 新建或打开已有 .pen 文件
3. pencil_get_guidelines(category="guide")  → 获取可用设计指南
4. pencil_get_guidelines(category="style")  → 获取可用视觉样式
```

**设计稿存放路径**：`docs/07_design/{序号}_{界面名}.pen`

### 第 3 步：搭建组件系统（可选）

若项目尚未建立组件库，先创建基础 UI 组件：

```
1. pencil_get_guidelines(category="guide", name="general")  → 获取 schema 定义
2. 设计基础组件：Button、Label、Panel、InputField、Slider、Toggle
3. 每个组件标记为 reusable: true
4. 使用 pencil_set_variables 定义全局设计 token
```

参见 [references/ui-component-patterns.md](references/ui-component-patterns.md) 获取 Godot UI 组件设计模式。

### 第 4 步：定义设计变量

使用 `pencil_set_variables` 建立全局设计 token：

```
1. 颜色系统：主色、辅色、背景色、文字色、成功/警告/错误色
2. 间距系统：基础单位（如 8px）、组件内边距、元素间距
3. 字体系统：标题字体、正文字体、字号层级
4. 圆角系统：小/中/大圆角值
5. 暗色/亮色主题变量
```

参见 [references/design-tokens.md](references/design-tokens.md) 获取推荐的 Godot 游戏设计 token。

### 第 5 步：界面原型设计

使用 `pencil_batch_design` 构建界面：

**布局原则**：
- 使用 `frame` + `layout` 属性组织布局（horizontal / vertical）
- 利用 `gap`、`padding`、`justifyContent`、`alignItems` 控制间距和对齐
- 动态内容区域设置 `placeholder: true`
- 固定尺寸元素使用具体数值，弹性元素使用 `fill_container`

**操作顺序**：

```
1. pencil_find_empty_space_on_canvas  → 找到画布空白区域
2. pencil_batch_design(operations)    → 创建主框架（Screen）
3. pencil_batch_design(operations)    → 填充导航栏/标题栏
4. pencil_batch_design(operations)    → 填充主内容区
5. pencil_batch_design(operations)    → 填充底部栏/操作按钮
6. pencil_batch_design(operations)    → 添加细节（图标、装饰、状态指示）
```

**批量操作规则**：
- 每次最多 25 个操作
- 按逻辑分批：先结构 → 再内容 → 最后细节
- 每次调用必须使用新的 binding name，禁止跨批次重用

### 第 6 步：截图验证与迭代

```
1. pencil_get_screenshot(nodeId=screenId)  → 截图验证整体效果
2. 检查以下要点：
   - 布局是否对齐、间距是否均匀
   - 文字是否可读、字号是否合理
   - 组件是否完整、没有溢出或裁切
   - 颜色对比度是否足够
3. 发现问题 → 用 pencil_batch_design 修复 → 重新截图验证
4. pencil_snapshot_layout(problemsOnly=true)  → 检查布局问题
```

### 第 7 步：导出设计稿

```
1. pencil_export_nodes(
     filePath="docs/07_design/{序号}_{界面名}.pen",
     nodeIds=[screenId],
     outputDir="docs/07_design/exports",
     format="png",
     scale=2
   )
2. 确认导出文件生成成功
```

### 第 8 步：生成设计文档

在 .pen 设计稿旁生成 Markdown 设计说明：

```
输出包含：
1. 界面概述（用途、目标平台、参考分辨率）
2. 组件清单（使用的组件及其属性）
3. 布局说明（层级结构、对齐方式、间距规则）
4. 交互说明（按钮点击、状态切换、动画效果）
5. 设计变量表（颜色、字号、间距等 token 值）
6. Godot 实现提示（推荐节点类型、容器选择、Theme 配置）
```

## Godot UI 节点映射

设计稿中的 Pencil 元素对应 Godot 中的节点：

| Pencil 元素 | Godot 节点 | 说明 |
|-------------|-----------|------|
| `frame` (horizontal) | `HBoxContainer` / `HBoxLayout` | 水平布局容器 |
| `frame` (vertical) | `VBoxContainer` / `VBoxLayout` | 垂直布局容器 |
| `frame` (placeholder) | `MarginContainer` / `PanelContainer` | 内容占位容器 |
| `text` | `Label` / `RichTextLabel` | 文字显示 |
| `rectangle` (clickable) | `Button` / `TextureButton` | 可点击按钮 |
| `rectangle` (fillable) | `LineEdit` / `TextEdit` | 文字输入框 |
| `icon_font` | `TextureRect` | 图标显示 |
| `frame` + slider | `HSlider` / `VSlider` | 滑块控件 |
| `frame` + toggle | `CheckBox` / `CheckButton` | 开关控件 |
| `frame` + scroll | `ScrollContainer` | 滚动区域 |
| `frame` + tab | `TabContainer` | 标签页 |

## Godot 常见界面设计模式

### HUD（抬头显示）

```
ScreenRoot (1920×1080)
├── TopBar (HBox, full_width)
│   ├── HealthBar (frame, horizontal)
│   │   ├── HealthIcon (icon)
│   │   └── HealthFill (rectangle, fill)
│   ├── Spacer (frame, expand)
│   └── ScoreDisplay (text, right_align)
├── CenterArea (frame, placeholder, expand)
└── BottomBar (HBox, full_width)
    ├── AbilitySlots (HBox)
    └── MiniMap (frame, fixed_size)
```

### 主菜单

```
ScreenRoot (1920×1080)
├── Background (frame, full_size)
├── TitleArea (frame, vertical, center)
│   ├── GameTitle (text, large)
│   └── Subtitle (text, small)
├── MenuButtons (frame, vertical, center)
│   ├── NewGameButton (ref:Button)
│   ├── ContinueButton (ref:Button)
│   ├── SettingsButton (ref:Button)
│   └── QuitButton (ref:Button)
└── VersionText (text, bottom_right, small)
```

### 设置面板

```
ScreenRoot (1920×1080)
├── Overlay (rectangle, semi_transparent)
└── SettingsPanel (frame, vertical, centered)
    ├── PanelTitle (text, "Settings")
    ├── TabBar (HBox)
    │   ├── AudioTab (ref:TabButton)
    │   ├── VideoTab (ref:TabButton)
    │   └── ControlsTab (ref:TabButton)
    ├── ContentArea (frame, placeholder, scroll)
    └── ButtonBar (HBox, right)
        ├── ApplyButton (ref:Button)
        └── CancelButton (ref:Button)
```

### 背包/物品栏

```
ScreenRoot (1920×1080)
├── Overlay (rectangle, semi_transparent)
└── InventoryPanel (frame, horizontal)
    ├── ItemGrid (frame, grid, 6×4)
    │   └── ItemSlot × 24 (ref:Slot)
    └── DetailPanel (frame, vertical)
        ├── ItemIcon (frame, large)
        ├── ItemName (text)
        ├── ItemDescription (text, multiline)
        └── ActionButtons (HBox)
```

### 对话框/弹窗

```
ScreenRoot (1920×1080)
├── Overlay (rectangle, semi_transparent)
└── DialogBox (frame, vertical, centered)
    ├── DialogTitle (text)
    ├── DialogContent (frame, placeholder)
    └── DialogButtons (HBox, right)
        ├── ConfirmButton (ref:Button, primary)
        └── CancelButton (ref:Button, secondary)
```

## 与其他 Skill 的协作

| 下游 Skill | 协作方式 |
|-----------|---------|
| `godot-scene` | 读取设计稿 → 创建对应 .tscn 场景，按映射表选择节点类型 |
| `godot-developer` | 根据设计文档编写 UI 脚本逻辑 |
| `godot-debug` | 截图对比设计稿与实际运行效果 |

### 设计稿 → 场景的交付物

设计完成时，需确保以下信息可被 `godot-scene` 读取：

1. **布局层级**：每个 frame 的 layout、gap、padding、justifyContent、alignItems
2. **组件实例**：ref 引用的组件名及其覆写属性
3. **设计变量**：颜色、字号、间距等 token 值
4. **交互标注**：哪些元素可点击、可输入、可滚动

## 参考资料（按需加载）

- **UI 组件模式**：[references/ui-component-patterns.md](references/ui-component-patterns.md) — Pencil 中可复用 UI 组件的设计模式
- **设计 Token**：[references/design-tokens.md](references/design-tokens.md) — 推荐的 Godot 游戏设计变量系统
- **Godot UI 布局指南**：[references/godot-ui-layout.md](references/godot-ui-layout.md) — Godot Container 节点与 Pencil 布局的映射关系

## 约束

- **必须**使用 Pencil 工具设计界面，禁止跳过设计直接开发
- **必须**将设计稿存放在 `docs/07_design/` 目录
- **必须**使用 `pencil_get_screenshot` 截图验证设计效果
- **必须**使用 `pencil_set_variables` 管理全局设计 token，禁止硬编码颜色/字号
- **禁止**在单次 `pencil_batch_design` 调用中超过 25 个操作
- **禁止**跨 `pencil_batch_design` 调用重用 binding name
- **禁止**手动定位 UI 元素（x/y 坐标），必须使用 layout + gap + padding
- UI 界面设计稿**必须**经截图验证通过后，方可交付给 `godot-scene` 开发
