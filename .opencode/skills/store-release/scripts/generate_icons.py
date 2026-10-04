#!/usr/bin/env python3
"""Generate launcher icons + Play Store assets from a brand.json file.

Usage:
    python3 generate_icons.py <app-root> [--brand <path>] [--play-only]

Reads <app-root>/store/brand.json (or --brand path) and writes:
    <app-root>/android/app/src/main/res/mipmap-*/ic_launcher.png
    <app-root>/android/app/src/main/res/mipmap-*/ic_launcher_foreground.png
    <app-root>/android/app/src/main/res/mipmap-*/ic_launcher_round.png
    <app-root>/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
    <app-root>/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
    <app-root>/android/app/src/main/res/values/ic_launcher_background.xml
    <app-root>/store/assets/icon_512.png          (Play listing icon, 512x512, opaque)
    <app-root>/store/assets/feature_graphic_1024x500.png
    <app-root>/store/assets/preview.png           (contact-sheet preview, not uploaded)

brand.json schema:
    {
      "app_name": "Pas Foto",
      "package_id": "com.appnovasi.pasfoto",
      "monogram": "PF",
      "background": "#2563EB",
      "background_end": "#0EA5E9",
      "foreground": "#FFFFFF",
      "wordmark": true,
      "icon_note": "optional free-text, copied into store/icon-notes.md"
    }

Design rules enforced (Google Play / Android):
  - 512x512 PNG, 32-bit, fully opaque, no alpha, no rounded corners of its own
    (Play applies its own mask/shadow).
  - Adaptive icon foreground canvas is 108dp; only the centre 72dp is guaranteed
    visible, so the monogram is drawn inside that safe zone.
  - Legacy density buckets: mdpi 48, hdpi 72, xhdpi 96, xxhdpi 144, xxxhdpi 192.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:  # pragma: no cover
    sys.exit("Pillow is required: python3 -m pip install Pillow")

LAUNCHER_DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}
ADAPTIVE_FACTOR = 108 / 48  # adaptive foreground canvas is 2.25x the legacy size
SAFE_ZONE = 2 / 3  # centre 72dp of 108dp is guaranteed visible

FONT_CANDIDATES = [
    "assets/fonts/Poppins-Bold.ttf",
    "assets/fonts/Poppins-SemiBold.ttf",
    "assets/fonts/Inter-SemiBold.ttf",
    "assets/fonts/Manrope-Variable.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/Library/Fonts/Arial Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
]


def resolve_font(workspace: Path, name: str | None) -> str | None:
    if name:
        p = Path(name)
        if p.is_file():
            return str(p)
    env = os.environ.get("STORE_ICON_FONT")
    if env and Path(env).is_file():
        return env
    roots = [workspace, Path.cwd()]
    for root in roots:
        for rel in FONT_CANDIDATES:
            p = root / rel
            if p.is_file():
                return str(p)
    for rel in FONT_CANDIDATES:
        p = Path(rel)
        if p.is_file():
            return str(p)
    return None


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    v = value.strip().lstrip("#")
    if len(v) == 3:
        v = "".join(c * 2 for c in v)
    if len(v) != 6:
        raise ValueError(f"invalid hex colour: {value}")
    return tuple(int(v[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def load_brand(path: Path) -> dict:
    if not path.is_file():
        sys.exit(f"brand.json not found: {path}")
    brand = json.loads(path.read_text(encoding="utf-8"))
    for required in ("app_name", "monogram", "background"):
        if not brand.get(required):
            sys.exit(f"brand.json missing required field: {required}")
    brand.setdefault("background_end", brand["background"])
    brand.setdefault("foreground", "#FFFFFF")
    brand.setdefault("wordmark", True)
    return brand


def vertical_gradient(size: int, top: str, bottom: str) -> Image.Image:
    img = Image.new("RGB", (size, size), hex_to_rgb(top))
    draw = ImageDraw.Draw(img)
    start = hex_to_rgb(top)
    end = hex_to_rgb(bottom)
    for y in range(size):
        t = y / max(size - 1, 1)
        draw.line(
            [(0, y), (size, y)],
            fill=tuple(int(round(start[i] + (end[i] - start[i]) * t)) for i in range(3)),
        )
    return img


def fit_font(font_path: str | None, target_h: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    if font_path:
        try:
            return ImageFont.truetype(font_path, target_h)
        except OSError:
            pass
    return ImageFont.load_default()


def draw_monogram(
    canvas: Image.Image,
    text: str,
    font_path: str | None,
    height_ratio: float,
    tracking: float = 0.0,
):
    size = canvas.size[0]
    target_h = max(int(size * height_ratio), 8)
    font = fit_font(font_path, target_h)
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    if not font_path:
        draw.text((size / 2, size / 2), text, fill=(255, 255, 255, 255), anchor="mm")
        canvas.alpha_composite(layer)
        return
    advance = 0.0
    glyphs = []
    for ch in text:
        left, top, right, bottom = font.getbbox(ch)
        glyphs.append((ch, font.getlength(ch), bottom - top))
        advance += font.getlength(ch) + tracking * target_h
    advance -= tracking * target_h
    total_w = advance
    start_x = (size - total_w) / 2
    max_h = max(g[2] for g in glyphs) or target_h
    y_offset = (size - max_h * 0.78) / 2  # optical centring
    for ch, width, glyph_h in glyphs:
        left, top, right, bottom = font.getbbox(ch)
        y = y_offset - top - (max_h - glyph_h) / 2
        draw.text((start_x, y), ch, font=font, fill=(255, 255, 255, 255))
        start_x += width + tracking * target_h
    canvas.alpha_composite(layer)


def legacy_icon(size: int, brand: dict, font_path: str | None) -> Image.Image:
    base = vertical_gradient(size, brand["background"], brand["background_end"]).convert("RGBA")
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size - 1, size - 1], radius=int(size * 0.22), fill=255
    )
    base.putalpha(mask)
    draw_monogram(base, brand["monogram"], font_path, height_ratio=0.46, tracking=0.02)
    return base


def adaptive_foreground(size: int, brand: dict, font_path: str | None) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # keep the monogram well inside the 72dp safe zone of the 108dp canvas
    draw_monogram(canvas, brand["monogram"], font_path, height_ratio=0.30 * SAFE_ZONE, tracking=0.02)
    return canvas


def round_icon(icon: Image.Image, size: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, size - 1, size - 1], fill=255)
    out = icon.copy()
    out.putalpha(mask)
    return out


def play_icon_512(brand: dict, font_path: str | None) -> Image.Image:
    size = 512
    base = vertical_gradient(size, brand["background"], brand["background_end"]).convert("RGBA")
    draw_monogram(base, brand["monogram"], font_path, height_ratio=0.46, tracking=0.02)
    flat = Image.new("RGB", base.size, (0, 0, 0))
    flat.paste(base, (0, 0), base)
    return flat  # opaque RGB: Play rejects alpha in the listing icon


def feature_graphic(brand: dict, font_path: str | None) -> Image.Image:
    w, h = 1024, 500
    start = hex_to_rgb(brand["background"])
    end = hex_to_rgb(brand["background_end"])
    img = Image.new("RGB", (w, h))
    draw = ImageDraw.Draw(img)
    for x in range(w):
        t = x / (w - 1)
        draw.line(
            [(x, 0), (x, h)],
            fill=tuple(int(round(start[i] + (end[i] - start[i]) * t)) for i in range(3)),
        )
    if brand.get("wordmark", True) and font_path:
        label = brand["app_name"]
        name_font = fit_font(font_path, 72)
        name_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        ld = ImageDraw.Draw(name_layer)
        bbox = ld.textbbox((0, 0), label, font=name_font)
        text_w = bbox[2] - bbox[0]
        ld.text(((w - text_w) / 2 - bbox[0], h / 2 - 26), label, font=name_font, fill=(255, 255, 255, 255))
        img = Image.alpha_composite(img.convert("RGBA"), name_layer).convert("RGB")
    logo = play_icon_512(brand, font_path).resize((190, 190), Image.LANCZOS)
    if brand.get("wordmark", True) and font_path:
        img.paste(logo, (w // 2 - 95, int(h / 2) - 150))
    else:
        img.paste(logo, (w // 2 - 95, h // 2 - 95))
    return img


def adaptive_xml(background_ref: str) -> str:
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        f"    <background android:drawable=\"{background_ref}\" />\n"
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_foreground" />\n'
        "</adaptive-icon>\n"
    )


def write(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if isinstance(data, Image.Image):
        data.save(path, format="PNG", optimize=True)
    else:
        path.write_text(data, encoding="utf-8")
    print(f"  wrote {path}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("app_root", help="path to the Flutter app root (contains android/, store/)")
    ap.add_argument("--brand", help="explicit path to brand.json")
    ap.add_argument("--font", help="explicit TTF path for the monogram")
    ap.add_argument("--play-only", action="store_true", help="only write store/assets/")
    args = ap.parse_args()

    app_root = Path(args.app_root).resolve()
    brand_path = Path(args.brand).resolve() if args.brand else app_root / "store" / "brand.json"
    brand = load_brand(brand_path)
    font_path = resolve_font(app_root, args.font)
    if not font_path:
        print(
            "WARNING: no TrueType font found, monogram quality will be poor. "
            "Set STORE_ICON_FONT=/path/to/font.ttf",
            file=sys.stderr,
        )
    print(f"brand: {brand_path}")
    print(f"font:  {font_path or '(Pillow default)'}")

    assets = app_root / "store" / "assets"
    print("Play Store assets:")
    write(assets / "icon_512.png", play_icon_512(brand, font_path))
    write(assets / "feature_graphic_1024x500.png", feature_graphic(brand, font_path))

    if not args.play_only:
        res = app_root / "android" / "app" / "src" / "main" / "res"
        print("Launcher icons (legacy densities):")
        for density, size in LAUNCHER_DENSITIES.items():
            folder = res / f"mipmap-{density}"
            icon = legacy_icon(size, brand, font_path)
            write(folder / "ic_launcher.png", icon)
            write(folder / "ic_launcher_round.png", round_icon(icon, size))
            fg_size = int(size * ADAPTIVE_FACTOR)
            write(folder / "ic_launcher_foreground.png", adaptive_foreground(fg_size, brand, font_path))
        print("Adaptive icon XML:")
        write(res / "mipmap-anydpi-v26" / "ic_launcher.xml", adaptive_xml("@color/ic_launcher_background"))
        write(
            res / "mipmap-anydpi-v26" / "ic_launcher_round.xml",
            adaptive_xml("@color/ic_launcher_background"),
        )
        write(
            res / "values" / "ic_launcher_background.xml",
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            f'    <color name="ic_launcher_background">{brand["background"]}</color>\n'
            "</resources>\n",
        )

    if brand.get("icon_note"):
        write(assets / "icon-notes.md", f"# Icon notes\n\n{brand['icon_note']}\n")
    print("done")


if __name__ == "__main__":
    main()