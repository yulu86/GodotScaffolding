---
name: sprite-analyzer
description: >
  分析游戏精灵图（sprite sheet）资源，精确识别 tile 网格、tile 内容与动画帧分组，
  生成结构化文档。当用户要求分析 sprites/ 下的图片、识别精灵表内容、提取动画帧、
  生成精灵资源文档时使用此技能。
  触发词：分析精灵图、sprite 分析、精灵资源文档、分析 sprites、tile 识别、动画帧分组、图片内容识别。
---

# Sprite Analyzer v2

精确识别精灵表的 tile 网格布局、逐 tile 内容、动画帧分组，并生成结构化 Markdown 文档。

## 核心策略

**AI 主导语义判断 + 算法保证数值精度。** 两阶段管线：

```
算法阶段(tile_tools.py，精确数值)  →  AI阶段(zai-mcp 多工具，语义理解)
  · 尺寸/alpha                         · OCR 提取嵌入标签
  · tile 网格检测/校验                  · 动画分组(看 contact sheet)
  · 切 tile + 标号 contact sheet        · 边界帧精判(ui_diff_check)
  · phash 重复帧检测(可选)              · per-tile 内容识别(analyze_image)
```

**关键纪律：数字以算法为准，AI 不负责量数字。** 纯 AI 视觉会瞎猜 tile 尺寸/列数（实测把 60 列猜成 50、把 64×64 猜成 32×32），故所有"几行几列""tile 多大"必须由 `tile_tools.py` 输出，AI 只给初步 hint 供算法校验。

## 工具

### 辅助脚本：`tile_tools.py`

位置：本 skill 目录下 `scripts/tile_tools.py`。依赖 Python 3.8+ / Pillow，跨平台（无 `sips` 依赖）。

```bash
TILE_TOOLS=.opencode/skills/sprite-analyzer/scripts/tile_tools.py
python $TILE_TOOLS meta  <img>                         # 精确尺寸/alpha/格式 → JSON
python $TILE_TOOLS grid  <img> [--hint "RxC"|--tile "WxH"]  # 检测/校验网格 → JSON
python $TILE_TOOLS split <img> --grid "RxC" --out <dir>      # 切 tile + contact_sheet.png
python $TILE_TOOLS phash <dir> [--threshold 10]              # 重复/近重复帧检测 → JSON
```

### zai-mcp 工具分层（按子任务选最合适的）

| 子任务 | zai-mcp 工具 | 调用时机 |
|--------|-------------|---------|
| 整图网格初判 | `analyze_image` | 给算法 hint |
| **嵌入标签提取** | `extract_text_from_screenshot` | split 后对原图/contact sheet，取标签**名称**（坐标不可靠，行号映射交给 AI 视觉） |
| **动画分组提议** | `analyze_image`（contact sheet） | 看带标号全局图，输出"动画名→行:列范围" |
| **边界帧精判** | `ui_diff_check` | 仅当 AI 对 idle/walk 过渡等边界不确定时，对比相邻 tile |
| per-tile 内容 | `analyze_image` | 单 tile 识别姿态/方向 |

## 工作流

```
1. 扫描目录 → 收集图片路径
2. 单图串行循环（写完一张再下一张，禁止并行）：
   a. tile_tools.py meta <img>                 # 精确尺寸/alpha
   b. AI 整图视觉提网格 hint（analyze_image）    # 问 "几行几列/tile 多大"，只作 hint
   c. tile_tools.py grid <img> --hint "<hint>"  # 算法校验/修正，数字以此为准
   d. 判断置信度：
      · 高 → 继续
      · 低/多个候选 → 列候选，在文档"待确认"区提示用户（必要时用 question 工具）
   e. tile_tools.py split <img> --grid "<rows>x<cols>" --out <临时目录>
   f. AI OCR 提标签（extract_text_from_screenshot，对原图或 contact_sheet）
      · 有标签（如 IDLE/RUN）→ 得标签名清单，AI 视觉把标签映射到行号
      · 无标签 → 跳过
   g. AI 动画分组（analyze_image，输入 contact_sheet.png）：
      · 输出 "动画名 → [(行,列)...]"，循环类型(loop/once/hold)
      · tile 数>20 → 先跑 phash 数值预筛重复/近重复帧，缩小比较范围
      · 分组边界模糊 → 用 ui_diff_check 对比相邻 tile 精判
   h. AI per-tile 内容识别（analyze_image，按需抽 tile 或批量）
   i. 写入文档段（见输出格式）
   j. 清理该图临时目录
3. 文档收尾：顶部目录 + 锚点
```

### 步骤 a-c 详解：网格判定（需求 ①②）

`grid` 子命令是数字精度的核心。流程：

1. `meta` 拿到精确 W×H
2. AI 看整图给出 hint（如 "1x60" 或 "5x10"）—— **AI 只给这个 hint，不直接下结论**
3. `grid --hint` 校验：
   - hint 能整除且导出 tile 尺寸合理 → `method=hint-verified`，采用
   - hint 不整除 → `conflict=true`，算法按因子候选 + alpha 分隔线自动选最优，列出 top5 候选
4. **数字冲突时一律以算法输出为准**，并在文档记录"AI 初判 X，算法修正为 Y"

实测基准：
- `player.png`（3840×64）→ 算法 1×60，tile 64×64，置信度高（AI 曾误判为 50 列/32×32）
- `knight.png`（256×256，带嵌入标签）→ 多候选，算法如实报告不确定，交 OCR+AI 解释

### 步骤 e 详解：切 tile（需求 ⑤）

`split` 把图按网格切成 `tile_rRR_cCC.png`，并生成 `contact_sheet.png`（在原图外侧绘制 `r00`/`c00` 行列标号 + 细网格线，**不缩放原像素**）。contact sheet 供 AI 看全局做分组，标号保证 AI 引用行列时不会错位。

**难识别的图（标签表/非统一网格）默认就走切分流程**——切完逐 tile/看 contact sheet 再用 AI 识别。

### 步骤 f-g 详解：标签与动画分组（需求 ③④）

**标签提取**：`extract_text_from_screenshot` 能精确读出嵌入文字（实测 knight.png 完整提取 `IDLE/RUN/ROLL/HIT/DEATH`）。注意：该工具的**坐标输出不可靠**，所以"标签→行号"的映射由 AI 看 contact sheet 视觉判定（标签名可靠 + 行号视觉可靠 = 整体可靠）。

**动画分组输出**必须含明确的行列标注：

```
动画名 → 帧位置 (行:列) 列表
idle   → 0:0, 0:1, 0:2, 0:3        （4 帧，loop）
walk   → 1:0, 1:1, ..., 1:7         （8 帧，loop）
```

**phash 定位（重要）**：`phash` 基于 aHash，**可靠用途是检测重复/近重复帧**（如 c00 与 c03 identical，可能是 hold 帧或重复帧）。它**不擅长**"同角色不同姿势"的语义分组——语义分组交给 AI（analyze_image + ui_diff_check）。tile 数>20 时跑 phash 预筛重复帧，帮 AI 缩小比较范围。

## 输出文档格式

每个精灵条目：

```markdown
### <filename> — <中文名称>

| 属性 | 值 |
|------|-----|
| 尺寸 | <宽> × <高> px |
| 透明通道 | 有/无 |
| 主色调 | <描述> |

#### 网格检测
| 行 | 列 | Tile 尺寸 | 检测方法 | 置信度 | 备注 |
|----|----|----------|---------|--------|------|
| <R> | <C> | <W>×<H> | auto / hint-verified / 待确认 | 高/中/低 | <AI 初判与算法是否一致> |

#### 动画分组
> 动画名优先取自 OCR 标签；无标签时 AI 语义命名（如 walk/attack）

| 动画名 | 帧数 | 帧位置 (行:列) | 循环类型 | 说明 |
|--------|------|---------------|---------|------|
| idle | 4 | 0:0–0:3 | loop | 待机微动 |
| walk | 8 | 1:0–1:7 | loop | 八方向行走 |

#### Tile 内容
| 行 | 列 | 内容 |
|----|----|------|
| 0 | 0 | <姿态/方向/元素描述> |

**Godot 使用方式：**
- 导入方式 / hframes=vframes 或 SpriteFrames 配置
- 代码示例（如适用）

**适用场景：**
- 场景1 / 场景2
```

## 边界情况

| 情况 | 处理 |
|------|------|
| **非精灵表**（单图，无≥8 像素因子或仅 1×1） | 跳过 grid/split，整图分析，文档标"非精灵表" |
| **带嵌入标签的表**（如 knight.png） | OCR 取标签名 → AI 视觉映射标签→行号；网格若多候选则如实报告 |
| **因子不整除 / 低置信度** | 文档"待确认"区列候选，必要时用 `question` 工具让用户选 |
| **非 RGBA 图（无 alpha）** | `grid` 自动改用亮度方差判网格线（算法内置） |
| **动画边界帧难判**（walk→idle 过渡） | `ui_diff_check` 对比相邻 tile 语义差异 |

## 临时文件（遵全局宪法 §1.7）

- 临时目录：`$TEMP/opencode/sprite_analyzer/<img_stem>/`（Windows）或 `$TMPDIR/...`（unix）
- **每张图分析完（写入文档后）立即删除该图子目录**
- 全部处理完，确认根临时目录已清空

## 注意事项

- **单张串行**：等一张图分析写入文档后才开始下一张，禁止并行
- **去重**：输出文件已有相同图片条目时，合并为更详细版本，不重复添加
- **文档目录**：输出文件顶部含带锚点链接的目录
- **AI 不量数字**：所有尺寸/行列数来自 `tile_tools.py` JSON，AI 不得自行估算后写入文档
- **引用工具**：Read 工具不能直接显示图片，必须用 `zai-mcp-server_analyze_image` 等视觉工具
- **引用脚本**：用相对路径 `.opencode/skills/sprite-analyzer/scripts/tile_tools.py`，通过 `python` 调用
- **宽图/大图防超时**：`analyze_image` 处理超宽 contact sheet（如 60 列单行条带）易超时。对策：①prompt 尽量简短（只问"分段+起止列号"）②仍超时则按列分块分析（如每 10 列一段）③结合 phash 重复帧模式辅助分段
- **交叉验证**：AI 给出的动画分组应与 phash 的近重复帧模式相互印证（如 phash 发现 idle 段每 3 帧重复 = hold-frame，AI 分组边界应在重复模式断裂处）
