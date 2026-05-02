# Godot UI 布局映射指南

Pencil 设计稿中的布局属性与 Godot Container 节点的对应关系。

## 容器映射

| Pencil 属性 | Godot 节点 | 说明 |
|-------------|-----------|------|
| `layout: "horizontal"` | `HBoxContainer` | 水平排列子节点 |
| `layout: "vertical"` | `VBoxContainer` | 垂直排列子节点 |
| `layout: "horizontal"` + wrap | `HFlowContainer` | 水平自动换行 |
| `layout: "vertical"` + wrap | `VFlowContainer` | 垂直自动换行 |
| `layout: "grid"` | `GridContainer` | 网格排列（需设置 columns） |
| 无 layout + 定位子节点 | `Control` (手动定位) | 仅限装饰层，UI 禁用 |
| `placeholder: true` | `MarginContainer` | 提供内边距的占位容器 |
| overlay/stacking | `CanvasLayer` | 层级叠加（HUD、弹窗） |

## 布局属性映射

### 间距

| Pencil 属性 | Godot 属性 | 说明 |
|-------------|-----------|------|
| `gap: 16` | `Container.add_theme_constant_override("separation", 16)` | 子元素间距 |
| `padding: [T, R, B, L]` | `MarginContainer` 的 `margin_*` 属性 | 容器内边距 |

### 对齐

| Pencil 属性 | Godot 属性 | 说明 |
|-------------|-----------|------|
| `justifyContent: "center"` | `container.alignment = BoxContainer.ALIGNMENT_CENTER` | 主轴居中 |
| `justifyContent: "start"` | `container.alignment = BoxContainer.ALIGNMENT_BEGIN` | 主轴起始 |
| `justifyContent: "end"` | `container.alignment = BoxContainer.ALIGNMENT_END` | 主轴末尾 |
| `alignItems: "center"` | 子节点的 `size_flags_vertical = SIZE_SHRINK_CENTER` | 交叉轴居中 |

### 尺寸

| Pencil 属性 | Godot 属性 | 说明 |
|-------------|-----------|------|
| `width: "fill_container"` | `size_flags_horizontal = SIZE_EXPAND_FILL` | 水平填满 |
| `height: "fill_container"` | `size_flags_vertical = SIZE_EXPAND_FILL` | 垂直填满 |
| `width: 200` | `custom_minimum_size.x = 200` | 固定宽度 |
| `height: 48` | `custom_minimum_size.y = 48` | 固定高度 |

## 常见布局模式

### 居中弹窗

**Pencil**：
```javascript
overlay = I(document, {type: "frame", layout: "horizontal", justifyContent: "center", alignItems: "center", fill: "#00000080", width: 1920, height: 1080})
panel = I(overlay, {type: "frame", layout: "vertical", padding: [24, 24, 24, 24], gap: 16, fill: "$surface", cornerRadius: [16, 16, 16, 16], width: 400})
```

**Godot**：
```gdscript
# ColorRect (overlay)
var overlay = ColorRect.new()
overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
overlay.color = Color(0, 0, 0, 0.5)

# CenterContainer
var center = CenterContainer.new()
center.set_anchors_preset(Control.PRESET_FULL_RECT)

# Panel
var panel = PanelContainer.new()
panel.custom_minimum_size = Vector2(400, 0)
```

### 底部操作栏

**Pencil**：
```javascript
bar = I("parentId", {type: "frame", layout: "horizontal", justifyContent: "end", padding: [16, 16, 16, 16], gap: 12, width: "fill_container"})
```

**Godot**：
```gdscript
var bar = HBoxContainer.new()
bar.alignment = BoxContainer.ALIGNMENT_END
bar.add_theme_constant_override("separation", 12)
# 设置 margin
```

### 左右分栏

**Pencil**：
```javascript
split = I("parentId", {type: "frame", layout: "horizontal", gap: 0, width: "fill_container", height: "fill_container"})
left = I(split, {type: "frame", layout: "vertical", width: 240, height: "fill_container", fill: "$surface"})
right = I(split, {type: "frame", layout: "vertical", width: "fill_container", height: "fill_container"})
```

**Godot**：
```gdscript
var split = HSplitContainer.new()
var left = VBoxContainer.new()
left.custom_minimum_size.x = 240
var right = VBoxContainer.new()
right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
```

## Theme 资源映射

设计稿中的全局变量对应 Godot Theme 资源：

| 设计 Token | Theme 属性 | 说明 |
|-----------|-----------|------|
| `$primary` | `theme.set_color("primary_color", "Control", color)` | 主题色 |
| `$text_primary` | `theme.set_font_color("font_color", "Label", color)` | 默认文字色 |
| `$text-h1` | `theme.set_font_size("font_size", "Label", 32)` | 标题字号 |
| `$radius-md` | `theme.set_constant("border_radius", "Panel", 8)` | 面板圆角 |
| `$spacing-md` | `theme.set_constant("separation", "BoxContainer", 16)` | 容器间距 |

## 响应式注意事项

Godot 的 Anchor 系统与 Pencil 的固定像素不同：

1. **Pencil 设计稿**：基于固定分辨率（如 1920×1080）
2. **Godot 场景**：使用 `anchor` + `margin` / `offset` 实现自适应

**转换规则**：
- `width: 1920, height: 1080` → 根节点设为 `FULL_RECT`
- `width: "fill_container"` → `size_flags_horizontal = SIZE_EXPAND_FILL`
- 居中元素 → `CenterContainer` 或 `anchor = 0.5`
- 固定尺寸 → `custom_minimum_size`
