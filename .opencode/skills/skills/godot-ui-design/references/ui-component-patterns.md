# UI 组件设计模式

在 Pencil 中为 Godot 游戏创建可复用的 UI 组件。

## 基础组件

### Button（按钮）

```javascript
// 创建可复用按钮组件
button = I("parentId", {
  type: "frame",
  name: "Button",
  reusable: true,
  layout: "horizontal",
  justifyContent: "center",
  alignItems: "center",
  padding: [12, 24, 12, 24],
  gap: 8,
  cornerRadius: [8, 8, 8, 8],
  fill: "$primary",
  width: "fill_container",
  height: 48
})
I(button, {type: "icon_font", iconFontFamily: "Material Icons", iconFontName: "play_arrow", fill: "$on_primary"})
I(button, {type: "text", name: "Label", content: "Button", fill: "$on_primary", fontSize: 16, fontWeight: "Medium"})
```

**变体属性**：
- `primary`：fill=$primary, text=$on_primary
- `secondary`：fill=$secondary, text=$on_secondary
- `ghost`：fill=transparent, stroke=$primary, text=$primary
- `danger`：fill=$error, text=$on_error

### Label（标签）

```javascript
label = I("parentId", {
  type: "frame",
  name: "Label",
  reusable: true,
  layout: "horizontal",
  alignItems: "center",
  gap: 4
})
I(label, {type: "icon_font", name: "Icon", iconFontFamily: "Material Icons", iconFontName: "info", fill: "$text_secondary"})
I(label, {type: "text", name: "Text", content: "Label", fill: "$text_primary", fontSize: 14})
```

### Panel（面板）

```javascript
panel = I("parentId", {
  type: "frame",
  name: "Panel",
  reusable: true,
  layout: "vertical",
  padding: [16, 16, 16, 16],
  gap: 12,
  cornerRadius: [12, 12, 12, 12],
  fill: "$surface",
  stroke: "$outline",
  strokeThickness: 1
})
I(panel, {type: "text", name: "Title", content: "Panel Title", fill: "$text_primary", fontSize: 18, fontWeight: "Bold"})
I(panel, {type: "frame", name: "Content", placeholder: true, layout: "vertical", gap: 8})
```

### InputField（输入框）

```javascript
input = I("parentId", {
  type: "frame",
  name: "InputField",
  reusable: true,
  layout: "vertical",
  gap: 4
})
I(input, {type: "text", name: "Hint", content: "Placeholder", fill: "$text_hint", fontSize: 14})
I(input, {
  type: "rectangle",
  name: "Border",
  cornerRadius: [6, 6, 6, 6],
  stroke: "$outline",
  strokeThickness: 1,
  fill: "$background",
  width: "fill_container",
  height: 44
})
```

### Slider（滑块）

```javascript
slider = I("parentId", {
  type: "frame",
  name: "Slider",
  reusable: true,
  layout: "vertical",
  gap: 8,
  width: "fill_container"
})
I(slider, {
  type: "frame",
  name: "Track",
  layout: "horizontal",
  alignItems: "center",
  height: 8,
  cornerRadius: [4, 4, 4, 4],
  fill: "$surface_variant",
  width: "fill_container"
})
// Fill indicator
I(slider, {
  type: "text",
  name: "Value",
  content: "50%",
  fill: "$text_secondary",
  fontSize: 12,
  textAlign: "right"
})
```

### Slot（物品槽位）

```javascript
slot = I("parentId", {
  type: "frame",
  name: "Slot",
  reusable: true,
  layout: "horizontal",
  justifyContent: "center",
  alignItems: "center",
  width: 64,
  height: 64,
  cornerRadius: [8, 8, 8, 8],
  stroke: "$outline",
  strokeThickness: 1,
  fill: "$surface_variant"
})
I(slot, {type: "frame", name: "Icon", placeholder: true, width: 48, height: 48})
```

## 复合组件

### HealthBar（血条）

```javascript
healthbar = I("parentId", {
  type: "frame",
  name: "HealthBar",
  reusable: true,
  layout: "horizontal",
  alignItems: "center",
  gap: 8
})
I(healthbar, {type: "icon_font", name: "Icon", iconFontFamily: "Material Icons", iconFontName: "favorite", fill: "$error"})
I(healthbar, {
  type: "frame",
  name: "Track",
  layout: "horizontal",
  height: 12,
  cornerRadius: [6, 6, 6, 6],
  fill: "$surface_variant",
  width: "fill_container"
})
I(healthbar, {type: "text", name: "Value", content: "100/100", fill: "$text_primary", fontSize: 14})
```

### Tooltip（提示框）

```javascript
tooltip = I("parentId", {
  type: "frame",
  name: "Tooltip",
  reusable: true,
  layout: "vertical",
  padding: [8, 12, 8, 12],
  gap: 4,
  cornerRadius: [6, 6, 6, 6],
  fill: "$inverse_surface"
})
I(tooltip, {type: "text", name: "Title", content: "Item Name", fill: "$inverse_on_surface", fontSize: 14, fontWeight: "Bold"})
I(tooltip, {type: "text", name: "Description", content: "Description text", fill: "$inverse_on_surface", fontSize: 12})
```

### ModalDialog（模态对话框）

```javascript
dialog = I("parentId", {
  type: "frame",
  name: "ModalDialog",
  reusable: true,
  layout: "vertical",
  padding: [24, 24, 24, 24],
  gap: 16,
  cornerRadius: [16, 16, 16, 16],
  fill: "$surface",
  width: 400
})
I(dialog, {type: "text", name: "Title", content: "Dialog Title", fill: "$text_primary", fontSize: 20, fontWeight: "Bold"})
I(dialog, {type: "frame", name: "Content", placeholder: true, layout: "vertical", gap: 8})
I(dialog, {
  type: "frame",
  name: "Actions",
  layout: "horizontal",
  justifyContent: "right",
  gap: 12
})
```

## 组件命名规范

| 类型 | 命名模式 | 示例 |
|------|---------|------|
| 基础组件 | PascalCase | Button, Label, Panel |
| 复合组件 | PascalCase 描述 | HealthBar, MiniMap, ItemSlot |
| 组件内部节点 | PascalCase 描述 | Track, Label, Icon, Border |
| 设计稿 Screen | PascalCase 界面名 | MainMenuScreen, SettingsScreen |
