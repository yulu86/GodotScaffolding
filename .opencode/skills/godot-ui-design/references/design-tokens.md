# 设计 Token 系统

为 Godot 游戏界面定义统一的设计变量。

## 推荐颜色系统

### 暗色主题（游戏默认）

```json
{
  "primary": { "type": "color", "value": "#BB86FC" },
  "on_primary": { "type": "color", "value": "#381E72" },
  "secondary": { "type": "color", "value": "#03DAC6" },
  "on_secondary": { "type": "color", "value": "#003830" },
  "background": { "type": "color", "value": "#1A1A2E" },
  "on_background": { "type": "color", "value": "#E6E1E5" },
  "surface": { "type": "color", "value": "#2D2D44" },
  "on_surface": { "type": "color", "value": "#E6E1E5" },
  "surface_variant": { "type": "color", "value": "#3A3A52" },
  "outline": { "type": "color", "value": "#49454F" },
  "error": { "type": "color", "value": "#F2B8B5" },
  "on_error": { "type": "color", "value": "#601410" },
  "success": { "type": "color", "value": "#81C784" },
  "warning": { "type": "color", "value": "#FFD54F" },
  "text_primary": { "type": "color", "value": "#E6E1E5" },
  "text_secondary": { "type": "color", "value": "#CAC4D0" },
  "text_hint": { "type": "color", "value": "#78757A" }
}
```

### 亮色主题（可选）

```json
{
  "primary": { "type": "color", "value": "#6750A4" },
  "on_primary": { "type": "color", "value": "#FFFFFF" },
  "background": { "type": "color", "value": "#FFFBFE" },
  "surface": { "type": "color", "value": "#FFFBFE" }
}
```

## 间距系统

基于 8px 网格：

```json
{
  "spacing-xs": { "type": "number", "value": 4 },
  "spacing-sm": { "type": "number", "value": 8 },
  "spacing-md": { "type": "number", "value": 16 },
  "spacing-lg": { "type": "number", "value": 24 },
  "spacing-xl": { "type": "number", "value": 32 },
  "spacing-2xl": { "type": "number", "value": 48 }
}
```

**使用场景**：
- `spacing-xs`：图标与文字间距、紧凑元素内边距
- `spacing-sm`：同类元素间距
- `spacing-md`：组件内边距、列表项间距
- `spacing-lg`：区块间距、面板内边距
- `spacing-xl`：主要区域分隔
- `spacing-2xl`：屏幕级分隔

## 字体系统

```json
{
  "font-display": { "type": "string", "value": "Noto Sans SC" },
  "font-body": { "type": "string", "value": "Noto Sans SC" },
  "font-mono": { "type": "string", "value": "JetBrains Mono" },
  "text-h1": { "type": "number", "value": 32 },
  "text-h2": { "type": "number", "value": 24 },
  "text-h3": { "type": "number", "value": 20 },
  "text-body": { "type": "number", "value": 16 },
  "text-caption": { "type": "number", "value": 12 },
  "text-button": { "type": "number", "value": 16 },
  "text-weight-normal": { "type": "string", "value": "Regular" },
  "text-weight-bold": { "type": "string", "value": "Bold" }
}
```

## 圆角系统

```json
{
  "radius-sm": { "type": "number", "value": 4 },
  "radius-md": { "type": "number", "value": 8 },
  "radius-lg": { "type": "number", "value": 12 },
  "radius-xl": { "type": "number", "value": 16 },
  "radius-full": { "type": "number", "value": 999 }
}
```

**使用场景**：
- `radius-sm`：输入框、小图标
- `radius-md`：按钮、标签、小卡片
- `radius-lg`：面板、卡片
- `radius-xl`：弹窗、大面板
- `radius-full`：圆形头像、圆形按钮

## 尺寸系统

```json
{
  "height-button": { "type": "number", "value": 48 },
  "height-input": { "type": "number", "value": 44 },
  "height-header": { "type": "number", "value": 64 },
  "height-footer": { "type": "number", "value": 56 },
  "height-tab": { "type": "number", "value": 48 },
  "icon-sm": { "type": "number", "value": 16 },
  "icon-md": { "type": "number", "value": 24 },
  "icon-lg": { "type": "number", "value": 32 }
}
```

## 完整 Token 设置示例

使用 `pencil_set_variables` 一次性设置所有 token：

```javascript
pencil_set_variables({
  filePath: "docs/07_design/01_main_menu.pen",
  variables: {
    "primary": { type: "color", value: "#BB86FC" },
    "on_primary": { type: "color", value: "#381E72" },
    "background": { type: "color", value: "#1A1A2E" },
    "surface": { type: "color", value: "#2D2D44" },
    "spacing-md": { type: "number", value: 16 },
    "text-h1": { type: "number", value: 32 },
    // ... 更多 token
  }
})
```
