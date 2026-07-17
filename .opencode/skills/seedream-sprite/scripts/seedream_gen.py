#!/usr/bin/env python3
"""Seedream 5.0 pro 图像生成命令行工具。

封装火山方舟 API 调用、URL 下载持久化、像素画降采样+索引三件套。
所有鉴权一律走 ARK_API_KEY 环境变量，禁止硬编码。

用法：
    # 文生图
    python3 seedream_gen.py text2img --prompt "..." --size 2K --out <path>.png

    # 图生图
    python3 seedream_gen.py img2img --prompt "..." --image <url> --out <path>.png

    # 多图融合
    python3 seedream_gen.py blend --prompt "..." --images a.png b.png --out <path>.png

    # 像素画模式（高清生成 + 降采样 + 索引）
    python3 seedream_gen.py text2img --prompt "..." --pixel --target 64 --colors 16 \
        --out aseprite-assets/source/ai-generated/goblin/goblin.png
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path
from typing import Iterable

ARK_MODEL = "doubao-seedream-5-0-pro-260628"
ARK_BASE_URL = "https://ark.cn-beijing.volces.com/api/v3"


def _die_missing_dep(pkg: str, hint: str) -> None:
    sys.stderr.write(f"[error] 缺少依赖 {pkg}：{hint}\n")
    sys.exit(2)


def _import_ark():
    """延迟导入火山 SDK，让 --help 等基础命令不依赖第三方包。"""
    try:
        from volcenginesdkarkruntime import Ark
        return Ark
    except ImportError:
        _die_missing_dep(
            "volcenginesdkarkruntime",
            "pip install 'volcengine-python-sdk[ark]' requests",
        )


def _import_requests():
    try:
        import requests
        return requests
    except ImportError:
        _die_missing_dep("requests", "pip install requests")


def _import_pil():
    try:
        from PIL import Image
        return Image
    except ImportError:
        _die_missing_dep("PIL", "pip install Pillow")


def build_client():
    """从 ARK_API_KEY 环境变量构造 Ark client。禁止硬编码 Key。"""
    Ark = _import_ark()
    api_key = os.getenv("ARK_API_KEY")
    if not api_key:
        sys.stderr.write(
            "[error] 未设置 ARK_API_KEY 环境变量。\n"
            "  - macOS/Linux: 在 ~/.zshrc 或项目根 .env 添加 ARK_API_KEY=<your-key>\n"
            "  - 获取地址: https://console.volcengine.com/ark/region:ark+cn-beijing/apikey\n"
        )
        sys.exit(2)
    return Ark(base_url=ARK_BASE_URL, api_key=api_key)


def generate(
    client,
    *,
    prompt: str,
    image: str | list[str] | None = None,
    size: str = "2K",
    output_format: str = "png",
    response_format: str = "url",
    watermark: bool = False,
    optimize_mode: str = "standard",
) -> str:
    """调用 Seedream 5.0 pro 生成图片，返回图片 URL（24h 失效）。"""
    kwargs = dict(
        model=ARK_MODEL,
        prompt=prompt,
        size=size,
        output_format=output_format,
        response_format=response_format,
        watermark=watermark,
    )
    if image:
        kwargs["image"] = image
    if optimize_mode and optimize_mode != "standard":
        kwargs["optimize_prompt_options"] = {"mode": optimize_mode}

    resp = client.images.generate(**kwargs)
    data = resp.data[0]
    if hasattr(data, "b64_json") and data.b64_json:
        import base64
        # b64 模式：返回 base64 字符串
        return ("b64:", data.b64_json)
    return data.url


def download(url_or_b64: str | tuple, out_path: Path) -> Path:
    """下载 URL 图片或解码 base64 到本地。"""
    out_path.parent.mkdir(parents=True, exist_ok=True)

    if isinstance(url_or_b64, tuple) and url_or_b64[0] == "b64":
        import base64
        with open(out_path, "wb") as f:
            f.write(base64.b64decode(url_or_b64[1]))
    else:
        requests = _import_requests()
        resp = requests.get(url_or_b64, timeout=60)
        resp.raise_for_status()
        with open(out_path, "wb") as f:
            f.write(resp.content)
    return out_path


def downscale_nearest(hires_path: Path, target: int, out_path: Path) -> Path:
    """NEAREST 降采样，保持透明通道。"""
    Image = _import_pil()
    with Image.open(hires_path) as img:
        img = img.convert("RGBA")
        w, h = img.size
        # 短边到 target，保持像素长宽比
        if w < h:
            new_w, new_h = target, int(target * h / w)
        else:
            new_w, new_h = int(target * w / h), target
        pixel_img = img.resize((new_w, new_h), Image.NEAREST)
        pixel_img.save(out_path)
    print(f"[ok] pixel saved: {out_path} ({new_w}x{new_h})", file=sys.stderr)
    return out_path


def index_palette(pixel_path: Path, colors: int, out_path: Path) -> Path:
    """MedianCut 调色板量化，保留 alpha 通道。"""
    Image = _import_pil()
    with Image.open(pixel_path) as img:
        img = img.convert("RGBA")
        alpha = img.getchannel("A")
        rgb = img.convert("RGB")
        quantized = rgb.quantize(colors=colors, method=Image.MEDIANCUT)
        rgb_back = quantized.convert("RGB")
        merged = Image.merge("RGBA", (
            rgb_back.getchannel("R"),
            rgb_back.getchannel("G"),
            rgb_back.getchannel("B"),
            alpha,
        ))
        merged.save(out_path)
    actual_colors = len(merged.convert("RGB").getcolors(maxcolors=256) or [])
    print(f"[ok] indexed saved: {out_path} ({actual_colors} colors)", file=sys.stderr)
    return out_path


def save_prompt_record(prompt: str, out_dir: Path, **extra) -> None:
    """保存 prompt 记录到 prompt.md，便于复现/迭代。"""
    out_dir.mkdir(parents=True, exist_ok=True)
    record = out_dir / "prompt.md"
    with open(record, "a", encoding="utf-8") as f:
        f.write(f"\n## {Path(extra.get('name', 'item'))}\n\n")
        f.write(f"- **prompt**: {prompt}\n")
        for k, v in extra.items():
            if k != "name":
                f.write(f"- **{k}**: {v}\n")
        f.write(f"- **timestamp**: {__import__('datetime').datetime.now().isoformat()}\n")


def cmd_text2img(args: argparse.Namespace) -> None:
    client = build_client()
    out = Path(args.out)
    out_dir = out.parent
    base_name = out.stem

    # Step 1: 生成高清图
    hires_path = out if not args.pixel else out_dir / f"{base_name}_hires.png"
    url = generate(
        client,
        prompt=args.prompt,
        size=args.size,
        output_format=args.format,
        response_format=args.response_format,
        watermark=not args.no_skip_watermark if hasattr(args, "no_skip_watermark") else False,
        optimize_mode=args.optimize_mode,
    )
    download(url, hires_path)
    print(f"[ok] hires saved: {hires_path}", file=sys.stderr)

    # Step 2: 像素画后处理（可选）
    if args.pixel:
        pixel_path = out_dir / f"{base_name}_pixel_{args.target}.png"
        downscale_nearest(hires_path, args.target, pixel_path)
        indexed_path = out_dir / f"{base_name}_indexed_{args.colors}c.png"
        index_palette(pixel_path, args.colors, indexed_path)
        # 最终输出指向 indexed 版本
        if args.out != str(indexed_path):
            print(f"[info] 像素画最终输出: {indexed_path}", file=sys.stderr)

    save_prompt_record(
        args.prompt, out_dir,
        name=base_name, size=args.size, mode=args.optimize_mode, pixel=args.pixel,
    )


def cmd_img2img(args: argparse.Namespace) -> None:
    client = build_client()
    out = Path(args.out)
    url = generate(
        client,
        prompt=args.prompt,
        image=args.image,
        size=args.size,
        output_format=args.format,
        optimize_mode=args.optimize_mode,
    )
    download(url, out)
    print(f"[ok] saved: {out}", file=sys.stderr)
    save_prompt_record(args.prompt, out.parent, name=out.stem, image=args.image, size=args.size)


def cmd_blend(args: argparse.Namespace) -> None:
    client = build_client()
    if len(args.images) > 10:
        sys.stderr.write("[error] 参考图数量不能超过 10 张\n")
        sys.exit(2)
    if len(args.images) + 1 > 15:
        sys.stderr.write("[error] 参考图数 + 生成数 不能超过 15\n")
        sys.exit(2)
    out = Path(args.out)
    url = generate(
        client,
        prompt=args.prompt,
        image=args.images,
        size=args.size,
        output_format=args.format,
        optimize_mode=args.optimize_mode,
    )
    download(url, out)
    print(f"[ok] saved: {out}", file=sys.stderr)
    save_prompt_record(
        args.prompt, out.parent, name=out.stem,
        images=", ".join(args.images), size=args.size,
    )


def add_common_args(p: argparse.ArgumentParser) -> None:
    p.add_argument("--prompt", required=True, help="生成 prompt")
    p.add_argument("--out", required=True, help="输出文件路径（建议 .png）")
    p.add_argument("--size", default="2K", help='分辨率：1K / 2K / WxH（默认 2K）')
    p.add_argument("--format", default="png", choices=["png", "jpeg"], help="输出格式")
    p.add_argument("--optimize-mode", default="standard",
                   choices=["standard", "fast"], help="提示词优化模式")
    p.add_argument("--response-format", default="url",
                   choices=["url", "b64_json"], help="响应格式")


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        description="Seedream 5.0 pro 图像生成命令行工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_text = sub.add_parser("text2img", help="文生图")
    add_common_args(p_text)
    p_text.add_argument("--pixel", action="store_true",
                        help="启用像素画后处理（高清→降采样→索引）")
    p_text.add_argument("--target", type=int, default=64,
                        help="像素画目标分辨率（默认 64）")
    p_text.add_argument("--colors", type=int, default=16,
                        help="像素画调色板颜色数（默认 16）")
    p_text.set_defaults(func=cmd_text2img)

    p_img = sub.add_parser("img2img", help="单图生图 / 交互编辑")
    add_common_args(p_img)
    p_img.add_argument("--image", required=True,
                       help="参考图 URL 或本地路径（本地需先上传到可访问 URL）")
    p_img.set_defaults(func=cmd_img2img)

    p_blend = sub.add_parser("blend", help="多图融合")
    add_common_args(p_blend)
    p_blend.add_argument("--images", required=True, nargs="+",
                         help="参考图 URL 列表（≤10 张）")
    p_blend.set_defaults(func=cmd_blend)

    args = parser.parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
