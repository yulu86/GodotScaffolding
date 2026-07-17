# 像素画专用流水线

> Seedream 是通用图像生成模型，**非像素画原生**。社区共识（Wiki [[像素画AI生成工作流]] 模式 B）：`generate-high-res → downscale → index-palette`。本文件给出完整可执行的 Python 脚本与参数表。

## 目录

1. [核心思路](#1-核心思路)
2. [六步流水线](#2-六步流水线)
3. [完整 Python 脚本](#3-完整-python-脚本)
4. [参数决策表](#4-参数决策表)
5. [像素画友好的 prompt 模板](#5-像素画友好的-prompt-模板)
6. [与 Aseprite 衔接](#6-与-aseprite-衔接)
7. [常见问题](#7-常见问题)

## 1. 核心思路

```
Prompt(像素画关键词)
    ↓
Seedream 生成 2K 高清图      ← 模型在原生低分辨率下表现差，故走高清
    ↓
最近邻降采样到 32/64/128 px   ← PIL NEAREST 避免抗锯齿污染
    ↓
MedianCut 调色板量化          ← 限制颜色数（16/32），符合像素画调色板约束
    ↓
（可选）Aseprite 后处理       ← import_image_as_layer → 切帧 / 加描边
```

**为什么不能直接让 Seedream 出像素画？**

- 通用扩散模型在原生低分辨率（如 32×32）下笔触混乱、抗锯齿污染严重
- 像素画的"色块概括 + 调色板约束 + 完美线条规则"对模型而言是反训练分布的
- 故：让模型先出高质量高清图，再用确定性算法（NEAREST + quantize）降维到像素画

## 2. 六步流水线

| 步 | 操作 | 工具 | 产物 |
|----|------|------|------|
| 1 | 写像素画友好 prompt（见 §5） | — | prompt 字符串 |
| 2 | 调用 Seedream 生成 2K PNG | `seedream_gen.py` / Ark SDK | `<name>_hires.png` (2K) |
| 3 | 下载到 `aseprite-assets/source/ai-generated/<task>/` | `requests` | 持久化文件 |
| 4 | NEAREST 降采样到目标分辨率 | `Pillow` | `<name>_pixel.png` |
| 5 | MedianCut 调色板量化 | `Pillow.quantize` | `<name>_indexed.png` |
| 6 | （可选）Aseprite 后处理 | `draw-aseprite` skill | `.aseprite` 工程 |

## 3. 完整 Python 脚本

> 保存为 `.tmp/pixel_pipeline.py` 或直接复用本 skill 的 `scripts/seedream_gen.py`（已封装高清生成），再叠加本节后处理。

```python
"""Seedream 高清图 → 像素画降采样 → 索引调色板"""
import os
import sys
from pathlib import Path

from PIL import Image
from volcenginesdkarkruntime import Ark

# === 参数（来自命令行或上层调用）===
ARK_MODEL = "doubao-seedream-5-0-pro-260628"
ARK_BASE_URL = "https://ark.cn-beijing.volces.com/api/v3"
TARGET_SIZE = 64           # 目标像素画分辨率：32 / 64 / 128 / 256
PALETTE_COLORS = 16        # 调色板颜色数：8 / 16 / 32
OUT_DIR = Path("aseprite-assets/source/ai-generated/<task>")  # 替换 <task>

def generate_hires(prompt: str, out_path: Path) -> Path:
    """调 Seedream 生成 2K 高清图并下载保存。"""
    client = Ark(
        base_url=ARK_BASE_URL,
        api_key=os.getenv("ARK_API_KEY"),  # 禁止硬编码
    )
    resp = client.images.generate(
        model=ARK_MODEL,
        prompt=prompt,
        size="2K",
        output_format="png",
        response_format="url",
        watermark=False,
        # optimize_prompt_options={"mode": "standard"},  # 像素画建议 standard
    )
    img_url = resp.data[0].url

    import requests
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(requests.get(img_url).content)
    print(f"[ok] hires saved: {out_path}")
    return out_path

def downscale_nearest(hires_path: Path, target: int, out_path: Path) -> Path:
    """NEAREST 降采样，避免抗锯齿污染。"""
    with Image.open(hires_path) as img:
        # 转为 RGBA 保持透明通道
        img = img.convert("RGBA")
        # 等比缩放：短边到 target，保持像素长宽比
        w, h = img.size
        if w < h:
            new_w, new_h = target, int(target * h / w)
        else:
            new_w, new_h = int(target * w / h), target
        pixel_img = img.resize((new_w, new_h), Image.NEAREST)
        pixel_img.save(out_path)
    print(f"[ok] pixel saved: {out_path} ({new_w}x{new_h})")
    return out_path

def index_palette(pixel_path: Path, colors: int, out_path: Path) -> Path:
    """MedianCut 调色板量化，限制颜色数。"""
    with Image.open(pixel_path) as img:
        img = img.convert("RGBA")
        # 量化透明通道外的颜色
        alpha = img.getchannel("A")
        rgb = img.convert("RGB")
        quantized = rgb.quantize(colors=colors, method=Image.MEDIANCUT)
        # 重新拼回 alpha
        quantized_rgba = Image.merge("RGBA", (
            quantized.convert("RGB").getchannel("R"),
            quantized.convert("RGB").getchannel("G"),
            quantized.convert("RGB").getchannel("B"),
            alpha,
        ))
        quantized_rgba.save(out_path)
    actual_colors = len(quantized_rgba.convert("RGB").getcolors(maxcolors=256))
    print(f"[ok] indexed saved: {out_path} ({actual_colors} colors)")
    return out_path

def run_pipeline(prompt: str, name: str, task: str,
                 target: int = 64, colors: int = 16) -> dict:
    """完整流水线入口。返回各阶段产物路径。"""
    out_dir = OUT_DIR.parent / task
    out_dir.mkdir(parents=True, exist_ok=True)

    hires = out_dir / f"{name}_hires.png"
    pixel = out_dir / f"{name}_pixel_{target}.png"
    indexed = out_dir / f"{name}_indexed_{colors}c.png"

    generate_hires(prompt, hires)
    downscale_nearest(hires, target, pixel)
    index_palette(pixel, colors, indexed)

    return {
        "hires": str(hires),
        "pixel": str(pixel),
        "indexed": str(indexed),
    }

if __name__ == "__main__":
    # 命令行用法：python pixel_pipeline.py "<prompt>" <name> <task> [target] [colors]
    result = run_pipeline(
        prompt=sys.argv[1],
        name=sys.argv[2],
        task=sys.argv[3],
        target=int(sys.argv[4]) if len(sys.argv) > 4 else 64,
        colors=int(sys.argv[5]) if len(sys.argv) > 5 else 16,
    )
    print(result)
```

## 4. 参数决策表

### 目标分辨率（`TARGET_SIZE`）

| 用途 | 推荐 | 说明 |
|------|------|------|
| 物品图标 / 道具 | 32 | 复古 JRPG 风格 |
| 角色立绘 / NPC | 64–128 | 立绘细节 |
| 场景元素 / 瓦片 | 16–32 | TileMap 用 |
| BOSS / 主角精绘 | 128–256 | 大型精灵 |
| 概念图（非像素画用途） | 不降采样 | 直接用 `_hires.png` |

### 调色板颜色数（`PALETTE_COLORS`）

| 调色板 | 推荐色数 | 说明 |
|--------|---------|------|
| GameBoy / 极简复古 | 4 | 极致限制 |
| DawnBringer 16 | 16 | 经典像素画调色板 |
| DawnBringer 32 | 32 | 兼顾细节 |
| 自由调色板 | 64+ | 接近原始 |

> 像素画经典调色板可参考 [Lospec Palette List](https://lospec.com/palette-list)。如使用 DawnBringer 等固定调色板，应在 `index_palette` 后再映射到目标调色板（用 `ImagePalette` + 最近邻色匹配）。

### 提示词优化模式

- 像素画任务**建议 `standard`**（质量优先）—— fast 模式可能在高清图阶段引入额外细节，污染降采样质量。
- 大量批量预览可临时用 `fast` 出草稿，定稿再 standard。

## 5. 像素画友好的 prompt 模板

在普通 prompt 基础上叠加以下关键词（中英文都行）：

**通用基础**：

```
pixel art style, clean edges, limited palette, no anti-aliasing,
flat shading, crisp pixel boundaries
```

**主体描述模板**（角色）：

```
<pixel art style> full body character of <subject>,
<pose>, <expression>, <clothing/equipment>,
simple flat background or transparent background,
centered composition, facing front (or 3/4 view)
```

**主体描述模板**（物品图标）：

```
<pixel art style> game item icon of <subject>,
centered, on transparent or dark background,
top-down view, simple shading
```

**避雷词**（**禁止**出现在像素画 prompt）：

- `photorealistic`, `8k`, `4k`, `high detail`, `smooth`, `blur`, `bokeh`
- `anti-aliasing`, `gradient`, `soft shadow`
- 任何引导模型出"高清摄影感"的词

**透明背景**：

```
... , transparent background, isolated subject, no background,
PNG with alpha channel
```

> 模型对"transparent background"理解可能不稳定；建议生成后用 `Pillow` 后处理去除背景色（如把接近 `#FFFFFF` 的像素转为 alpha=0）。

## 6. 与 Aseprite 衔接

像素画流水线输出 `<name>_indexed_16c.png` 后，建议交给 `draw-aseprite` skill 做后续：

1. **创建新工程**：用 Aseprite MCP `create_canvas` 创建对应分辨率的 `.aseprite`。
2. **导入为图层**：用 `import_image_as_layer` 把 `_indexed_16c.png` 导入。
3. **索引调色板**：用 Aseprite MCP `apply_palette_preset`（dawnbringer16 / 32）或 `quantize_to_palette` 锁定到目标调色板。
4. **切帧动画**（按需）：参考 `draw-aseprite` skill 的动画工作流。
5. **导出**：`export_sprite` / `export_spritesheet` 输出到 `aseprite-assets/export/`。

> 这是"AI 出草稿 + 人工精修切帧"的主流工作流（Wiki [[像素画AI生成工作流]] 实战建议）。

## 7. 常见问题

### Q1：降采样后边缘锯齿严重 / 形状失真？

- 检查 prompt 是否含"photorealistic / smooth"等词，去掉。
- 尝试更高分辨率档位（如 2K 而非 1K）的源图，让模型出更清晰的轮廓。
- 切换 `Image.LANCZOS` 一次再到目标分辨率，有时能改善斜线锯齿（注意：会引入抗锯齿，需权衡）。

### Q2：索引后颜色"脏"（出现意料外的中间色）？

- 把 `PALETTE_COLORS` 调小（如 32 → 16）。
- 改用固定调色板（DawnBringer）做最终映射，而非 MEDIANCUT 自动量化。
- 用 Aseprite 打开后手动清理调色板（最稳）。

### Q3：Seedream 把"像素画"理解成"低多边形" / "马赛克滤镜"？

- 把关键词改为更明确的"pixel art, retro game style, NES/SNES era graphics"。
- 在 prompt 中点名游戏参考："in the style of Stardew Valley / Celeste / Undertale"。

### Q4：透明背景无效？

- 模型对 alpha 通道理解不稳定，常见结果是白色或黑色背景。
- 解决：脚本后处理，把接近背景色的像素（容差 ±10）转为 alpha=0。
- 或先生成深绿色背景（#00FF00 chroma key），后处理抠图。

---

_来源：Wiki [[像素画AI生成工作流]] / [[Doubao Seedream 5.0 pro 教程]] / [[像素画视觉基础]]_
