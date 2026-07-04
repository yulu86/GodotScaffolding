---
name: draw-aseprite
description: >
  使用 Aseprite MCP 工具集绘制游戏资产精灵图（pixel art sprites），覆盖静态精灵
  （角色/物品/场景元素）与动画精灵（角色动作/特效）的端到端创作流程。
  当用户要求绘制精灵图、画像素画、制作游戏资产、画角色/物品/道具、绘制 sprite、
  pixel art、像素动画、aseprite 绘制、精灵图创作时使用此技能。
  触发词：绘制精灵图、画像素画、画 sprite、pixel art、像素动画、aseprite、
  游戏资产、角色立绘、物品图标、动画精灵、精灵表。
---

# Draw Aseprite

通过 `aseprite` MCP 工具集（104 个工具）绘制像素艺术精灵图。核心是**六步工作流 + 可视化反馈循环**：AI 画完后无法直接"看见"渲染结果，必须靠 `export_frame` 放大预览 + `get_color_stats`/`render_onion_skin` 自检来迭代收敛。

## 0. 前置约定（项目强制）

**产物路径**（遵从项目 AGENTS.md §2.4，违反即阻断）：

| 类型 | 路径 | 说明 |
|------|------|------|
| `.aseprite` 工程源文件 | `aseprite-assets/source/` | `create_canvas`/`copy_sprite` 的 `filename` |
| 导出 PNG/GIF/精灵表 | `aseprite-assets/export/` | `export_*` 的 `output_filename` |
| **临时预览图**（仅 AI/用户视觉反馈，scale 8-10） | `tmp/` | 任务结束**必删**，禁止落入 `aseprite-assets/` |

> 游戏场景引用导出的 PNG/GIF 时直接 `load("res://aseprite-assets/...")`，无需复制到 `assets/sprites/`。

**确认画布尺寸**：角色常用 16/24/32/64 平方；物品图标 16/32；UI 元素按需。开始前与用户确认尺寸与风格（复古限制色 vs 自由色）。

## 1. 六步工作流

> 源自 aseprite-mcp 官方《Recommended Workflow for LLMs》，已融入项目约定与像素艺术技法。

### Step 1 — 规划调色板（先色后形）

调色板是像素艺术的灵魂。**画第一笔前必须先定色板**。

- **复古风**：`apply_palette_preset`（`pico8`/`gameboy`/`dawnbringer16`/`dawnbringer32` 等）→ 全局限制色。
- **写实/多材质**：为**每种材质**调一条渐变（`generate_color_ramp`，带 hue shifting）：
  - 角色：皮肤 / 头发 / 衣服 / 金属 / 皮甲 各一条
  - 物品：主体材质 / 高光 / 阴影
- 用 `set_palette` 写入色板。**色数控制**：16×16 精灵建议 ≤ 16 色，32×32 建议 ≤ 32 色。
- 详见 [references/pixel-art-techniques.md](references/pixel-art-techniques.md) 的「调色板设计」。

### Step 2 — 分层构建（独立可编辑）

**始终分层绘制**，让各部件可独立动画/修改。推荐分层（自下而上）：

```
Background（背景/底色）
  └─ Body（身体剪影/肤色）
      └─ Clothing（衣服）
          └─ Equipment（武器/盔甲/道具）
              └─ Details（细节纹样）
                  └─ Effects（发光/特效，叠加层）
                      └─ Outline（轮廓，可选独立层）
```

用 `add_layer`/`add_group` 建层。每个材质对应一个层，方便后续 `adjust_hsl` 整体调色。

### Step 3 — 由粗到细（剪影先行）

**先画对的大形状，再画细节。** 不要一上来逐像素。

1. **剪影/底色**：`fill_area_at` 填主色块 → `draw_ellipse_at`（头/关节）/`draw_rectangle_at`（躯干/四肢）搭出剪影。
2. **修轮廓**：用 `draw_pixels_at` 逐像素修出干净的像素轮廓（避免锯齿，详见技法文档「轮廓法则」）。
3. **加内部细节**：`draw_pixels_at` 点出五官、纹路、高光。

> 优先用 `_at` 变体工具（指定 layer + frame，自动建 cel），坐标均为 sprite 全局坐标。

### Step 4 — 可视化反馈循环（画-看-修，反复迭代）

**AI 看不到渲染结果，这是唯一可靠的自检手段，禁止跳过。**

```
画一批 → export_frame(8×) 到 tmp/ → 读图自检 → 修正 → 再 export → 收敛
```

- **形态检查**：`export_frame` scale 8 放大，确认比例/对称/剪影可读。
- **调色板纪律**：`get_color_stats` 看是否冒出计划外的颜色（near-duplicate 是常见错误），多了就 `quantize_to_palette` 收敛。
- **像素卫生**：检查有无无意锯齿、脏点、半透明残留。

### Step 5 — 刻意上色（光影/质感/可读性）

- **光影分层**：复制身体层 → `adjust_hsl`（降亮度+偏冷色相）做阴影层，用 `set_layer_blend_mode`（multiply/overlay）叠加。
- **渐变与混色**：`apply_dither_gradient`（天空/金属渐变）、`apply_dither_pattern`（纹理质感，如石头/草地）。
- **轮廓提可读性**：`outline_cel`（1px 描边）让精灵在任何背景上都清晰；可选 `outline_native`（更高质量）。
- **色相替换**：`replace_color` 微调某个具体色，`adjust_hsl` 批量色相位移（夜场景偏蓝）。

### Step 6 — 动画（可选，仅当需要动起来）

1. **建帧**：`add_frames`（设好每帧 ms，如 100-150ms）；`set_tag` 标记动画段落（idle/walk/attack）+ direction（forward/pingpong）。
2. **关键帧先行**：在首/末关键帧画好姿态，`propagate_cels` 把基础帧铺开。
3. **补间**：`tween_cel_positions_eased`（位移，带缓动）、`oscillate_cel_positions`（呼吸/漂浮/待机摇摆）、`tween_cel_opacity_eased`（淡入淡出）、`tween_cel_scale_eased`（缩放）。
4. **验证运动连续**：`render_onion_skin`（叠前后帧残影检查连贯性）+ `compare_frames`（量化帧间差异，确认中间帧确实有变化）。
5. **导出**：`export_tag`（GIF 动画 / PNG 序列）、`export_spritesheet`（精灵表 + JSON 数据，供游戏引擎切帧）。

## 2. 工具选用速查

| 任务场景 | 首选工具 |
|---------|---------|
| 新建精灵 | `create_canvas`（尺寸→存 `aseprite-assets/source/`）|
| 单点像素 | `draw_pixels_at` |
| 直线/矩形/圆/椭圆/多边形 | `draw_*_at` 系列（指定层帧）|
| 填色 | `fill_area_at`（油漆桶）|
| 材质渐变色板 | `generate_color_ramp` |
| 限制全局色 | `apply_palette_preset` + `quantize_to_palette` |
| 阴影/夜色调色 | `duplicate_layer` → `adjust_hsl` → 改 blend mode |
| 纹理质感 | `apply_dither_pattern` |
| 平滑渐变 | `apply_dither_gradient`（Bayer 抖动）/ `apply_gradient_rect` |
| 描边提可读性 | `outline_cel`（1px）/ `outline_native`（高质量）|
| 换某颜色 | `replace_color` |
| **自检形态** | `export_frame`(8×) → tmp/ |
| **自检色板** | `get_color_stats` |
| **自检动画连贯** | `render_onion_skin` / `compare_frames` |
| 静态导出 | `export_sprite`（PNG）→ `aseprite-assets/export/` |
| 动画导出 | `export_tag`（GIF）/ `export_spritesheet`（表+JSON）|
| 查看精灵信息 | `get_sprite_info` |
| 读像素校验 | `get_pixel_color` / `get_pixels_rect` |
| 工具不覆盖的需求 | `run_lua_script`（逃生舱，可批量操作）|

## 3. 像素艺术核心法则（速览）

> 详见 [references/pixel-art-techniques.md](references/pixel-art-techniques.md)。

- **网格对齐**：所有边缘对齐像素网格，坐标取整数。
- **无抗锯齿**：像素艺术禁止平滑边缘，轮廓必须是硬边。
- **有限的色数**：色数越少越有风格；阴影/高光用色板内已有色，不冒新色。
- **轮廓法则**：外轮廓干净（1px），内部可省略；Jaggies（无意锯齿）要修。
- **对称用翻转**：左右对称部件画一半 → `flip_layer` 翻转，省时且对齐。
- **hue shifting 上色**：阴影偏冷（蓝/紫），高光偏暖（黄/橙），比单纯变暗/变亮更立体。

## 4. 交付清单

完成绘制后确认：

- [ ] `.aseprite` 源文件存 `aseprite-assets/source/`
- [ ] 导出 PNG/GIF/精灵表存 `aseprite-assets/export/`
- [ ] 已用 `get_color_stats` 核验色板无冗余色
- [ ] 已用 `export_frame` 8× 预览形态无误
- [ ] （动画）已用 `render_onion_skin` + `compare_frames` 验证连贯
- [ ] `tmp/` 下的临时预览图已删除
- [ ] 若供游戏场景使用，已确认 `load("res://aseprite-assets/...")` 路径正确

## 5. 进阶参考

需要深入的像素艺术技法（调色板设计、形状构建、轮廓与抗锯齿、抖动应用、动画原则、常见角色模板）时，读 [references/pixel-art-techniques.md](references/pixel-art-techniques.md)。
