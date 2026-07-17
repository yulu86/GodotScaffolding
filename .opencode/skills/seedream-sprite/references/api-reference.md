# Seedream 5.0 pro API 参考

> 详细 API 字段、调用骨架、限制速查。本文件按需加载，主流程见 [../SKILL.md](../SKILL.md)。

## 目录

1. [模型与端点](#1-模型与端点)
2. [输出规格四参数](#2-输出规格四参数)
3. [提示词优化模式](#3-提示词优化模式)
4. [Python 调用骨架（火山 SDK）](#4-python-调用骨架火山-sdk)
5. [curl 调用骨架](#5-curl-调用骨架)
6. [OpenAI SDK 兼容调用](#6-openai-sdk-兼容调用)
7. [使用限制铁律](#7-使用限制铁律)
8. [错误处理](#8-错误处理)
9. [版本对比](#9-版本对比)

## 1. 模型与端点

| 项 | 值 |
|---|---|
| 模型 ID | `doubao-seedream-5-0-pro-260628` |
| Base URL | `https://ark.cn-beijing.volces.com/api/v3` |
| 端点 | `POST /api/v3/images/generations` |
| 鉴权 | `Authorization: Bearer $ARK_API_KEY`（**禁止硬编码**） |
| API Key 获取 | <https://console.volcengine.com/ark/region:ark+cn-beijing/apikey> |

**响应结构**：

```json
{
  "data": [
    { "url": "https://...", "b64_json": "..." }
  ]
}
```

> 取 `resp.data[0].url` 或 `resp.data[0].b64_json`（按 `response_format` 决定）。

## 2. 输出规格四参数

| 参数 | 类型 | 可选值 | 默认 | 说明 |
|------|------|--------|------|------|
| `size` | str | `"1K"` / `"2K"` 或 `"WIDTHxHEIGHT"` | — | **两种方式不可混用** |
| `response_format` | str | `"url"` / `"b64_json"` | `url` | URL 仅保留 24 小时；b64 直接返回 base64 |
| `output_format` | str | `"png"` / `"jpeg"` | — | 像素画、透明背景、需要无损 → `png`；预览图、压缩比优先 → `jpeg` |
| `watermark` | bool | `true` / `false` | — | 是否加"AI 生成"水印，游戏资产通常 `false` |

### size 的两种方式

**方式 1（推荐）— 分辨率档位**：模型按 prompt 中描述的宽高比/形状/用途决定最终像素。

| 分辨率 | 1:1 | 4:3 | 16:9 | 9:16 | 21:9 |
|--------|-----|-----|------|------|------|
| **1K** | 1024×1024 | 1152×864 | 1424×800 | 800×1424 | 1568×672 |
| **2K** | 2048×2048 | 2368×1776 | 2816×1584 | 1584×2816 | 3136×1344 |

**方式 2 — 自定义宽×高像素值**：

- 总像素 ∈ **[921600, 4624220]**（约 [1280×720, 2048×2048×1.1025]）
- 宽高比 ∈ [1/16, 16]
- **需同时满足**两条件
- ✅ 有效：`2048x1024`（总像素 2,097,152 ∈ 区间；宽高比 2 ∈ [1/16, 16]）
- ❌ 无效：`512x512`（总像素 262,144 < 921,600）

> ⚠️ 总像素是对宽×高的**乘积**限制，不是对单边限制；方式 1 与方式 2 **不可混用**。

## 3. 提示词优化模式

通过 `optimize_prompt_options.mode` 字段控制 prompt 重写工序：

| 模式 | 值 | 特点 | 适用 |
|------|----|------|------|
| **标准模式** | `standard`（默认） | 生成内容质量更高，耗时较长 | 对最终画质要求高、可接受等待 |
| **快速模式** | `fast` | 生成耗时更短，效果略低 | 对**时延敏感**的业务（实时 UI 反馈、批量预览） |

**业务组合推荐**：

| 业务场景 | 推荐组合 |
|----------|----------|
| 实时编辑预览 | `fast` + `1K` + `jpeg` |
| 高质量成品出图 | `standard` + `2K` + `png` |
| 批量生成筛选 | `fast` + `1K`（先快出多张筛选，定稿再走 standard） |

## 4. Python 调用骨架（火山 SDK）

```python
from volcenginesdkarkruntime import Ark
import os

client = Ark(
    base_url="https://ark.cn-beijing.volces.com/api/v3",
    api_key=os.getenv("ARK_API_KEY"),  # 禁止硬编码
)

# 文生图
resp = client.images.generate(
    model="doubao-seedream-5-0-pro-260628",
    prompt="...",
    size="2K",
    output_format="png",
    response_format="url",
    watermark=False,
    # optimize_prompt_options={"mode": "fast"},  # 可选：切换快速模式
)

# 图生图 / 多图融合 / 交互编辑（增加 image 字段）
resp = client.images.generate(
    model="doubao-seedream-5-0-pro-260628",
    prompt="...",
    image="https://...",   # 单图
    # image=["https://1", "https://2"],  # 多图融合（≤10 张）
    size="2K",
    output_format="png",
    response_format="url",
    watermark=False,
)

# 下载图片（URL 仅 24h）
import requests
img_url = resp.data[0].url
with open("output.png", "wb") as f:
    f.write(requests.get(img_url).content)
```

安装：`pip install 'volcengine-python-sdk[ark]' requests`

## 5. curl 调用骨架

```bash
curl https://ark.cn-beijing.volces.com/api/v3/images/generations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ARK_API_KEY" \
  -d '{
    "model": "doubao-seedream-5-0-pro-260628",
    "prompt": "...",
    "image": "https://...",
    "size": "2K",
    "output_format": "png",
    "response_format": "url",
    "watermark": false
  }'
```

响应示例：

```json
{
  "data": [{ "url": "https://..." }]
}
```

## 6. OpenAI SDK 兼容调用

便于已有 OpenAI 代码迁移；火山专属字段需用 `extra_body` 传递。

```python
from openai import OpenAI
import os, requests

client = OpenAI(
    base_url="https://ark.cn-beijing.volces.com/api/v3",
    api_key=os.getenv("ARK_API_KEY"),
)

resp = client.images.generate(
    model="doubao-seedream-5-0-pro-260628",
    prompt="...",
    size="2K",  # 注意：OpenAI SDK 原生 size 格式是 "1024x1024"，这里走火山格式
    response_format="url",
    extra_body={
        "image": "https://...",
        "watermark": False,
        "output_format": "png",
        # "optimize_prompt_options": {"mode": "fast"},
    },
)

# 下载（同上）
```

安装：`pip install openai requests`

> ⚠️ OpenAI SDK 兼容路径下 `size` 字段可能被 OpenAI SDK 自身校验（如要求 `"1024x1024"` 格式）。如遇校验错误，改用火山 SDK（§4）或 curl（§5）。

## 7. 使用限制铁律

| 项 | 值 | 后果 |
|---|---|---|
| 图片格式 | jpeg / png / webp / bmp / tiff / gif / heic / heif | 不支持则报错 |
| 宽高比 | ∈ [1/16, 16] | 越界报错 |
| 单边像素 | > 14 px | 越界报错 |
| 文件大小 | ≤ 30 MB | 超出报错 |
| 总像素 | ≤ 6000×6000 = 36,000,000 | 超出报错 |
| 参考图数 | ≤ 10 张 | 超出报错 |
| 参考图 + 生成数 | ≤ 15 | 超出报错 |
| **URL 保留** | **24 小时** | 超时自动清除，**必须及时下载** |
| RPM 限流 | 500 张/分钟（同账号同模型，区分版本） | 超出限流 |

## 8. 错误处理

| HTTP 状态 | 含义 | 处理 |
|-----------|------|------|
| 401 | API Key 无效或过期 | 检查 `ARK_API_KEY` 配置，重新从控制台获取 |
| 429 | 限流（RPM 超限） | 退避重试（指数退避，初始 1s） |
| 400 | 参数错误（size / format / image 越界） | 对照 §2 / §7 检查参数 |
| 5xx | 服务端错误 | 重试 3 次后退避 |

**重试骨架**（Python）：

```python
import time
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, max=10))
def generate_with_retry(client, **kwargs):
    return client.images.generate(**kwargs)
```

## 9. 版本对比

> 仅 5.0 pro 独占交互编辑；其余版本各有取舍。

| 模型 | Model ID | 文生组图 | 交互编辑 | 流式输出 | 联网搜索 | 提示词优化 |
|------|----------|----------|----------|----------|----------|-----------|
| **5.0 pro** | `doubao-seedream-5-0-pro-260628` | ✗ | **✓ 独占** | ✗ | ✗ | standard / fast |
| 5.0 lite | `doubao-seedream-5-0-260128` / `-lite-260128` | ✓ | ✗ | ✓ | ✓ | standard |
| 4.5 | `doubao-seedream-4-5-251128` | ✓ | ✗ | ✓ | ✗ | standard |
| 4.0 | `doubao-seedream-4-0-250828` | ✓ | ✗ | ✓ | ✗ | standard / fast |

**5.0 pro 的取舍**：拿组图 / 流式 / 联网搜索 换取**交互编辑 + 提示词优化双模式**。IPM 限流统一 500 张/分钟。

---

_来源：火山方舟官方教程，参考 Wiki [[Doubao Seedream 5.0 pro 教程]] / [[Ark SDK]] / [[图像生成输出规格]] / [[图像生成提示词优化模式]]_
