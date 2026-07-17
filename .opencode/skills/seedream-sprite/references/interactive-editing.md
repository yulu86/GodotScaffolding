# 交互编辑能力（5.0 pro 独占）

> 通过归一化坐标（0-999）+ 自然语言指令，实现局部元素替换、物品定位、区域生成、跨图搬运。Wiki [[Doubao Seedream 5.0 pro 交互编辑指南]] / [[Seedream交互编辑坐标系]]。

## 目录

1. [两种坐标标记](#1-两种坐标标记)
2. [归一化坐标系铁律](#2-归一化坐标系铁律)
3. [三大支持场景](#3-三大支持场景)
4. [多主体场景的 prompt 技巧](#4-多主体场景的-prompt-技巧)
5. [跨图编辑（最强用法）](#5-跨图编辑最强用法)
6. [调用骨架](#6-调用骨架)
7. [前端交互实现（如需自建工具）](#7-前端交互实现如需自建工具)

## 1. 两种坐标标记

| 标记 | 语法 | 用途 |
|------|------|------|
| **点选** | `<point>x y</point>` | 指定一个点，**模型判断影响范围** |
| **框选** | `<bbox>x1 y1 x2 y2</bbox>` | 指定左上角 + 右下角，**精确控制区域大小** |

> 标记直接嵌入自然语言 prompt 中，与其他文本并列。坐标都是整数。

## 2. 归一化坐标系铁律

| 规则 | 说明 |
|------|------|
| **图片按 1000×1000 等分** | 不管原图实际像素多少，都映射到 1000×1000 网格 |
| **左上角为 (0, 0)** | 类似 CSS / Canvas 坐标系 |
| **右下角为 (999, 999)** | 注意上限是 **999** 不是 1000 |
| **取值范围 [0, 999]** | 整数；越界会被夹紧或报错 |

**换算公式**（原图任意尺寸 → 归一化）：

```python
def to_normalized(x_px: int, y_px: int, width: int, height: int) -> tuple[int, int]:
    """像素坐标 → 归一化 0-999 坐标"""
    return (
        round(x_px / width * 1000),
        round(y_px / height * 1000),
    )

def to_bbox(x1, y1, x2, y2, width, height):
    """像素 bbox → 归一化 bbox"""
    nx1, ny1 = to_normalized(x1, y1, width, height)
    nx2, ny2 = to_normalized(x2, y2, width, height)
    return f"<bbox>{nx1} {ny1} {nx2} {ny2}</bbox>"
```

**示例**：原图 800×600，框选左上角 100×100 区域：

```python
to_bbox(0, 0, 100, 100, 800, 600)
# => <bbox>0 0 125 167</bbox>
```

## 3. 三大支持场景

| 场景 | 交互 | prompt 写法 |
|------|------|------------|
| 编辑指定点附近对象 | 点选 | `把图1<point>520 460</point>位置换成皇冠` |
| 编辑指定区域对象 | 框选 | `把图1<bbox>120 180 640 760</bbox>区域替换成花园` |
| 跨图片编辑 | 点选 + 框选 | `将图1<bbox>179 283 796 986</bbox>的主体放到图2<bbox>118 331 933 871</bbox>位置` |

> 标签后**不需要空格**分隔，自然语言描述可以紧跟 `</bbox>` 之后。

## 4. 多主体场景的 prompt 技巧

**问题**：当 `<bbox>` 覆盖区域内存在**多个主体/元素**时，模型可能选错对象。

**解决**：在 prompt 中补充自然语言限定目标对象。

| 写法 | 效果 |
|------|------|
| `把图1<bbox>120 180 640 760</bbox>区域换成人` | ❓ 可能替换区域内任意一个人 |
| `把图1<bbox>120 180 640 760</bbox>区域内的**左侧人物**换成机器人` | ✅ 明确指向 |
| `把图1<bbox>120 180 640 760</bbox>区域内的**戴帽子的猫**换成狗` | ✅ 用特征限定 |

**保持不变的写法**（一并框选并明确"保持"）：

```
把图1<bbox>120 180 640 760</bbox>区域替换成花园，
图1<bbox>700 120 920 360</bbox>区域保持不变
```

## 5. 跨图编辑（最强用法）

把"参考图 A 的角色 + 参考图 B 的背景"用坐标精确组合——这对游戏开发"角色立绘 × 场景原画"组合是直接可用的工程能力。

```
将图1<bbox>179 283 796 986</bbox>的主体放到图2<bbox>118 331 933 871</bbox>位置，
将图2<point>50 50</point>位置换成皇冠
```

**游戏资产典型场景**：

| 需求 | 参考图 1 | 参考图 2 | prompt 范式 |
|------|---------|---------|------------|
| 角色立绘合成到场景 | 角色透明底 PNG | 场景原画 | `将图1<bbox>...</bbox>的角色放到图2<bbox>...</bbox>位置` |
| 武器装备替换 | 角色立绘 | 新武器图 | `把图1<point>...</point>位置的武器换成图2<bbox>...</bbox>的武器` |
| NPC 表情切换 | 角色全身 | 新表情特写 | `把图1<bbox>...</bbox>的脸部表情替换成图2<bbox>...</bbox>` |

## 6. 调用骨架

交互编辑的 API 调用与普通图生图完全一致，**区别仅在于 prompt 中嵌入坐标标记**。

```python
from volcenginesdkarkruntime import Ark
import os

client = Ark(
    base_url="https://ark.cn-beijing.volces.com/api/v3",
    api_key=os.getenv("ARK_API_KEY"),
)

# 单图坐标编辑（点选）
resp = client.images.generate(
    model="doubao-seedream-5-0-pro-260628",
    prompt="把图1<point>520 460</point>位置换成黄金皇冠，闪闪发光",
    image="https://.../reference.png",
    size="2K",
    output_format="png",
    response_format="url",
    watermark=False,
)

# 跨图编辑（图1的角色 → 图2的背景）
resp = client.images.generate(
    model="doubao-seedream-5-0-pro-260628",
    prompt="将图1<bbox>179 283 796 986</bbox>的角色立绘放到图2<bbox>118 331 933 871</bbox>位置，保持图2其余场景不变",
    image=[
        "https://.../character.png",  # 图1
        "https://.../scene.png",       # 图2
    ],
    size="2K",
    output_format="png",
    response_format="url",
    watermark=False,
)
```

**图号映射**：`image` 列表中的第 N 张对应 prompt 中的 `图N`。被 prompt 引用的图才生效，未被引用的会被忽略。

## 7. 前端交互实现（如需自建工具）

> 仅当用户需要自建 Web 端"点选编辑"工具时参考。本 skill 主体工作流不依赖前端，靠 AI 直接生成坐标即可。

**三层坐标转换**（Client → World → Normalized）：

| 坐标类型 | 含义 | 用途 |
|----------|------|------|
| **Client** | 鼠标相对浏览器窗口左上角 | 浏览器事件原始输入 |
| **World** | 画布内部逻辑坐标系 | 消除画布缩放/平移 |
| **Normalized** | 相对单张图归一化到 0-999 | 最终写入 `<point>` / `<bbox>` |

**JavaScript 实现**：

```javascript
// Client → World
function clientToWorld(clientX, clientY, viewport, view) {
  const rect = viewport.getBoundingClientRect();
  return {
    x: (clientX - rect.left - view.x) / view.scale,
    y: (clientY - rect.top  - view.y) / view.scale,
  };
}

// World → Normalized (0-999)
function normalizedPoint(worldPoint, image) {
  const clamp1000 = (v) => Math.max(0, Math.min(999, Math.round(v)));
  return {
    x: clamp1000(((worldPoint.x - image.x) / image.width)  * 1000),
    y: clamp1000(((worldPoint.y - image.y) / image.height) * 1000),
  };
}
```

**端到端四步流程**：

```
1. 上传图片 → 画布记录每张图的 naturalWidth/Height/x/y/URL/label
2. 用户操作（点选 / 框选）→ Client → World → Normalized 坐标
3. 组装 prompt（图号重映射 + 坐标标记拼接）
4. 调用 images.generate → 返回编辑后图片 URL
```

---

_来源：Wiki [[Doubao Seedream 5.0 pro 交互编辑指南]] / [[Seedream交互编辑坐标系]]_
