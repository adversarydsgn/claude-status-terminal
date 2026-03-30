#!/usr/bin/env python3
"""Generate Claude Status app icon — diagonal split: claude.ai / Claude Code."""

from PIL import Image, ImageDraw, ImageFont
import subprocess, tempfile, os, math

SIZES = [16, 32, 64, 128, 256, 512, 1024]
OUT_DIR = os.path.dirname(os.path.abspath(__file__))
FONTS_DIR = os.path.join(os.path.dirname(OUT_DIR), "_fonts")

GREEN = (118, 173, 42, 255)       # #76AD2A — operational
DARK_BG = (20, 20, 32, 245)       # dark navy
DARK_TOP = (28, 28, 48, 245)      # slightly lighter for top half
DARK_BOT = (16, 16, 28, 245)      # slightly darker for bottom half
BORDER = (55, 55, 80, 200)
WHITE = (240, 240, 250, 255)
DIM_WHITE = (180, 180, 200, 180)
DIVIDER = (70, 70, 100, 160)


def get_font(size_px, bold=False):
    """Load Inter or fall back to system fonts."""
    paths = [
        os.path.join(FONTS_DIR, "Inter", "static", "Inter_18pt-Bold.ttf" if bold else "Inter_18pt-SemiBold.ttf"),
        os.path.join(FONTS_DIR, "Inter", "static", "Inter_18pt-SemiBold.ttf"),
        os.path.join(FONTS_DIR, "Inter", "Inter-VariableFont_opsz,wght.ttf"),
        "/System/Library/Fonts/SFCompact.ttf",
        "/System/Library/Fonts/HelveticaNeue.ttc",
    ]
    for p in paths:
        try:
            return ImageFont.truetype(p, size_px)
        except (OSError, IOError):
            continue
    return ImageFont.load_default()


def draw_icon(size):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    pad = size * 0.06
    r = size * 0.18
    inner = pad
    outer = size - pad

    # ── Background ──────────────────────────────────────
    draw.rounded_rectangle([inner, inner, outer, outer], radius=r, fill=DARK_BG)

    # ── Diagonal split — draw two triangles ─────────────
    # Top-left triangle (claude.ai)
    mask_top = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    dt = ImageDraw.Draw(mask_top)
    dt.polygon([(inner, inner), (outer, inner), (inner, outer)], fill=DARK_TOP)

    # Bottom-right triangle (Claude Code)
    mask_bot = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    db = ImageDraw.Draw(mask_bot)
    db.polygon([(outer, inner), (outer, outer), (inner, outer)], fill=DARK_BOT)

    # Composite with rounded rect mask
    bg_mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(bg_mask).rounded_rectangle([inner, inner, outer, outer], radius=r, fill=255)

    top_final = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    top_final.paste(mask_top, mask=bg_mask)
    bot_final = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    bot_final.paste(mask_bot, mask=bg_mask)

    img = Image.alpha_composite(img, top_final)
    img = Image.alpha_composite(img, bot_final)
    draw = ImageDraw.Draw(img)

    # ── Diagonal divider line ───────────────────────────
    line_w = max(1, size // 100)
    # Draw from top-right to bottom-left with slight offset for clarity
    draw.line([(outer - r/3, inner + r/3), (inner + r/3, outer - r/3)],
              fill=DIVIDER, width=max(1, size // 80))

    # ── Border ──────────────────────────────────────────
    draw.rounded_rectangle([inner, inner, outer, outer], radius=r,
                           outline=BORDER, width=max(1, size // 100))

    # ── Content ─────────────────────────────────────────
    if size >= 64:
        # Top-left area: claude.ai
        dot_r = size * 0.055
        ai_dot_x = inner + size * 0.22
        ai_dot_y = inner + size * 0.28

        # Green dot
        draw.ellipse([ai_dot_x - dot_r, ai_dot_y - dot_r,
                      ai_dot_x + dot_r, ai_dot_y + dot_r], fill=GREEN)

        # "claude.ai" text
        if size >= 128:
            font_lg = get_font(max(size // 11, 10), bold=True)
            font_sm = get_font(max(size // 16, 8))
            draw.text((ai_dot_x + dot_r + size * 0.04, ai_dot_y - size * 0.045),
                      "claude.ai", fill=WHITE, font=font_lg)
        elif size >= 64:
            font_sm = get_font(max(size // 8, 8), bold=True)
            draw.text((ai_dot_x + dot_r + size * 0.03, ai_dot_y - size * 0.07),
                      "ai", fill=WHITE, font=font_sm)

        # Bottom-right area: Claude Code
        code_dot_x = outer - size * 0.22
        code_dot_y = outer - size * 0.28

        draw.ellipse([code_dot_x - dot_r, code_dot_y - dot_r,
                      code_dot_x + dot_r, code_dot_y + dot_r], fill=GREEN)

        if size >= 128:
            # Right-align "code" text to the left of the dot
            code_text = "code"
            bbox = draw.textbbox((0, 0), code_text, font=font_lg)
            tw = bbox[2] - bbox[0]
            draw.text((code_dot_x - dot_r - size * 0.04 - tw, code_dot_y - size * 0.045),
                      code_text, fill=WHITE, font=font_lg)
        elif size >= 64:
            bbox = draw.textbbox((0, 0), "</>", font=font_sm)
            tw = bbox[2] - bbox[0]
            draw.text((code_dot_x - dot_r - size * 0.03 - tw, code_dot_y - size * 0.07),
                      "</>", fill=WHITE, font=font_sm)

    elif size >= 32:
        # At small sizes, just show two colored dots
        dot_r = size * 0.12
        draw.ellipse([size * 0.22, size * 0.22, size * 0.22 + dot_r * 2, size * 0.22 + dot_r * 2], fill=GREEN)
        draw.ellipse([size * 0.58, size * 0.58, size * 0.58 + dot_r * 2, size * 0.58 + dot_r * 2], fill=GREEN)
    else:
        # 16px — single green dot
        dot_r = size * 0.2
        cx, cy = size / 2, size / 2
        draw.ellipse([cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r], fill=GREEN)

    return img


def main():
    with tempfile.TemporaryDirectory() as tmpdir:
        iconset = os.path.join(tmpdir, 'AppIcon.iconset')
        os.makedirs(iconset)

        for size in SIZES:
            img = draw_icon(size)
            if size <= 512:
                img.save(os.path.join(iconset, f'icon_{size}x{size}.png'))
            half = size // 2
            if half in [16, 32, 64, 128, 256, 512]:
                img.save(os.path.join(iconset, f'icon_{half}x{half}@2x.png'))

        icns_path = os.path.join(OUT_DIR, 'AppIcon.icns')
        subprocess.run(['iconutil', '-c', 'icns', iconset, '-o', icns_path], check=True)
        print(f'Generated {icns_path}')

        # Also save a preview PNG
        preview = draw_icon(512)
        preview_path = os.path.join(OUT_DIR, 'icon-preview.png')
        preview.save(preview_path)
        print(f'Preview saved to {preview_path}')


if __name__ == '__main__':
    main()
