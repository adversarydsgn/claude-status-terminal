#!/usr/bin/env python3
"""Generate a Claude Status app icon (.icns) with status dots for claude.ai and Claude Code."""

from PIL import Image, ImageDraw, ImageFont
import subprocess, tempfile, os, sys

SIZES = [16, 32, 64, 128, 256, 512, 1024]
OUT_DIR = os.path.dirname(os.path.abspath(__file__))

def draw_icon(size):
    """Draw a single icon at the given size."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    pad = size * 0.06
    r = size * 0.18  # corner radius

    # Background: dark rounded rect (#1a1a2e)
    bg_rect = [pad, pad, size - pad, size - pad]
    draw.rounded_rectangle(bg_rect, radius=r, fill=(26, 26, 46, 240))

    # Subtle border
    draw.rounded_rectangle(bg_rect, radius=r, outline=(60, 60, 90, 180), width=max(1, size // 128))

    # Center area
    cx = size / 2
    cy = size / 2

    # Draw two status dots (claude.ai and Claude Code)
    dot_r = size * 0.14
    gap = size * 0.22

    # Top dot — claude.ai
    dot1_y = cy - gap
    draw.ellipse(
        [cx - dot_r, dot1_y - dot_r, cx + dot_r, dot1_y + dot_r],
        fill=(118, 173, 42, 255)  # green (#76AD2A)
    )
    # Glow effect
    for i in range(3):
        glow_r = dot_r + (i + 1) * size * 0.02
        draw.ellipse(
            [cx - glow_r, dot1_y - glow_r, cx + glow_r, dot1_y + glow_r],
            outline=(118, 173, 42, 60 - i * 15)
        )

    # Bottom dot — Claude Code
    dot2_y = cy + gap
    draw.ellipse(
        [cx - dot_r, dot2_y - dot_r, cx + dot_r, dot2_y + dot_r],
        fill=(118, 173, 42, 255)  # green
    )
    for i in range(3):
        glow_r = dot_r + (i + 1) * size * 0.02
        draw.ellipse(
            [cx - glow_r, dot2_y - glow_r, cx + glow_r, dot2_y + glow_r],
            outline=(118, 173, 42, 60 - i * 15)
        )

    # Small labels next to dots (only at larger sizes)
    if size >= 128:
        try:
            font_size = max(size // 14, 8)
            font = ImageFont.truetype("/System/Library/Fonts/SFCompact.ttf", font_size)
        except (OSError, IOError):
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
            except (OSError, IOError):
                font = ImageFont.load_default()

        # "ai" label for top dot
        label_x = cx + dot_r + size * 0.06
        draw.text((label_x, dot1_y - font_size // 2), "ai", fill=(200, 200, 220, 200), font=font)

        # "</>" label for bottom dot (code)
        draw.text((label_x, dot2_y - font_size // 2), "</>", fill=(200, 200, 220, 200), font=font)

    return img

def main():
    with tempfile.TemporaryDirectory() as tmpdir:
        iconset = os.path.join(tmpdir, 'AppIcon.iconset')
        os.makedirs(iconset)

        for size in SIZES:
            img = draw_icon(size)
            # 1x
            if size <= 512:
                img_1x = img.resize((size, size), Image.LANCZOS)
                img_1x.save(os.path.join(iconset, f'icon_{size}x{size}.png'))
            # 2x (the @2x version is the next size up)
            half = size // 2
            if half in [16, 32, 64, 128, 256, 512]:
                img.save(os.path.join(iconset, f'icon_{half}x{half}@2x.png'))

        # Generate .icns
        icns_path = os.path.join(OUT_DIR, 'AppIcon.icns')
        subprocess.run(['iconutil', '-c', 'icns', iconset, '-o', icns_path], check=True)
        print(f'Generated {icns_path}')

if __name__ == '__main__':
    main()
