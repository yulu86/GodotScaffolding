"""Sample pixels from a Godot web screenshot and compare against expected hex colors.

Usage:
    python <skill>/scripts/sample_pixels.py <screenshot.png> [--expect name=#hex ...]

Examples:
    # Just sample key points and print hex
    python <skill>/scripts/sample_pixels.py .tmp/S01-battle.png

    # Sample + verify against expected colors (exit 1 on mismatch)
    python <skill>/scripts/sample_pixels.py .tmp/S01-battle.png \
        --expect felt=#1a5236 bg=#15101e neon=#ff2e88

Samples 9 points (corners + center + mid-edges) by default and prints hex.
With --expect, also checks if ANY sampled point matches each expected color.
"""
import sys
from PIL import Image


def to_hex(rgb: tuple) -> str:
    return "#{:02x}{:02x}{:02x}".format(*rgb[:3])


def sample_points(img: Image.Image) -> dict:
    w, h = img.size
    points = {
        "top_left":     (w // 4, h // 4),
        "top_center":   (w // 2, h // 4),
        "top_right":    (3 * w // 4, h // 4),
        "center":       (w // 2, h // 2),
        "left":         (w // 4, h // 2),
        "right":        (3 * w // 4, h // 2),
        "bot_left":     (w // 4, 3 * h // 4),
        "bot_center":   (w // 2, 3 * h // 4),
        "bot_right":    (3 * w // 4, 3 * h // 4),
    }
    return {name: to_hex(img.getpixel(xy)) for name, xy in points.items()}


def parse_expect(args: list) -> dict:
    """Parse --expect name=#hex pairs into {name: '#hex'}."""
    expect = {}
    for arg in args:
        if arg.startswith("--expect"):
            continue
        if "=" in arg and arg.split("=", 1)[1].startswith("#"):
            name, hexval = arg.split("=", 1)
            expect[name] = hexval.lower()
    return expect


def main():
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        return

    path = args[0]
    expect_raw = [a for a in args[1:] if a.startswith("--expect") or ("=" in a and a.split("=", 1)[1].startswith("#"))]
    expect = parse_expect(expect_raw)

    img = Image.open(path)
    samples = sample_points(img)

    print(f"Image: {path} ({img.size[0]}x{img.size[1]})")
    print("Sampled pixels:")
    for name, hexval in samples.items():
        print(f"  {name:12s}: {hexval}")

    if expect:
        print("\nExpected color check:")
        all_present = True
        sampled_set = set(samples.values())
        for name, expected in expect.items():
            found = expected in sampled_set
            status = "FOUND" if found else "MISSING"
            print(f"  {name:12s}: {expected} -> {status}")
            if not found:
                all_present = False
        if not all_present:
            print("\nSome expected colors not found in sampled points.")
            print("Tip: the color may be at a location not covered by the 9 default sample points.")
            sys.exit(1)
        else:
            print("\nAll expected colors found. OK")


if __name__ == "__main__":
    main()
