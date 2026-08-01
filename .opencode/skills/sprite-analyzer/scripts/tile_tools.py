#!/usr/bin/env python3
"""tile_tools.py - Sprite sheet tile grid detection & splitting.

Subcommands emit JSON to stdout for AI agent consumption.
Cross-platform (Python 3.8+ / Pillow). Part of sprite-analyzer skill.

Subcommands:
  meta  <img>                         -> precise size/alpha/format
  grid  <img> [--hint RxC|--tile WxH] -> detect or verify tile grid
  split <img> --grid RxC --out <dir>  -> slice tiles + labeled contact sheet
  phash <dir>                         -> perceptual-hash similarity matrix
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# Common pixel-art / sprite tile sizes used as detection priors.
COMMON_SIZES = (16, 24, 32, 40, 48, 56, 64, 72, 80, 96, 112, 128, 144, 192, 256)
MIN_TILE = 8
MAX_TILE = 1024
# Below this mean-alpha a column/row counts as a transparent "gutter".
GUTTER_ALPHA_THRESHOLD = 16


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #
def _open(path: str) -> Image.Image:
    img = Image.open(path)
    img.load()
    return img


def _has_alpha(img: Image.Image) -> bool:
    return img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info)


def _to_rgba(img: Image.Image) -> Image.Image:
    if img.mode == "RGBA":
        return img
    return img.convert("RGBA")


def _column_alpha_means(img: Image.Image) -> list[float]:
    """Mean alpha per column (0..255). Uses Box-resize for speed."""
    rgba = _to_rgba(img)
    col = rgba.split()[3].resize((rgba.width, 1))
    return [v / 1.0 for v in col.tobytes()]


def _row_alpha_means(img: Image.Image) -> list[float]:
    rgba = _to_rgba(img)
    row = rgba.split()[3].resize((1, rgba.height))
    return [v / 1.0 for v in row.tobytes()]


def _divisors(n: int, lo: int = MIN_TILE, hi: int = MAX_TILE) -> list[int]:
    out = []
    for i in range(lo, hi + 1):
        if n % i == 0:
            out.append(i)
    return out


def _cell_empty_ratio(img: Image.Image, tw: int, th: int, max_sample: int = 12) -> float:
    """Fraction of sampled cells that are (near-)fully transparent."""
    rgba = _to_rgba(img)
    alpha = rgba.split()[3]
    cols = rgba.width // tw
    rows = rgba.height // th
    total = 0
    empty = 0
    sampled_rows = 0
    for r in range(rows):
        if sampled_rows >= max_sample:
            break
        sampled_rows += 1
        for c in range(min(cols, max_sample)):
            box = (c * tw, r * th, c * tw + tw, r * th + th)
            cell = alpha.crop(box)
            mean = sum(cell.tobytes()) / (cell.width * cell.height)
            total += 1
            if mean < 8:
                empty += 1
    return empty / total if total else 1.0


# --------------------------------------------------------------------------- #
# meta
# --------------------------------------------------------------------------- #
def cmd_meta(args: argparse.Namespace) -> int:
    img = _open(args.image)
    out = {
        "file": os.path.basename(args.image),
        "width": img.width,
        "height": img.height,
        "has_alpha": _has_alpha(img),
        "mode": img.mode,
        "format": img.format,
    }
    print(json.dumps(out, ensure_ascii=False))
    return 0


# --------------------------------------------------------------------------- #
# grid detection
# --------------------------------------------------------------------------- #
def _score_candidate(img: Image.Image, tw: int, th: int) -> dict:
    cols = img.width // tw
    rows = img.height // th
    score = 0.0
    reasons = []

    # square tiles preferred
    if tw == th:
        score += 2.0
        reasons.append("square")
    elif max(tw, th) / min(tw, th) <= 2:
        score += 1.0
        reasons.append("near-square")

    # common size preferred
    if tw in COMMON_SIZES:
        score += 0.5
    if th in COMMON_SIZES:
        score += 0.5

    # gutter match (alpha images only)
    if _has_alpha(img):
        col_means = _column_alpha_means(img)
        row_means = _row_alpha_means(img)
        # check seam columns (multiples of tw) are emptier than average
        seam_alpha = []
        for k in range(1, cols):
            x = k * tw
            if x < len(col_means):
                seam_alpha.append(col_means[x - 1] + col_means[x])
        nonseam = [v for i, v in enumerate(col_means) if i % tw != 0]
        if seam_alpha and nonseam:
            seam_mean = sum(seam_alpha) / len(seam_alpha) / 2
            nonseam_mean = sum(nonseam) / len(nonseam)
            if seam_mean < nonseam_mean * 0.5:
                score += 2.0
                reasons.append("col-gutter")

        seam_alpha = []
        for k in range(1, rows):
            y = k * th
            if y < len(row_means):
                seam_alpha.append(row_means[y - 1] + row_means[y])
        nonseam = [v for i, v in enumerate(row_means) if i % th != 0]
        if seam_alpha and nonseam:
            seam_mean = sum(seam_alpha) / len(seam_alpha) / 2
            nonseam_mean = sum(nonseam) / len(nonseam)
            if seam_mean < nonseam_mean * 0.5:
                score += 2.0
                reasons.append("row-gutter")

    # content sanity: few fully-empty cells
    empty_ratio = _cell_empty_ratio(img, tw, th)
    if empty_ratio < 0.1:
        score += 1.0
        reasons.append("content-full")
    elif empty_ratio > 0.5:
        score -= 2.0
        reasons.append("many-empty")

    confidence = "high" if score >= 4 else ("medium" if score >= 2 else "low")
    return {
        "tile_w": tw,
        "tile_h": th,
        "cols": cols,
        "rows": rows,
        "score": round(score, 2),
        "confidence": confidence,
        "reasons": reasons,
        "empty_ratio": round(empty_ratio, 3),
    }


def _detect_grid(img: Image.Image) -> list[dict]:
    cands = []
    seen = set()
    for tw in _divisors(img.width):
        for th in _divisors(img.height):
            # keep reasonable aspect ratios; allow single-row strips
            if tw == th or (img.height <= MAX_TILE and th == img.height) or \
               (img.width <= MAX_TILE and tw == img.width) or \
               max(tw, th) / min(tw, th) <= 3:
                key = (tw, th)
                if key not in seen:
                    seen.add(key)
                    cands.append(_score_candidate(img, tw, th))
    cands.sort(key=lambda c: c["score"], reverse=True)
    return cands


def _parse_hint(hint: str) -> tuple[int, int] | None:
    """Parse 'RxC' or 'WxH' style hints. Returns (a, b) or None."""
    if not hint:
        return None
    hint = hint.lower().replace(" ", "")
    if "x" not in hint:
        return None
    try:
        a, b = hint.split("x", 1)
        return int(a), int(b)
    except ValueError:
        return None


def cmd_grid(args: argparse.Namespace) -> int:
    img = _open(args.image)
    w, h = img.width, img.height

    # enumerate all candidates first
    ranked = _detect_grid(img)

    hint_target = None
    method = "auto"
    conflict = False

    hint = args.hint
    tile_hint = args.tile
    if tile_hint:
        parsed = _parse_hint(tile_hint)
        if parsed:
            tw, th = parsed
            hint_target = {"tile_w": tw, "tile_h": th, "cols": w // tw, "rows": h // th}
            method = "tile-hint"
    if hint:
        parsed = _parse_hint(hint)
        if parsed:
            a, b = parsed  # ambiguous: could be RxC or WxH
            # Interpretation 1: tile size WxH (a=tile_w, b=tile_h)
            if a >= MIN_TILE and b >= MIN_TILE and w % a == 0 and h % b == 0:
                hint_target = {"tile_w": a, "tile_h": b, "cols": w // a, "rows": h // b}
                method = "hint-verified"
            # Interpretation 2: grid RxC (a=rows, b=cols) - validate derived tile size
            elif a >= 1 and b >= 1 and w % b == 0 and h % a == 0 \
                    and (w // b) >= MIN_TILE and (h // a) >= MIN_TILE:
                hint_target = {"tile_w": w // b, "tile_h": h // a, "cols": b, "rows": a}
                method = "hint-verified"
            else:
                conflict = True

    # pick best: if hint cleanly verified, use it; else use top-ranked auto
    best = ranked[0] if ranked else None
    candidates = ranked[:5]

    if hint_target:
        # find matching candidate to pull its score/confidence
        match = next(
            (c for c in ranked if c["tile_w"] == hint_target["tile_w"]
             and c["tile_h"] == hint_target["tile_h"]),
            None,
        )
        if match:
            best = match
            best["method"] = method
        else:
            # hint divides cleanly but wasn't in auto-ranked (maybe filtered) - trust math
            best = {
                **hint_target,
                "score": 0,
                "confidence": "medium" if not conflict else "low",
                "reasons": ["hint-divides-cleanly"],
                "empty_ratio": _cell_empty_ratio(img, hint_target["tile_w"], hint_target["tile_h"]),
                "method": method,
            }

    if best is None:
        print(json.dumps({
            "file": os.path.basename(args.image),
            "width": w, "height": h,
            "error": "no valid tile grid (image too small or no divisor >= %d)" % MIN_TILE,
            "candidates": [],
        }, ensure_ascii=False))
        return 1

    best.setdefault("method", method if hint_target else "auto")
    out = {
        "file": os.path.basename(args.image),
        "width": w,
        "height": h,
        "rows": best["rows"],
        "cols": best["cols"],
        "tile_w": best["tile_w"],
        "tile_h": best["tile_h"],
        "confidence": best["confidence"],
        "method": best["method"],
        "conflict": conflict,
        "best": best,
        "candidates": candidates,
    }
    print(json.dumps(out, ensure_ascii=False))
    return 0


# --------------------------------------------------------------------------- #
# split
# --------------------------------------------------------------------------- #
def _load_font(size: int) -> ImageFont.ImageFont:
    for candidate in (
        "arial.ttf",
        "C:\\Windows\\Fonts\\arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ):
        try:
            return ImageFont.truetype(candidate, size)
        except (OSError, IOError):
            continue
    return ImageFont.load_default()


def cmd_split(args: argparse.Namespace) -> int:
    img = _open(args.image)
    parsed = _parse_hint(args.grid)
    if not parsed:
        print(json.dumps({"error": "invalid --grid RxC"}))
        return 2
    rows, cols = parsed
    if rows <= 0 or cols <= 0:
        print(json.dumps({"error": "rows/cols must be positive"}))
        return 2
    tw = img.width // cols
    th = img.height // rows
    if tw == 0 or th == 0:
        print(json.dumps({"error": "grid larger than image"}))
        return 2

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    tiles = []
    for r in range(rows):
        for c in range(cols):
            box = (c * tw, r * th, c * tw + tw, r * th + th)
            cell = img.crop(box)
            name = "tile_r%02d_c%02d.png" % (r, c)
            cell.save(out_dir / name)
            tiles.append({"row": r, "col": c, "file": name})

    # contact sheet with row/col labels
    label_size = max(14, min(28, th // 3))
    font = _load_font(label_size)
    left_margin = label_size * 4 + 8
    top_margin = label_size + 8
    canvas = Image.new(
        "RGBA",
        (img.width + left_margin, img.height + top_margin),
        (30, 30, 30, 255),
    )
    canvas.paste(img, (left_margin, top_margin))
    draw = ImageDraw.Draw(canvas)
    # row labels (left)
    for r in range(rows):
        y = top_margin + r * th + th // 2
        draw.text((4, y - label_size // 2), "r%02d" % r, fill=(255, 255, 255, 255), font=font)
    # column labels (top), rotated number every column if room else every Nth
    label_every = max(1, (label_size * 3) // max(1, tw))
    for c in range(cols):
        if c % label_every != 0 and c != cols - 1:
            continue
        x = left_margin + c * tw + tw // 2
        draw.text((x - label_size, 2), "c%02d" % c, fill=(255, 255, 255, 255), font=font)
    # seam lines (subtle)
    for c in range(1, cols):
        x = left_margin + c * tw
        draw.line([(x, top_margin), (x, canvas.height)], fill=(80, 80, 80, 255))
    for r in range(1, rows):
        y = top_margin + r * th
        draw.line([(left_margin, y), (canvas.width, y)], fill=(80, 80, 80, 255))

    contact_name = "contact_sheet.png"
    canvas.save(out_dir / contact_name)

    out = {
        "tile_dir": str(out_dir),
        "tile_count": len(tiles),
        "contact_sheet": contact_name,
        "tile_w": tw,
        "tile_h": th,
        "rows": rows,
        "cols": cols,
        "tiles": tiles,
    }
    print(json.dumps(out, ensure_ascii=False))
    return 0


# --------------------------------------------------------------------------- #
# phash
# --------------------------------------------------------------------------- #
def _ahash(img: Image.Image, size: int = 8) -> int:
    # For RGBA, crop to the content bounding box first so the hash reflects the
    # sprite itself rather than its (often large) transparent padding. Then
    # composite onto white so residual transparency does not skew the average.
    # NOTE: aHash reliably finds DUPLICATE / near-identical tiles; it is a weak
    # signal for semantic "same character, different pose" grouping (use the AI
    # vision path / ui_diff_check for that).
    work = _to_rgba(img) if _has_alpha(img) else img.convert("RGBA")
    if _has_alpha(img):
        alpha = work.split()[3]
        bbox = alpha.getbbox()
        if bbox:
            work = work.crop(bbox)
        bg = Image.new("RGBA", work.size, (255, 255, 255, 255))
        bg.paste(work, mask=work.split()[3])
        work = bg
    gray = work.convert("L").resize((size, size))
    pixels = list(gray.tobytes())
    avg = sum(pixels) / len(pixels)
    bits = 0
    for p in pixels:
        bits = (bits << 1) | (1 if p >= avg else 0)
    return bits


def _hamming(a: int, b: int) -> int:
    return bin(a ^ b).count("1")


def cmd_phash(args: argparse.Namespace) -> int:
    d = Path(args.dir)
    files = sorted(d.glob("tile_r*_c*.png"))
    if not files:
        print(json.dumps({"error": "no tile_*.png found", "dir": str(d)}))
        return 1
    hashes = []
    for f in files:
        img = _open(str(f))
        hashes.append((f.name, _ahash(img)))
    threshold = args.threshold
    pairs = []
    for i in range(len(hashes)):
        for j in range(i + 1, len(hashes)):
            h = _hamming(hashes[i][1], hashes[j][1])
            if h <= threshold:
                pairs.append({"a": hashes[i][0], "b": hashes[j][0], "hamming": h, "similar": True})
    pairs.sort(key=lambda p: p["hamming"])
    out = {
        "tile_count": len(hashes),
        "threshold": threshold,
        "similar_pairs": pairs,
        "all_hashes": [{"file": n, "hash": hex(h)} for n, h in hashes],
    }
    print(json.dumps(out, ensure_ascii=False))
    return 0


# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #
def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)

    pm = sub.add_parser("meta", help="precise size/alpha/format")
    pm.add_argument("image")
    pm.set_defaults(func=cmd_meta)

    pg = sub.add_parser("grid", help="detect or verify tile grid")
    pg.add_argument("image")
    pg.add_argument("--hint", default=None, help='AI-provided hint, e.g. "5x10" (RxC or WxH)')
    pg.add_argument("--tile", default=None, help='tile size hint, e.g. "64x64"')
    pg.set_defaults(func=cmd_grid)

    ps = sub.add_parser("split", help="slice tiles + labeled contact sheet")
    ps.add_argument("image")
    ps.add_argument("--grid", required=True, help='grid as "RxC", e.g. "1x60"')
    ps.add_argument("--out", required=True, help="output directory")
    ps.set_defaults(func=cmd_split)

    pp = sub.add_parser("phash", help="perceptual-hash similarity matrix")
    pp.add_argument("dir", help="directory of tile_*.png")
    pp.add_argument("--threshold", type=int, default=10, help="hamming threshold for 'similar'")
    pp.set_defaults(func=cmd_phash)

    args = p.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
