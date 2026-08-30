"""Render static/favicon.svg (gold "$") into all platform app icons.

Reuses a single high-res master render (1024) and downscales for:
- iOS AppIcon.appiconset (15 PNGs + Contents.json already in place)
- Android mipmap-{m,h,xh,xxh,xxxh}dpi (ic_launcher.png)
- Windows app_icon.ico (multi-size embedded)

Only depends on Pillow (already installed).
"""
from __future__ import annotations

import math
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SVG_PATH = ROOT / "static" / "favicon.svg"

IOS_ICON_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
ANDROID_RES = ROOT / "android" / "app" / "src" / "main" / "res"
WIN_ICO = ROOT / "windows" / "runner" / "resources" / "app_icon.ico"

# SVG gradient stops (top-left -> bottom-right diagonal)
GRADIENT_STOPS = [
    (0.00, (255, 224, 102)),  # #FFE066
    (0.40, (255, 215,   0)),  # #FFD700
    (0.80, (245, 166,  35)),  # #F5A623
    (1.00, (212, 137,  10)),  # #D4890A
]

# Background gradient stops (warm cream, opaque — required by App Store)
BG_STOPS = [
    (0.00, (255, 251, 230)),  # #FFFBE6
    (1.00, (255, 244, 194)),  # #FFF4C2
]

FONT_CANDIDATES = [
    r"C:\Windows\Fonts\ariblk.ttf",   # Arial Black
    r"C:\Windows\Fonts\impact.ttf",    # Impact
    r"C:\Windows\Fonts\segoeuib.ttf",  # Segoe UI Bold
    r"C:\Windows\Fonts\segoeui.ttf",   # Segoe UI
]


def lerp(a, b, t):
    return a + (b - a) * t


def gradient_color(u: float, v: float) -> tuple[int, int, int, int]:
    """Diagonal gradient (top-left -> bottom-right) sampled at (u, v) in [0,1]."""
    t = (u + v) * 0.5  # diagonal position
    t = max(0.0, min(1.0, t))
    for i in range(len(GRADIENT_STOPS) - 1):
        p0, c0 = GRADIENT_STOPS[i]
        p1, c1 = GRADIENT_STOPS[i + 1]
        if p0 <= t <= p1:
            local = (t - p0) / (p1 - p0) if p1 > p0 else 0
            return (
                int(lerp(c0[0], c1[0], local)),
                int(lerp(c0[1], c1[1], local)),
                int(lerp(c0[2], c1[2], local)),
                255,
            )
    c = GRADIENT_STOPS[-1][1]
    return (c[0], c[1], c[2], 255)


def bg_color(u: float, v: float) -> tuple[int, int, int, int]:
    """Background diagonal gradient sampled at (u, v) in [0,1]."""
    t = (u + v) * 0.5
    t = max(0.0, min(1.0, t))
    for i in range(len(BG_STOPS) - 1):
        p0, c0 = BG_STOPS[i]
        p1, c1 = BG_STOPS[i + 1]
        if p0 <= t <= p1:
            local = (t - p0) / (p1 - p0) if p1 > p0 else 0
            return (
                int(lerp(c0[0], c1[0], local)),
                int(lerp(c0[1], c1[1], local)),
                int(lerp(c0[2], c1[2], local)),
                255,
            )
    c = BG_STOPS[-1][1]
    return (c[0], c[1], c[2], 255)


def load_font(size: int) -> ImageFont.FreeTypeFont:
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()


def render_master(size: int = 1024) -> Image.Image:
    """Render the gold '$' on a warm cream background, matching favicon.svg.

    Background is opaque (alpha=255) to satisfy iOS App Store icon requirements
    (transparent icons are rejected).
    """
    # SVG: viewBox 0 0 100 100, text x=50 y=76 font-size=80 weight=900 anchor=middle.
    # So at size N: font-size = 80/100 * N = 0.8N; baseline_y = 76/100 * N = 0.76N.
    font_size = int(size * 0.80)
    baseline_y = int(size * 0.76)
    font = load_font(font_size)

    # 1. Build a mask of the "$" character, centered horizontally on baseline.
    mask = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(mask)
    # Anchor "ms" = middle baseline (Pillow >= 8). Falls back gracefully.
    try:
        md.text((size // 2, baseline_y), "$", font=font, fill=255, anchor="ms")
    except Exception:
        # Fallback: measure and center manually
        bbox = md.textbbox((0, 0), "$", font=font)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        md.text(((size - w) // 2 - bbox[0], baseline_y - h), "$", font=font, fill=255)

    # 2. Drop shadow: offset mask, blur, darken.
    shadow_offset = max(2, int(size * 0.012))   # dx~1 @ 100 -> ~12 @ 1024
    shadow_blur = max(3, int(size * 0.020))      # stdDev=2 @ 100 -> ~20 @ 1024
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_alpha = mask.filter(ImageFilter.GaussianBlur(shadow_blur))
    # Shift shadow down-right
    shifted = Image.new("L", (size, size), 0)
    shifted.paste(shadow_alpha, (shadow_offset, shadow_offset * 2))
    sd = ImageDraw.Draw(shadow)
    sd.bitmap((0, 0), shifted, fill=(0, 0, 0, int(255 * 0.18)))

    # 3. Gold gradient fill using the mask.
    # Build gradient by sampling per-pixel — O(N^2) but only done once.
    grad = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gp = grad.load()
    for y in range(size):
        for x in range(size):
            gp[x, y] = gradient_color(x / size, y / size)
    # Apply mask: keep gradient alpha where mask is, scaled by mask value.
    grad.putalpha(mask)

    # 4. Opaque warm cream background (App Store requires non-transparent icons).
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bp = bg.load()
    for y in range(size):
        for x in range(size):
            bp[x, y] = bg_color(x / size, y / size)

    # 5. Compose: background -> shadow -> gold $ on top.
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out = Image.alpha_composite(out, bg)
    out = Image.alpha_composite(out, shadow)
    out = Image.alpha_composite(out, grad)
    return out


def save_scaled(master: Image.Image, size: int, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if master.size[0] == size:
        img = master
    else:
        img = master.resize((size, size), Image.LANCZOS)
    img.save(path, "PNG")


def gen_ios(master: Image.Image) -> None:
    # Pixel sizes referenced by Contents.json (we already have one)
    sizes_files = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for fname, px in sizes_files.items():
        save_scaled(master, px, IOS_ICON_DIR / fname)
        print(f"  iOS  {fname:<32} {px}px")


def gen_android(master: Image.Image) -> None:
    # Standard Android launcher icon sizes (background-less; adaptive icon foreground can be added later).
    sizes = {
        "mipmap-mdpi":   48,
        "mipmap-hdpi":   72,
        "mipmap-xhdpi":  96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, px in sizes.items():
        save_scaled(master, px, ANDROID_RES / folder / "ic_launcher.png")
        # Round icon (Android shows circular icon on some launchers)
        round_img = make_round(master.resize((px, px), Image.LANCZOS))
        round_path = ANDROID_RES / folder / "ic_launcher_round.png"
        round_path.parent.mkdir(parents=True, exist_ok=True)
        round_img.save(round_path, "PNG")
        print(f"  Droid {folder:<16} {px}px")


def make_round(img: Image.Image) -> Image.Image:
    w, h = img.size
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, w - 1, h - 1), fill=255)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def gen_windows(master: Image.Image) -> None:
    # Multi-size ICO: PIL resizes the master for each requested size automatically.
    sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    WIN_ICO.parent.mkdir(parents=True, exist_ok=True)
    master.save(WIN_ICO, format="ICO", sizes=sizes)
    print(f"  Win  {WIN_ICO.relative_to(ROOT)}  sizes={sizes}")


def main() -> int:
    if not SVG_PATH.exists():
        print(f"ERROR: source SVG not found at {SVG_PATH}")
        return 1

    print(f"Rendering master 1024 from {SVG_PATH.name} ...")
    master = render_master(1024)

    # Save a copy of the master PNG next to the SVG for reference
    master_png = SVG_PATH.with_name("favicon-1024.png")
    master.save(master_png, "PNG")
    print(f"Saved master -> {master_png.relative_to(ROOT)}")

    print("\n[iOS]")
    gen_ios(master)

    print("\n[Android]")
    gen_android(master)

    print("\n[Windows]")
    gen_windows(master)

    print("\nDone.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
